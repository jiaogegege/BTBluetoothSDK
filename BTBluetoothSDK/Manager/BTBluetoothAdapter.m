//
//  BTBluetoothAdapter.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTBluetoothAdapter.h"
#import "BTUtility.h"


@interface BTBluetoothAdapter()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property(nonatomic, strong)CBCentralManager *centralManager;       //系统蓝牙中心管理器
@property(nonatomic, strong)NSMutableArray *tempPeripheralArray;        //存放搜索到的外围设备

@property(nonatomic, strong)CBPeripheral *currentPeripheral;        //当前连接的外围设备，未连接为nil
@property(nonatomic, strong)NSMutableArray *servicesArray;      //当前连接设备的服务列表
@property(nonatomic, strong)CBService *service;             //服务
@property(nonatomic, strong)CBCharacteristic *writeCharacteristic;          //写特征
@property(nonatomic, strong)CBCharacteristic *readCharacteristic;            //读特征
@property(nonatomic, strong)dispatch_source_t connectTimer;     //连接的定时器


@end

@implementation BTBluetoothAdapter

static BTBluetoothAdapter *_adapter = nil;
    ///单例类方法
+(BTBluetoothAdapter *)adapter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _adapter = [[BTBluetoothAdapter alloc] init];
    });
    return _adapter;
}

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _state = BTDeviceStateDisconnect;
        _currentPeripheral = nil;
        _tempPeripheralArray = [NSMutableArray array];
        _servicesArray = [NSMutableArray array];
        _service = nil;
        _writeCharacteristic = nil;
        _readCharacteristic = nil;
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:@{CBCentralManagerOptionShowPowerAlertKey: @(YES)}];
        
    }
    return self;
}

#pragma mark - 自定义方法
///将外设对象转换为框架对象
-(BTPeripheralModel *)convertPeripheralToModel:(CBPeripheral *)peripheral
{
    if (peripheral)
    {
        BTPeripheralModel *peripheralModel = [[BTPeripheralModel alloc] initWithID:peripheral.identifier.UUIDString name:peripheral.name];
        return peripheralModel;
    }
    return nil;
}

///设置state
-(void)setState:(BTDeviceState)state
{
    _state = state;
    //调用代理方法
    if (self.delegate)
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidUpdateState:)])
        {
            [self.delegate blueToothAdapterDidUpdateState:state];
        }
    }
}

///开始扫描蓝牙设备
-(void)startScanDevice
{
    [_tempPeripheralArray removeAllObjects];
    [_servicesArray removeAllObjects];
    _service = nil;
    _writeCharacteristic = nil;
    _readCharacteristic = nil;
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    [self setState:BTDeviceStateSearching];
}

///停止扫描设备
-(void)stopScanDevice
{
//    NSLog(@"----------停止扫描------");
    [_centralManager stopScan];
//    [self setState:BTDeviceStateDisconnect];
}

    ///扫描到一个设备
-(void)didFoundPeripheral:(CBPeripheral *)peripheral
{
    [self.tempPeripheralArray addObject:peripheral];
    if (self.delegate)
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidFoundPeripheral:)])      //如果代理对象实现了这个方法
        {
            BTPeripheralModel *peripheralModel = [self convertPeripheralToModel:peripheral];
            [self.delegate blueToothAdapterDidFoundPeripheral:peripheralModel];
        }
    }
}

    ///连接某个设备
