//
//  BTManager.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTManager.h"
#import "BTUtility.h"
#import "BTBluetoothAdapter.h"
#import "BTTaskDispatcher.h"
#import "BTLogRecorder.h"


@interface BTManager()<BTBluetoothAdapterDelegate, BTTaskDispatcherDelegate>
{
    BTManagerWorkMode _workMode;           //工作模式，如果在后台模式下，屏蔽所有界面的指令请求
    BOOL _needReconnect;        //当从后台进入前台的过程中，是否需要自动重连
}
@property(nonatomic, strong)BTBluetoothAdapter *adapter;        //蓝牙适配器，和系统蓝牙通信
@property(nonatomic, strong)BTTaskDispatcher *dispatcher;           //任务调度器，接收和发送指令线程，处理指令数据
@property(nonatomic, strong)BTLogRecorder *recorder;            //log记录器

@property(nonatomic, strong)NSPointerArray *delegates DEPRECATED_ATTRIBUTE;      //服务协议代理对象们(deprecated)
@property(nonatomic, strong)NSMutableArray *tempPeripheralArray;        //用于存放搜索到的设备
/**
 * 设备断开连接的方式：手动或自动，手动断开不需要自动重连；自动断开需要自动重连
 * 总结来讲，设备断开有三种情况：
 1.系统蓝牙因为距离太远或者设备关机而断开连接，这个时候管理器只是被告知蓝牙断开了，在不知道什么情况的时候需要自动重连
 2.管理器主动断开，比如通信超时，3次重连失败等，这种情况下管理器会主动断开蓝牙，方法会通过管理器执行，然后再自动重连
 3.用户断开连接，用户手动点击断开蓝牙按钮，这是时候不需要自动重连，方法会通过管理器执行
 * 所以，管理器倾向于自动断开模式，当设备连接上之后，就应该把这个属性设为自动模式
 */
@property(nonatomic, assign)BTBluetoothDisconnectWay disconnectWay;
@property(nonatomic, assign)NSTimeInterval autoConnectTryTime;          //自动重连时间，每次置零
@property(nonatomic, strong)dispatch_source_t autoConnectTimer;      //自动重连计时器
@property(nonatomic, strong)dispatch_source_t pollingDeviceInfoTimer;           //轮询设备信息的定时器，500ms一次


@end

@implementation BTManager

/**
 获取单例类方法
 */
static BTManager *_manager = nil;
+(BTManager *)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[BTManager alloc] init];
    });
//    [_manager.delegates compact];       //清理null对象
    return _manager;
}

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _delegates = [NSPointerArray weakObjectsPointerArray];
        _tempPeripheralArray = [NSMutableArray array];
        _adapter = [BTBluetoothAdapter adapter];
        _adapter.delegate = self;
        _dispatcher = [BTTaskDispatcher dispatcher];
        _dispatcher.delegate = self;
        _connectState = _adapter.state;
        _currentDevice = nil;
        _workMode = BTManagerWorkModeActive;
        _disconnectWay = BTBluetoothDisconnectWayAutomatic;
        _autoConnectTryTime = 0;
        _maxAutoConnectTime = MAX_RETRY_TIME;
        _needReconnect = NO;    //默认不自动重连
        _logEnabled = NO;       //默认不记录log
    }
    return self;
}

/*
///设置代理的方法
-(void)setDelegate:(id<BTManagerServices>)delegate
{
    [_delegates addPointer:NULL];
    [_delegates compact];
    [BTUtility asyncPerformActionOnGlobalThread:^{
        if ([delegate conformsToProtocol:@protocol(BTManagerServices)])
        {
            [self -> _delegates addPointer:(__bridge void * _Nullable)(delegate)];
        }
    }];

}
 */

///设置是否记录log
-(void)setLogEnabled:(BOOL)logEnabled
{
    _logEnabled = logEnabled;
    if (logEnabled)     //记录日志
    {
        if (!_recorder)     //还没有创建日志记录器，那么创建一下
        {
            _recorder = [BTLogRecorder recorder];
        }
    }
    if (_recorder)
    {
        _recorder.logEnabled = logEnabled;
    }
}

    ///设置工作模式，工作模式有前台和后台模式
