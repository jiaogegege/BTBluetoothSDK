//
//  BTManager.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 这个类是整个sdk的管理器，主要功能：
 1.连接蓝牙，断开蓝牙
 2.接收蓝牙发送的数据和发送数据给蓝牙的中转站，sdk全局控制管理中心
 3.单例类
 4.提供外部程序控制蓝牙的接口和服务，比如发送指令给蓝牙，传出指令数据给外部程序
 5.管理前后台线程控制，指令传输
 6.指令和数据流入流出的通道
 7.提供一组服务，以协议的形式供外部程序实现，服务主要包括各种轮询指令的返回结果，比如：设备信息、异常信息、蓝牙连接状态等
 8.提供一组接口给外部程序调用，用于发送指令并回调指令执行结果，类似网络接口的形式
 
 */

#import <Foundation/Foundation.h>
#import "BTCommandDefine.h"
#import "BTConstDefine.h"
#import "SendCommandModel.h"
#import "ReceivedCommandModel.h"
#import "BTException.h"
#import "BTDeviceModel.h"



#pragma - mark 服务协议，都要在主线程中执行
@protocol BTManagerServices<NSObject>
@optional
///发现了一个设备
-(void)managerDidFoundPeripheral:(BTPeripheralModel *)peripheral;

///更新了设备连接状态：搜索中/连接中/已连接/未连接/连接正常
-(void)managerDidUpdateConnectState:(BTDeviceState)state;

///连接上了设备，这个方法会在连接上蓝牙，并且一切初始化指令发送正常之后被调用，建议所有外部指令在这个方法成功回调之后再发起请求
-(void)managerDidConnectDevice:(BTDeviceModel *)device;

///设备断开了连接
-(void)managerDidDisconnectDevice:(BTDeviceModel *)device;

///更新了设备信息，这个方法希望被外部程序常驻内存的对象实现，因为更新设备信息的服务会经常发生
-(void)managerDidUpdateDeviceInfo:(BTDeviceModel *)deviceInfo;

///设备发生了异常，设备级的异常信息，比如：电极脱落，存储错误等，指令是正常的。这个方法希望被外部程序的一个全局对象实现，可以实时通知异常信息；这个方法希望被外部程序的常驻内存的对象实现，因为出现异常后需要界面提示和处理
-(void)managerDidCatchDeviceException:(BTException *)exception;

///指令发生了错误，发生了指令级别的错误，说明指令发送或接收失败，这个方法希望被一些想关注指令返回错误的对象实现，一般发送指令的对象会自己处理失败的回调
-(void)managerDidCatchCommandError:(BTError *)error;

///正在自动重连中，界面应该有一些提示，比如转菊花
-(void)managerDidStartAutoConnect;

///自动重连结束，返回重连结果，yes：重连成功；no：重连失败；外部程序应该根据返回结果提示接下来的操作
///no：弹出提示框让用户选择退出连接还是继续重连
-(void)managerDidFinishAutoConnect:(BOOL)result;

///设备类型不匹配，断开连接的服务协议，似乎不需要实现
-(void)managerDidNotMatchDevice;

///管理器不想自动重连
-(void)managerDidNotWantAutoConnect;


@end


#pragma - mark 类接口定义
@interface BTManager : NSObject
/**属性和变量*/
///当前连接的设备，断开后为nil
@property(nonatomic, strong, readonly)BTDeviceModel *currentDevice;

    ///设备连接状态，当这个状态是`BTDeviceStateOK`的时候才建议外部程序发送指令
@property(nonatomic, assign, readonly)BTDeviceState connectState;

    ///当前蓝牙开启状态
@property(nonatomic, assign, readonly)BOOL isBluetoothOK;

///(DEPRECATED_ATTRIBUTE)服务协议代理对象是一个弱引用数组，因为数组中的代理对象不一定全部实现服务协议中的方法，但是有些服务方法需要被不同的对象实现
///是一个单独的对象，只有一个，通常是外部的全局对象，比如AppDelegate
@property(nonatomic, weak)id<BTManagerServices> delegate;

///最大自动重连时间，默认30s
@property(nonatomic, assign)NSTimeInterval maxAutoConnectTime;

///是否需要记录log
@property(nonatomic, assign)BOOL logEnabled;


/**方法*/
/// 获取单例类方法
+(BTManager *)manager;

#pragma mark 外部接口，都要在后台线程中执行
///开始扫描设备
-(void)startScan;

///停止扫描
-(void)stopScan;

///连接某个设备
-(void)connect:(BTPeripheralModel *)peripheral;

///断开当前连接的设备
-(void)disconnect:(BTBluetoothDisconnectWay)way;

    ///自动重连
-(void)autoReconnect;

///设置工作状态，工作状态有前台和后台模式，默认初始化的时候是前台模式
-(void)setWorkMode:(BTManagerWorkMode)mode;



/**
 以接口方式调用指令功能，给下位机发送指令，一般用于外部程序主动发起蓝牙通讯请求，比如发送控制指令、发送设置指令、传输数据指令、主动从下位机获取数据等
 所有参数都应该是NSNumber类型
 */
-(void)sendCommand:(CommandType)commandType parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;




@end







