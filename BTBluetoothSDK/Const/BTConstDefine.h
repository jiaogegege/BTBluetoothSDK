//
//  BTConstDefine.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 1.常量定义，比如重试次数、最大重连时间等
 2.常用宏定义
 **/

#ifndef BTConstDefine_h
#define BTConstDefine_h

#ifdef DEBUG
#define NSLog(format, ...) printf("\n[%s] %s: %s", __TIME__, __FUNCTION__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

//#ifndef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#define NSLog(...){}
//#endif

///设备连接状态
typedef NS_ENUM(NSInteger, BTDeviceState) {
    BTDeviceStateOK,            //已连接并且一切正常
    BTDeviceStateDisconnect,        //未连接
    BTDeviceStateDisconnecting,     //断开连接中
    BTDeviceStateConnected,       //已连接，还没有通过验证
    BTDeviceStateConnecting,        //连接中
    BTDeviceStateSearching,         //搜索中
    
    BTDeviceStateUnknown            //未知状态，用不到
};

    ///断开连接的方式：手动或自动
typedef NS_ENUM(NSInteger, BTBluetoothDisconnectWay) {
    BTBluetoothDisconnectWayManual = 0,         //手动断开，用户自动断开设备，不需要自动重连，一般是从界面操作过来
    BTBluetoothDisconnectWayAutomatic      //自动断开，由于设备或者系统问题自动断开的，那么要自动重连，一般是蓝牙框架内部操作
};

///蓝牙框架工作模式
typedef NS_ENUM(NSInteger, BTManagerWorkMode) {
    BTManagerWorkModeActive = 0,        //前台工作模式，当app进入前台时，需要设置为这种模式
    BTManagerWorkModeSilent         //静默工作模式，当app进入后台时，需要设置为这种模式
};

///接收到的指令的类型
typedef NS_ENUM(NSInteger, ReceivedCommandType) {
    ReceivedCommandTypeNone,            //没有类型，说明不是个可识别指令，建议丢弃
    ReceivedCommandTypeSendedCommand,     //主动发起的控制指令
    ReceivedCommandTypeSendedData,        //主动发起的数据指令
    ReceivedCommandTypeNoSendCommand,       //非主动发起的控制指令
    ReceivedCommandTypeNoSendData,           //非主动发起的数据指令
    ReceivedCommandTypeNoSendException      //非主动发起的异常信息指令
};


///指令最大重试次数，3次
#define MAX_RETRY_COUNT 3

///3次重试时间间隔
#define RETRY_TIME_INTERVAL 0.5

///最大重连时间
#define MAX_RETRY_TIME 30

///指令最大并发数
#define MAX_COMMAND_CONCURRENCY 1

///发送指令间隔
#define TIME_INTERVAL_FOR_SEND_COMMAND 0.01

///接收指令的间隔
#define TIME_INTERVAL_FOR_RECEIVE_COMMAND 0.01

///轮询指令间隔
#define TIME_INTERVAL_FETCH_STATE 0.5

/// 产康设备前缀
#define DEVICE_NAME_PREFIX @"BLE"

///延迟连接时间
#define CONNECT_DELAY 3

///连接设备时间
#define CONNECT_TIME 30

///计算CRC16值用的一个参数
#define PLOY 0xA001

///蓝牙设备读写特征
//00000000000000000000000000001000
//00000000000000000000000000001001
//00000000000000000000000000001002
//00000000-0000-0000-0000-000000001001
//00000000-0000-0000-0000-000000001002
//00000000-0000-0000-0000-000000001003
#define SERVICE @"1000"
#define WRITE_CHARACTERISTIC @"1001"
#define READ_CHARACTERISTIC @"1002"


///型号和颜色
#define MODEL_1 @"PC-MD01"  //"11"
#define COLOR_1 @"银色"       //"11"

///log目录和相关文件名定义
#define LOG_DIR @"Logs"      //log文件夹目录名
#define LOG_COMMAND_FILE @"command.txt"     //发送接收指令的
#define LOG_EXCEPTION_FILE @"exception.txt"     //错误信息文件





#endif /* BTConstDefine_h */