-(void)connectDevice:(BTPeripheralModel *)peripheralModel
{
//    NSLog(@"-------%d------", _centralManager.isScanning);
//    [self disconnectDevice];
    CBPeripheral *peripheral = nil;
    for (CBPeripheral *m in _tempPeripheralArray)
    {
        if ([m.name isEqualToString:peripheralModel.name])
        {
            peripheral = m;
            break;
        }
    }
    if (peripheral)
    {
            //开始倒计时
        if (_connectTimer)
        {
            dispatch_source_cancel(self.connectTimer);
            self.connectTimer = nil;
        }
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        _connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(1 * NSEC_PER_SEC));
        uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
        dispatch_source_set_timer(_connectTimer, startTime, interval, 0);
        __weak typeof(self) weak = self;
        __block NSInteger count = 0;
        dispatch_source_set_event_handler(_connectTimer, ^{
            count++;
            if (count >= CONNECT_TIME)      //到达连接时间上限，取消定时器
            {
                dispatch_source_cancel(weak.connectTimer);
                weak.connectTimer = nil;
                if (weak.state != BTDeviceStateConnected)   //连接没有成功
                {
                    [self->_tempPeripheralArray removeAllObjects];
                    if (self -> _currentPeripheral)     //如果这时连接着设备，那么断开
                    {
                        [self -> _centralManager cancelPeripheralConnection:self -> _currentPeripheral];
                    }
//                    [weak stopScanDevice];
                        //回调方法
                    if (self.delegate)
                    {
                        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidFailToConnectPeripheral:)])
                        {
                            [self.delegate blueToothAdapterDidFailToConnectPeripheral:[self convertPeripheralToModel:peripheral]];
                        }
                    }
                }
            }
        });
        dispatch_resume(_connectTimer);
        //, CBConnectPeripheralOptionStartDelayKey: @(CONNECT_DELAY)
        [_centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @(YES), CBConnectPeripheralOptionNotifyOnDisconnectionKey: @(YES), CBConnectPeripheralOptionNotifyOnNotificationKey: @(YES)}];
        [self setState:BTDeviceStateConnecting];
    }
    else
    {
        NSLog(@"找不到设备");
            //回调方法
        if (self.delegate)
        {
            if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidFailToConnectPeripheral:)])
            {
                [self.delegate blueToothAdapterDidFailToConnectPeripheral:[self convertPeripheralToModel:peripheral]];
            }
        }
    }
}

    ///断开当前连接
-(void)disconnectDevice
{
    if (_currentPeripheral)
    {
        [_centralManager cancelPeripheralConnection:_currentPeripheral];
        [self setState:BTDeviceStateDisconnecting];
    }
}

    ///写入数据
-(BOOL)writeDataToPeripheral:(NSData *)data
{
    if (_currentPeripheral && _writeCharacteristic && (_currentPeripheral.state == CBPeripheralStateConnected))
    {
        [_currentPeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
        return YES;
    }
    else
    {
        NSLog(@"adapter发送指令失败");
        return NO;
    }
}



#pragma mark - 系统蓝牙代理方法
    //开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOn:
        {
            NSLog(@"蓝牙已打开, 请扫描外设!");
            _isBluetoothOK = YES;
            [self startScanDevice];
//            [self stopScanDevice];
            break;
        }
        case CBManagerStatePoweredOff:
        {
            NSLog(@"蓝牙未打开, 请在设置中打开!");
            _isBluetoothOK = NO;
            /**
             *如果是iOS11，并且设备连接着，检测到了蓝牙关闭，那么需要调用蓝牙断开连接的方法，因为无法检测到设备断开
             */
            if (@available(iOS 11.0, *))
            {
                if (self.currentPeripheral)
                {
                    [self disconnectDevice];
                    [self centralManager:_centralManager didDisconnectPeripheral:_currentPeripheral error:nil];
                }
            }
            break;
        }
        case CBManagerStateUnknown:
        {
            NSLog(@">>>CBCentralManagerStateUnknown");
            _isBluetoothOK = NO;
            break;
        }
        case CBManagerStateResetting:
        {
            NSLog(@">>>CBCentralManagerStateResetting");
            _isBluetoothOK = NO;
            break;
        }
        case CBManagerStateUnsupported:
        {
            NSLog(@">>>CBCentralManagerStateUnsupported");
            _isBluetoothOK = NO;
            break;
        }
        case CBManagerStateUnauthorized:
        {
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            _isBluetoothOK = NO;
            break;
        }
        default:
            break;
    }
}

    //扫描到外设后的方法:peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(![BTUtility isEmptyString:peripheral.name] && [peripheral.name hasPrefix:DEVICE_NAME_PREFIX])
    {
            //判断是否有重名设备
        BOOL isExist = NO;
        for (CBPeripheral *existPerpheral in _tempPeripheralArray)
        {
            if ([existPerpheral.name isEqualToString:peripheral.name])      //如果有重名设备，那么只保留一个
            {
                isExist = YES;
                break;
            }
        }
        if (isExist == NO)  //不存在同名设备则添加
        {
            //调用方法
            [self didFoundPeripheral:peripheral];
        }
    }
}

    //连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    dispatch_source_cancel(self.connectTimer);
    self.connectTimer = nil;
    _currentPeripheral = peripheral;
    _currentPeripheral.delegate = self;
    [_tempPeripheralArray removeAllObjects];
    [_servicesArray removeAllObjects];
    [self stopScanDevice];
    _writeCharacteristic = nil;
    _readCharacteristic = nil;
    NSLog(@"连接成功...");
    [self setState:BTDeviceStateConnecting];       //只有当所有的服务和特征都准备好之后才是连接状态
    [_currentPeripheral discoverServices:nil];
    [_centralManager stopScan];
}

    //连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接外设失败");
    if (error)
    {
        NSLog(@"%@", error.localizedDescription);
    }
    _currentPeripheral = nil;
    [self setState:BTDeviceStateDisconnect];
        //回调方法
    if (self.delegate)
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidFailToConnectPeripheral:)])
        {
            [self.delegate blueToothAdapterDidFailToConnectPeripheral:[self convertPeripheralToModel:peripheral]];
        }
    }