-(void)setWorkMode:(BTManagerWorkMode)mode
{
    _workMode = mode;
    [_dispatcher setWorkMode:mode];
    switch (mode)
    {
        case BTManagerWorkModeActive:       //前台工作模式
        {
            //进入前台后首先查看设备是否连接，如果连接了，那么需要开始工作，如果没有连接，那么也不需要做什么
            if (_currentDevice && [self checkConnectOK])
            {
                    //dispatcher开始工作
                [_dispatcher startWorking];
                    //BTManager开始轮询设备信息
                [self startPollingDeviceState];
            }
            else if (_needReconnect) //当前在自动重连状态中
            {
                [self autoReconnect];
            }
            break;
        }
        case BTManagerWorkModeSilent:       //后台工作模式
        {
            //停止轮询设备信息
            [self stopPollingDeviceState];
            //让dispatcher停止工作
            [_dispatcher stopWorking];
            break;
        }
        default:
        {
            NSLog(@"未知工作模式");
            break;
        }
    }
}

///获取蓝牙状态
-(BOOL)isBluetoothOK
{
    return _adapter.isBluetoothOK;
}

#pragma mark 设备连接相关
///设置设备连接状态
-(void)setConnectState:(BTDeviceState)connectState
{
    _connectState = connectState;
    if (self.currentDevice)
    {
        self.currentDevice.state = _connectState;
    }
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidUpdateConnectState:)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidUpdateConnectState:connectState];
        }];
    }
}

    ///开始扫描设备
-(void)startScan
{
    [BTUtility asyncPerformActionOnGlobalThread:^{
        [self -> _adapter startScanDevice];
    }];
    
}

    ///停止扫描
-(void)stopScan
{
    [BTUtility asyncPerformActionOnGlobalThread:^{
        [self -> _adapter stopScanDevice];
    }];
    
}

///连接某个设备
-(void)connect:(BTPeripheralModel *)peripheral
{
    [BTUtility asyncPerformActionOnGlobalThread:^{
        [self -> _adapter connectDevice:peripheral];
    }];
    
}

    ///断开当前连接的设备，参数1:手动或自动，自动断开的话需要自动重连
-(void)disconnect:(BTBluetoothDisconnectWay)way
{
    if (_currentDevice && [self checkConnectOK])     //设备连接的时候才断开
    {
        self -> _disconnectWay = way;
        [self stopPollingDeviceState];
        [self -> _adapter disconnectDevice];
    }
    //如果是手动断开连接，那么不需要存储设备信息
    if (way == BTBluetoothDisconnectWayManual)
    {
        _currentDevice =nil;
    }
}

///自动重连
-(void)autoReconnect
{
    __weak typeof(self) weak = self;
    [BTUtility asyncPerformActionOnGlobalThread:^{
        [weak autoReconnectOnGlobalThread];
    }];
    _needReconnect = NO;
}

///在后台线程中自动重连
-(void)autoReconnectOnGlobalThread
{
    if (_autoConnectTimer)
    {
        dispatch_source_cancel(_autoConnectTimer);
        _autoConnectTimer = nil;
    }
    [self startScan];
        //开始倒计时
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    _autoConnectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(1 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(_autoConnectTimer, startTime, interval, 0);
    __weak typeof(self) weak = self;
    dispatch_source_set_event_handler(_autoConnectTimer, ^{
        [weak autoConnectCountdown];
    });
    dispatch_resume(_autoConnectTimer);
    
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidStartAutoConnect)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidStartAutoConnect];
        }];
    }
}

///自动重连倒计时方法
-(void)autoConnectCountdown
{
    _autoConnectTryTime++;
    if (_autoConnectTryTime < self.maxAutoConnectTime)  //继续倒计时
    {
        if (_autoConnectTryTime > 3)        //搜索3s后再开始连接
        {
            [self connect:_currentDevice];
        }
        
    }
    else    //停止倒计时
    {
        [self resetAutoConnect];
    }
}

///判断自动重连是否成功
-(BOOL)checkConnectOK
{
    switch (_connectState) {
        case BTDeviceStateOK:
        {
            return YES;
            break;
        }
        case BTDeviceStateConnected:
        {
            return YES;
            break;
        }
        case BTDeviceStateSearching:
        {
            return NO;
            break;
        }
        case BTDeviceStateConnecting:
        {
            return NO;
            break;
        }
        case BTDeviceStateDisconnecting:
        {
            return NO;
            break;
        }
        case BTDeviceStateDisconnect:
        {
            return NO;
            break;
        }
        case BTDeviceStateUnknown:
        {
            return NO;
            break;
        }
        default:
        {
            return NO;
            break;
        }
    }
}

