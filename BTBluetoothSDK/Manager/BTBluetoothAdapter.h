//
//  BTBluetoothAdapter.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 蓝牙适配器，封装系统蓝牙相关功能
 1.包括蓝牙连接、断开蓝牙
 2.传输指令原始数据
 3.设备连接状态更新
 **/

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConstDefine.h"
#import "BTPeripheralModel.h"


@protocol BTBluetoothAdapterDelegate<NSObject>
@required
///发现了一个设备
-(void)blueToothAdapterDidFoundPeripheral:(BTPeripheralModel *)peripheral;

///连接外设成功
-(void)blueToothAdapterDidConnectedPeripheral:(BTPeripheralModel *)peripheral;

///断开了外设的连接
-(void)blueToothAdapterDidDisconnectedPeripheral:(BTPeripheralModel *)peripheral;

///外设连接失败
-(void)blueToothAdapterDidFailToConnectPeripheral:(BTPeripheralModel *)peripheral;

///接收到外设发来的数据
-(void)blueToothAdapterDidReceivedData:(NSData *)data;

@optional
///写入数据后的成功或失败回调
-(void)blueToothAdapterDidWriteDataToPeripheral:(BOOL)success;

///更新了蓝牙连接状态
-(void)blueToothAdapterDidUpdateState:(BTDeviceState)state;




@end


@interface BTBluetoothAdapter : NSObject

///蓝牙连接状态：未连接/已连接/连接中/搜索中
@property(nonatomic, assign, readonly)BTDeviceState state;

///系统蓝牙是否开启
@property(nonatomic, assign, readonly)BOOL isBluetoothOK;

///代理对象
@property(nonatomic, weak)id<BTBluetoothAdapterDelegate> delegate;



///单例类方法
+(BTBluetoothAdapter *)adapter;

    ///开始扫描蓝牙设备
-(void)startScanDevice;

    ///停止扫描设备
-(void)stopScanDevice;

///连接某个设备
-(void)connectDevice:(BTPeripheralModel *)peripheralModel;

///断开当前连接
-(void)disconnectDevice;

///写入数据
-(BOOL)writeDataToPeripheral:(NSData *)data;









@end