//    [_tempPeripheralArray removeAllObjects];
    [_servicesArray removeAllObjects];
    _service = nil;
    _writeCharacteristic = nil;
    _readCharacteristic = nil;
}

    ///断开设备连接的回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"设备已经断开连接");
    if (error)
    {
        NSLog(@"error:%@", error.localizedDescription);
    }
    [self setState:BTDeviceStateDisconnect];
    //回调方法
    if (self.delegate && _service)  //设备连接上了，但是没有找到对应的服务，那么不需要通知外部管理器
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidDisconnectedPeripheral:)])
        {
            [self.delegate blueToothAdapterDidDisconnectedPeripheral:[self convertPeripheralToModel:peripheral]];
        }
    }
        //    [_tempPeripheralArray removeAllObjects];
    _currentPeripheral = nil;
    [_servicesArray removeAllObjects];
    _service = nil;
    _writeCharacteristic = nil;
    _readCharacteristic = nil;
}

    ///已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
//    int i = 0;
    for(CBService* s in peripheral.services)
    {
//        NSLog(@"发现服务service:%@", s.UUID.UUIDString);
        [self.servicesArray addObject:s];
        if ([s.UUID.UUIDString isEqualToString:SERVICE])
        {
            _service = s;
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
    [self setState:BTDeviceStateConnecting];
}

    ///已发现characteristcs
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic* c in service.characteristics)
    {
//        NSLog(@"service UUID:%@", service.UUID.UUIDString);
//        NSLog(@"特征 UUID: %@ (%@)", c.UUID.data, c.UUID);
        if([c.UUID.UUIDString isEqualToString:WRITE_CHARACTERISTIC])
        {
            _writeCharacteristic = c;
//            NSLog(@"找到WRITE特征 : %@", c);
        }
        else if([c.UUID.UUIDString isEqualToString:READ_CHARACTERISTIC])
        {
            _readCharacteristic = c;
            [_currentPeripheral setNotifyValue:YES forCharacteristic:c];
//            NSLog(@"找到READ特征 : %@", c);
        }
    }
    [self setState:BTDeviceStateConnected];
    
        //回调方法，当连接上蓝牙，并且读写特征都准备好之后才是真正连接上了设备
    if (_writeCharacteristic && _readCharacteristic)
    {
        if (self.delegate)
        {
            if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidConnectedPeripheral:)])
            {
                [self.delegate blueToothAdapterDidConnectedPeripheral:[self convertPeripheralToModel:peripheral]];
            }
        }
    }
    else
    {
        NSLog(@"获取蓝牙设备读写特征失败");
//        [self disconnectDevice];
    }

}

    //获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"value:%@", characteristic.value);
    if (self.delegate)
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidReceivedData:)])
        {
            [self.delegate blueToothAdapterDidReceivedData:characteristic.value];
        }
    }
}

    //中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error)
    {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    if(characteristic.isNotifying)
    {
//        [peripheral readValueForCharacteristic:characteristic];
    }
    else
    {
        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
//        [_centralManager cancelPeripheralConnection:_currentPeripheral];
        [self disconnectDevice];
    }
}

    //向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"写入数据失败：%@", error.localizedDescription);
    }
    
    //回调方法
    if (self.delegate)
    {
        if ([self.delegate conformsToProtocol:@protocol(BTBluetoothAdapterDelegate)] && [self.delegate respondsToSelector:@selector(blueToothAdapterDidWriteDataToPeripheral:)])
        {
            [self.delegate blueToothAdapterDidWriteDataToPeripheral:(error ? NO : YES)];
        }
    }
}















@end