///重置自动重连计时器
-(void)resetAutoConnect
{
    if (_autoConnectTimer)
    {
        dispatch_source_cancel(_autoConnectTimer);
        _autoConnectTimer = nil;
    }
    _autoConnectTryTime = 0;
    [_adapter stopScanDevice];
    
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidFinishAutoConnect:)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidFinishAutoConnect:[weak checkConnectOK]];
        }];
    }
}


#pragma mark 指令相关
/**
 以接口方式调用指令功能，给下位机发送指令，一般用于外部程序主动发起蓝牙通讯需求，比如发送控制指令、发送设置指令、传输数据指令、主动从下位机获取数据等
 */
-(void)sendCommand:(CommandType)commandType parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    if (_workMode == BTManagerWorkModeActive)
    {
            //在后台线程中执行
        [BTUtility asyncPerformActionOnGlobalThread:^{
            [self -> _dispatcher sendCommand:commandType parameters:parameters success:^(CommandType commandType, NSDictionary *object) {
                [BTUtility asyncPerformActionOnMainThread:^{        //在主线程中返回
                    success(commandType, object);
                }];
            } failure:^(CommandType commandType, BTError *error) {
                [BTUtility asyncPerformActionOnMainThread:^{        //在主线程中返回
                    failure(commandType, error);
                }];
            }];
        }];
    }
}

/**
 以接口方式调用指令功能，给下位机发送指令，一般用于内部程序主动发起蓝牙通讯需求，比如轮询指令，查询设备信息等
 */
-(void)sendCommandInBackground:(CommandType)commandType parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    if (_workMode == BTManagerWorkModeActive)
    {
            //在后台线程中执行
        [BTUtility asyncPerformActionOnGlobalThread:^{
            [self -> _dispatcher sendCommand:commandType parameters:parameters success:success failure:failure];
        }];
    }
}

///查询从机信息，这里会返回设备的基础信息，包括：name/序列号/软硬件版本
-(void)fetchDeviceInfo
{
    __weak typeof(self) weak = self;
    [self sendCommandInBackground:CommandType_DeviceInfo parameters:nil success:^(CommandType commandType, NSDictionary *object) {
        if ([object[Command_Status] boolValue])
        {
            //如果解析成功，那么开始轮询设备状态
            BTDeviceModel *model = (BTDeviceModel *)object[Command_objValue];
            NSLog(@"从机信息:%@", model);
            [weak.currentDevice getDataFromInstance:model];
            weak.currentDevice.state = BTDeviceStateOK;
            self -> _connectState = BTDeviceStateOK;
            //通知外部程序已经连接上
            if ([weak.delegate conformsToProtocol:@protocol(BTManagerServices)] && [weak.delegate respondsToSelector:@selector(managerDidConnectDevice:)])
            {
                __weak typeof(self) weak = self;
                [BTUtility asyncPerformActionOnMainThread:^{
                    [weak.delegate managerDidConnectDevice:weak.currentDevice];
                }];
            }
            //开始轮询设备状态，包括电池/电极
            [weak startPollingDeviceState];
        }
        else
        {
            NSLog(@"----------指令解析失败-------------");
        }
    } failure:^(CommandType commandType, BTError *error) {
        NSLog(@"查询从机信息 error:%@", error.localizedDescription);
        switch (error.code)
        {
            case BTCommandStatus_IllegalError:  //非法操作
            {
                [weak fetchDeviceInfo];
                break;
            }
            case BTCommandStatus_BusyError:     //设备忙
            {
                [weak fetchDeviceInfo];
                break;
            }
            case BTCommandStatus_DeviceError:       //设备类型不匹配，断开连接，并通知外部程序
            {
                [weak disconnect:BTBluetoothDisconnectWayManual];
                if ([weak.delegate conformsToProtocol:@protocol(BTManagerServices)] && [weak.delegate respondsToSelector:@selector(managerDidNotMatchDevice)])
                {
                    [BTUtility asyncPerformActionOnMainThread:^{
                        [weak.delegate managerDidNotMatchDevice];
                    }];
                }
                break;
            }
            case BTCommandStatus_TimeoutError:      //如果查询设备信息的指令超时，说明设备有问题，直接断开连接
            {
                [weak disconnect:BTBluetoothDisconnectWayManual];
                break;
            }
            default:
            {
                [weak disconnect:BTBluetoothDisconnectWayManual];
                break;
            }
        }
    }];
}

///开始轮询设备状态（查询从机状态），包括：电量/工作状态/运行模式等；还可能返回异常信息
-(void)startPollingDeviceState
{
    //开始轮询定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
     _pollingDeviceInfoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(TIME_INTERVAL_FETCH_STATE * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(TIME_INTERVAL_FETCH_STATE * NSEC_PER_SEC);
    dispatch_source_set_timer(_pollingDeviceInfoTimer, startTime, interval, 0);
    __weak typeof(self) weak = self;
    dispatch_source_set_event_handler(_pollingDeviceInfoTimer, ^{
        [weak pollingDeviceState];
    });
    dispatch_resume(_pollingDeviceInfoTimer);
}

///轮询设备信息的具体方法
-(void)pollingDeviceState
{
    __weak typeof(self) weak = self;
    [self sendCommandInBackground:CommandType_DeviceState parameters:nil success:^(CommandType commandType, NSDictionary *object) {
        if ([object[Command_Status] boolValue])
        {
            //判断是对象还是异常
            id obj = object[Command_objValue];
//            NSLog(@"设备信息:%@", obj);
            if ([obj isKindOfClass:[BTDeviceModel class]])      //如果是设备对象
            {
                //更新设备信息并传给外部程序
                [weak.currentDevice getDataFromInstance:(BTDeviceModel *)obj];
                if ([weak.delegate conformsToProtocol:@protocol(BTManagerServices)] && [weak.delegate respondsToSelector:@selector(managerDidUpdateDeviceInfo:)])
                {
                    [BTUtility asyncPerformActionOnMainThread:^{
                        [weak.delegate managerDidUpdateDeviceInfo:[weak.currentDevice copy]];
                    }];
                }
            }
            else if ([obj isKindOfClass:[BTException class]])       //如果是异常
            {
                if ([weak.delegate conformsToProtocol:@protocol(BTManagerServices)] && [weak.delegate respondsToSelector:@selector(managerDidCatchDeviceException:)])
                {
                    [BTUtility asyncPerformActionOnMainThread:^{
                        [weak.delegate managerDidCatchDeviceException:(BTException *)obj];
                    }];
                }
            }
            else
            {
                NSLog(@"解析的设备状态：%@", obj);
            }
        }
        else
        {
            NSLog(@"----------指令解析失败-------------");
        }
    } failure:^(CommandType commandType, BTError *error) {
        //如果指令发生了错误，不用管，继续轮询
        NSLog(@"轮询设备信息 error:%@", error.localizedDescription);
    }];
}

///停止轮询设备信息
-(void)stopPollingDeviceState
{
    if (_pollingDeviceInfoTimer)
    {
        dispatch_source_cancel(_pollingDeviceInfoTimer);
        _pollingDeviceInfoTimer = nil;
    }

}


#pragma mark - 适配器代理方法
///适配器更新了连接状态
-(void)blueToothAdapterDidUpdateState:(BTDeviceState)state
{
    [self setConnectState:state];
}

///获取了下位机的数据，需要将数据分派到容器中
-(void)blueToothAdapterDidReceivedData:(NSData *)data
{
//    NSLog(@"接收到数据：%@", data);
    [BTUtility asyncPerformActionOnGlobalThread:^{
        [self -> _dispatcher receivedData:data];
    }];
    
}

///发现了一个设备
-(void)blueToothAdapterDidFoundPeripheral:(BTPeripheralModel *)peripheral
{
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidFoundPeripheral:)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidFoundPeripheral:peripheral];
        }];
    }
}

///连接上了一个设备，连接上设备后需要发送基础指令查询相关信息，暂时不能告诉外部程序已经连上了
-(void)blueToothAdapterDidConnectedPeripheral:(BTPeripheralModel *)peripheral
{
    _disconnectWay = BTBluetoothDisconnectWayAutomatic;
    _needReconnect = NO;
    _currentDevice = [BTDeviceModel deviceFromPeripheral:peripheral];
    //连上设备后停止扫描
    [self stopScan];
        //如果在自动重连状态中，需要取消自动重连
    if (_disconnectWay == BTBluetoothDisconnectWayAutomatic && _autoConnectTimer)
    {
        [self resetAutoConnect];
    }
    
    //开启发送和接收线程
    [_dispatcher startWorking];
    //开始查询设备信息
    [self fetchDeviceInfo];
    
}

///设备断开连接后
-(void)blueToothAdapterDidDisconnectedPeripheral:(BTPeripheralModel *)peripheral
{
        //停止轮询
    [self stopPollingDeviceState];
    //停止工作
    [_dispatcher stopWorking];
    //通知外部程序
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidDisconnectDevice:)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidDisconnectDevice:weak.currentDevice];
        }];
    }
    
    //是否自动重连
    if (_workMode == BTManagerWorkModeActive)
    {
        //判断条件，设备连接标志符是自动连接，自动连接计时器关闭状态
        if (_disconnectWay == BTBluetoothDisconnectWayAutomatic && !_autoConnectTimer)
        {
            [self autoReconnect];
        }
        else
        {
                //通知外部程序，断开连接的时候并不需要自动连接
            if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidNotWantAutoConnect)])
            {
                __weak typeof(self) weak = self;
                [BTUtility asyncPerformActionOnMainThread:^{
                    [weak.delegate managerDidNotWantAutoConnect];
                }];
            }
            _currentDevice = nil;
        }
    }
    else        //app在后台，那么记录自动重连状态
    {
        if (_disconnectWay == BTBluetoothDisconnectWayAutomatic && !_autoConnectTimer)
        {
            _needReconnect = YES;
        }
    }
}

///设备连接失败后
-(void)blueToothAdapterDidFailToConnectPeripheral:(BTPeripheralModel *)peripheral
{
    [_dispatcher stopWorking];
    //连接失败的情况下判断是否还在自动重连倒计时中，在的话需要继续尝试连接
    if (_disconnectWay == BTBluetoothDisconnectWayAutomatic && _autoConnectTimer)
    {
        
    }
    else        //正常连接失败，告诉外部程序
    {
        if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidDisconnectDevice:)])
        {
            __weak typeof(self) weak = self;
            [BTUtility asyncPerformActionOnMainThread:^{
                [weak.delegate managerDidDisconnectDevice:weak.currentDevice];
            }];
        }
        _currentDevice = nil;
    }
    
}

    ///写入数据的回复，先不管
-(void)blueToothAdapterDidWriteDataToPeripheral:(BOOL)success
{
    
}

#pragma mark 任务调度器代理方法
///发送指令
-(void)taskDispatcherWantSendCommand:(SendCommandModel *)sendCommand
{
    if (sendCommand)
    {
        if ([_adapter writeDataToPeripheral:sendCommand.commandDataFormat])
        {
            if (![sendCommand.commandStringFormat hasPrefix:@"02"] && ![sendCommand.commandStringFormat hasPrefix:@"03"] && ![sendCommand.commandStringFormat hasPrefix:@"0d"])
            {
                NSLog(@"manager发送指令成功:%@", sendCommand.commandDataFormat);
            }
        }
        else
        {
            NSLog(@"manager未收到发送指令：%@", sendCommand.commandStringFormat);
        }
    }
}

///发现了异常，停止轮询
-(void)taskDispatcherDidFoundException:(BTException *)exception
{
    //停止轮询
//    [self stopPollingDeviceState];
    //通知外部程序
    if ([_delegate conformsToProtocol:@protocol(BTManagerServices)] && [_delegate respondsToSelector:@selector(managerDidCatchDeviceException:)])
    {
        __weak typeof(self) weak = self;
        [BTUtility asyncPerformActionOnMainThread:^{
            [weak.delegate managerDidCatchDeviceException:exception];
        }];
        
    }
}

///发生了指令超时，那么断开连接并尝试重连
-(void)taskDispatcherDidCatchCommunicationTimeout:(BTError *)error commandType:(CommandType)type
{
    [_dispatcher stopWorking];      //停止所有指令线程
    [self disconnect:BTBluetoothDisconnectWayAutomatic];        //断开连接
}

///发现了指令错误，感兴趣的话处理一下
-(void)taskDispatcherDidFoundCommandError:(BTError *)error
{
    
}







@end
