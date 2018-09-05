//
//  BTCommandDefine.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 指令集和指令参数定义
 
 **/

#ifndef BTCommandDefine_h
#define BTCommandDefine_h

#pragma - mark 指令枚举类型定义
/**
 指令优先级
 */
typedef NS_ENUM(NSInteger, CommandPriority)
{
    CommandPriorityHigh = 1000,    //高优先级，这个优先级的指令需要在队列中提前执行
    CommandPriorityDefault = 0,     //默认优先级，默认位置
    CommandPriorityLow = -1000      //低优先级，这个优先级的指令可以放到队列后面执行
};

/**
 错误或异常严重程度
 */
typedef NS_ENUM(NSInteger, BTExceptionSeverityRank)
{
    BTExceptionSeverityRankVeryHigh = 1000,         //非常高的严重程度，一般是蓝牙系统或设备发生了不可恢复的故障；进入异常界面并断开连接
    BTExceptionSeverityRankHigh = 100,        //错误严重程度高，需要特殊处理，可以通过弹框或者进入异常界面提示
    BTExceptionSeverityRankNormal = 0,         //一般严重程度，一般为指令级别的错误，可以通过弹框提示
    BTExceptionSeverityRankLow = -100,         //比较低的严重程度，可以以提醒的方式告知外部，比如电池电量低
    BTExceptionSeverityVeryLow = -1000      //非常低的严重程度，认为无异常，比如一切正常
};

/**
 指令枚举类型
 */
typedef NS_ENUM(NSInteger, CommandType) {
    /**
     无指令，如果出现这个值，说明有错误，需要debug
     */
    CommandType_None = 0x00,
    /**
     功能：查询从机信息；返回序列号、软硬件版本
     参数：设备类型；定义：CommandType_DeviceInfo_Key
     优先级：default
     */
    CommandType_DeviceInfo = 0x01,
    /**
     功能：查询从机状态；返回电池电量、电极信息、异常信息、工作状态运行模式；轮询指令
     参数：无
     优先级：default
     */
    CommandType_DeviceState = 0x02,
    /**
     功能：查询电刺激信息；返回运行状态、方案编号、电流强度调节标识、手法小编号、电流强度和运行时间；轮询指令
     参数：无
     优先级：default
     */
    CommandType_StimulatorInfo = 0x03,
    /**
     功能：进入电刺激设置初始化；返回成功或失败
     参数1:A通道选择
     参数2:A通道方案编号
     参数3:B通道选择
     参数4:B通道方案编号
     优先级：default
     */
    CommandType_StimulatorInitialization = 0x04,
    /**
     功能：查询手法大编号列表
     参数：无
     优先级：default
     */
    CommandType_BigNumber = 0x05,
    /**
     功能：设置界面电刺激强度调节
     参数1:通道选择
     参数2:手法大编号
     参数3:电流强度
     优先级：default
     */
    CommandType_AdjustStimulator_Setting = 0x06,
    /**
     功能：电刺激方案开始运行
     参数1：通道选择
     参数2:方案编号
     参数3:运行时间
     优先级：high
     */
    CommandType_StartStimulator = 0x07,
    /**
     功能：方案运行时电刺激电流调节
     参数1:通道选择
     参数2:方案编号
     参数3:手法小编号
     参数4:电流强度
     优先级：high
     */
    CommandType_AdjustStimulator_Running = 0x08,
    /**
     功能：电刺激控制，通道继续、暂停、停止
     参数1:bit7-4表示通道，0001-通道A，0010-通道B，0011-AB通道；bit3-0: 0001-电刺激停止，0010-电刺激暂停，0011-电刺激继续。
     优先级：high
     */
    CommandType_StimulatorControl = 0x09,
    /**
     功能：进入振动模式
     参数1:振动模式
     参数2:振动强度
     参数3:振动时间
     参数4:计时标志
     优先级：high
     */
    CommandType_VibartionMode = 0x0A,
    /**
     功能：振动模式和强度设置
     参数1:振动模式
     参数2:振动强度
     优先级：default
     */
    CommandType_VibartionMode_Setting = 0x0B,
    /**
     功能：振动控制
     参数1:启动或停止振动
     优先级：high
     */
    CommandType_VibartionControl = 0x0C,
    /**
     振动信息查询，从机返回振动模式 振动强度 振动时间给主机；轮询指令
     参数：无
     优先级：default
     */
    CommandType_VibartionInfo = 0x0D,
    /**
    功能：账号绑定高16字节
     参数1：UserID高16字节
     优先级：default
     */
    CommandType_BindID_High = 0x0E,
    /**
     功能：账号绑定低16字节
     参数1：UserID低16字节
     优先级：default
     */
    CommandType_BindID_Low = 0x0F,
    /**
     功能：查询从机账号是否授权
     参数1:UserID高16字节
     优先级：default
     */
    CommandType_AuthorizationState_High = 0x10,
    /**
     功能：查询从机账号是否授权
     参数1:UserID低16字节
     优先级：default
     */
    CommandType_AuthorizationState_Low = 0x11,
    /**
     功能：查询从机账号；嵌入式调试使用，app开发可不考虑
     参数：无
     优先级：low
     */
     CommandType_QueryUserID = 0x12,
     CommandType_QueryUserID_Low = 0x13,
    /**
     功能：清除从机账号；0x14   0x03   0x43   0x4C  0x52   0x50   0xAE
     参数1：“CLR”
     优先级：low
     */
    CommandType_ClearUserID = 0x14,
    /**
     功能：模式选择；0x01-运行模式（默认模式），0x02-老化模式。
     参数1：模式
     优先级：low
     */
    CommandType_ModeSelect = 0x15,
    /**
     功能：负压控制
     参数1:只有一个参数值：0x02（停止负压）
     优先级：high
     */
    CommandType_Pressure_Control = 0x17,
    /**
     功能：调节负压模式和强度
     参数1:模式；0x01-模式1（默认），0x02-模式2，0x03-模式3……，其它-无效
     参数2:强度；0x01-强度1（默认），0x02-强度2，0x03-强度3……，其它-无效
     优先级：default
     */
    CommandType_AdjustPressure = 0x18,
    /**
     功能：负压运行
     参数1:模式；0x01-模式1（默认），0x02-模式2，0x03-模式3……，其它-无效
     参数2:强度；0x01-强度1（默认），0x02-强度2，0x03-强度3……，其它-无效
     参数3:时间；负压运行时间，单位：秒。若时间为0时，正计时；不为0时，倒计时\
     参数4:计时标志；0x01:正计时；0x02:倒计时
     优先级：high
     */
    CommandType_StartPressure = 0x19,
    /**
     功能：负压查询
     参数1:无
     优先级：default
     */
    CommandType_PollingPressureInfo = 0x1A,
    /**
     功能：恢复出厂设置；0x30   0x02   0x46   0x52   0x1D   0x79
     参数1:“FR”
     优先级：low
     */
    CommandType_Reset = 0x30,
    /**
     功能：自动关机；0x31   0x02   0x50   0x44  0x93   0x2B
     参数1:“PD”
     优先级：low
     */
    CommandType_PowerDown = 0x31,
    /**
     功能：设备主动发送异常信息过来，不需要app主动发起
     */
    CommandType_ExceptionInfo = 0x33,
    /**
     功能：主动给设备发送异常信息，经过延时之后，设备会返回异常信息----------测试异常专用
     参数1：异常信息字段，和轮询获得的异常信息结构相同
     参数2：异常延时时间
     优先级：default
     */
    CommandType_SetException = 0x50
};

#pragma - mark 所有可用的指令参数定义
/**
 查询从机信息参数
 */
#define Parameter_DeviceInfo_Key @"Parameter_DeviceInfo_Key"    //查询从机信息参数key
#define Parameter_DeviceInfo_Value @"C-CK"            //查询从机信息参数value
/**
 进入电刺激设置初始化
 */
#define Parameter_Stimulator_Initialization_Channel_A_Key @"Parameter_Stimulator_Initialization_Channel_A_Key"      //初始化电刺激A通道选择
#define Parameter_Stimulator_Initialization_Channel_B_Key @"Parameter_Stimulator_Initialization_Channel_B_Key"      //初始化电刺激B通道选择
//通道是否选择
typedef NS_ENUM(NSInteger, Parameter_Stimulator_Initialization_Channel_Value) {
    Parameter_Stimulator_Initialization_Channel_Value_Off = 0x00,      //通道不选择
    Parameter_Stimulator_Initialization_Channel_Value_On = 0x01      //通道选择
};

#define Parameter_Stimulator_Plan_Key @"Parameter_Stimulator_Plan_Key"          //电刺激方案选择
#define Parameter_Stimulator_A_Plan_Key @"Parameter_Stimulator_A_Plan_Key"        //初始化电刺激A通道方案选择
#define Parameter_Stimulator_B_Plan_Key @"Parameter_Stimulator_B_Plan_Key"         //初始化电刺激B通道方案选择
#define Parameter_Stimulator_Plan_Value_None 0x00           //通道初始化不选择任何方案

/**
 设置界面电刺激强度调节
 */
#define Parameter_Channel_Key @"Parameter_Channel_Key"      //电刺激调节通道选择
typedef NS_ENUM(NSInteger, Parameter_Channel_Value) {
    Parameter_Channel_Value_A = 0x01,       //选择A通道
    Parameter_Channel_Value_B = 0x02,        //选择B通道
    Parameter_Channel_Value_AB = 0x03       //AB通道同时选择
};
#define Parameter_Big_Number_Key @"Parameter_Big_Number_Key"        //手法大编号参数key

#define Parameter_Setting_Electric_Intensity_Key @"Parameter_Stimulator_Electric_Intensity_Key"      //电流强度调节参数key
//电流强度档位
typedef NS_ENUM(NSInteger, Parameter_Setting_Electric_Intensity_Value) {
    Parameter_Setting_Electric_Intensity_Value_Reduce1 = 0x81,      //电流-1
    Parameter_Setting_Electric_Intensity_Value_Reduce2 = 0x82,      //电流-2
    Parameter_Setting_Electric_Intensity_Value_Reduce5 = 0x85,      //电流-5
    Parameter_Setting_Electric_Intensity_Value_Add1 = 0x41,      //电流+1
    Parameter_Setting_Electric_Intensity_Value_Add2 = 0x42,      //电流+2
    Parameter_Setting_Electric_Intensity_Value_Add5 = 0x45,      //电流+5
};
/**
 方案运行
 */
#define Parameter_Plan_Time_Key @"Parameter_Plan_Time_Key"      //方案运行时间参数key
#define Parameter_Small_Number_Key @"Parameter_Small_Number_Key"        //手法小编号key

#define Parameter_Running_Electric_Intensity_Key @"Parameter_Running_Electric_Intensity_Key"        //运行界面电刺激调节key
  //电流强度档位
typedef NS_ENUM(NSInteger, Parameter_Running_Electric_Intensity_Value) {
    Parameter_Running_Electric_Intensity_Value_Reduce = 0x80,      //电流-
    Parameter_Running_Electric_Intensity_Value_Add = 0x40,      //电流+
};
/**
 电刺激控制
 */
#define Parameter_Stimulator_Control_Key @"Parameter_Stimulator_Control_Key"        //运行界面电刺激控制参数key
typedef NS_ENUM(NSInteger, Parameter_Stimulator_Control_Value) {
    Parameter_Stimulator_Control_Value_AStop = 0x11,        //A通道停止
    Parameter_Stimulator_Control_Value_APause = 0x12,        //A通道暂停
    Parameter_Stimulator_Control_Value_AContinue = 0x13,        //A通道继续
    Parameter_Stimulator_Control_Value_BStop = 0x21,        //B通道停止
    Parameter_Stimulator_Control_Value_BPause = 0x22,        //B通道暂停
    Parameter_Stimulator_Control_Value_BContinue = 0x23,        //B通道继续
    Parameter_Stimulator_Control_Value_ABStop = 0x31,        //AB通道停止
    Parameter_Stimulator_Control_Value_ABPause = 0x32,        //AB通道暂停
    Parameter_Stimulator_Control_Value_ABContinue = 0x33,        //AB通道继续
};
/**
 进入振动模式
 */
//#define Parameter_VibartionMode_Key @"Parameter_VibartionMode_Key"      //进入退出振动模式参数key
////振动模式进入和退出
//typedef NS_ENUM(NSInteger, Parameter_VibartionMode_Value) {
//    Parameter_VibartionMode_Value_Enter = 0x01,     //进入振动模式
//    Parameter_VibartionMode_Value_Exit = 0x02           //退出振动模式
//};
#define Parameter_VibartionMode_Time_key @"Parameter_VibartionMode_Time_key"        //进入振动模式时间参数key，值是一个整数，单位：秒时间为0时，正计时；不为0时，倒计时
#define Parameter_VibartionMode_Time_Symbol_Key @"Parameter_VibartionMode_Time_Symbol_Key"      //进入振动模式时间标志key，0x01：正计时；0x02:倒计时
/**
 振动模式设置
 */
#define Parameter_VibartionMode_Setting_Key @"Parameter_Vibartion_Mode_Setting_Key"      //振动模式参数设置key
//振动模式参数
typedef NS_ENUM(NSInteger, Parameter_Vibartion_Mode_Setting_Value) {
    Parameter_Vibartion_Mode_Setting_Value_1 = 0x01,        //连续短震
    Parameter_Vibartion_Mode_Setting_Value_2 = 0x02,        //连续长震
    Parameter_Vibartion_Mode_Setting_Value_3 = 0x03,        //1次短震+1次长震
    Parameter_Vibartion_Mode_Setting_Value_4 = 0x04        //3次短震+2次长震
};
#define Parameter_Vibartion_Intensity_Setting_Key @"Parameter_Vibartion_Intensity_Setting_Key"      //振动强度参数设置key
//振动强度参数
 typedef NS_ENUM(NSInteger, Parameter_Vibartion_Intensity_Setting_Value) {
     Parameter_Vibartion_Intensity_Setting_Value_1 = 0x01,      //很弱    柔
     Parameter_Vibartion_Intensity_Setting_Value_2 = 0x02,      //较弱    轻
     Parameter_Vibartion_Intensity_Setting_Value_3 = 0x03,      //适中    中
     Parameter_Vibartion_Intensity_Setting_Value_4 = 0x04,       //较强   强
     Parameter_Vibartion_Intensity_Setting_Value_5 = 0x05       //极强    重
 };
/**
 振动控制
 */
#define Parameter_Vibartion_Control_Key @"Parameter_Vibartion_Control_Key"      //振动控制参数key
//振动控制参数
typedef NS_ENUM(NSInteger, Parameter_Vibartion_Control_Value) {
    Parameter_Vibartion_Control_Value_Start = 0x01,         //启动振动
    Parameter_Vibartion_Control_Value_End = 0x02            //停止振动
};
    ///振动计时标志
typedef NS_ENUM(NSInteger, Parameter_Vibartion_Timer_Symbol) {
    Parameter_Vibartion_Timer_Symbol_PlusTime = 0x01,     //正计时
    Parameter_Vibartion_Timer_Symbol_ReduceTime = 0x02     //倒计时
};
    ///振动运行状态
typedef NS_ENUM(NSInteger, Parameter_Vibartion_Running_Status) {
    Parameter_Vibartion_Running_Status_Running = 0x01,       //运行
    Parameter_Vibartion_Running_Status_Stop = 0x02       //停止
};
/**
 负压控制
 */
#define Parameter_Pressure_Control_Key @"Parameter_Pressure_Control_Key"        //负压控制参数key
typedef NS_ENUM(NSInteger, Parameter_Pressure_Control_Value) {
    Parameter_Pressure_Control_Value_Start = 0x01,       //开始负压
    Parameter_Pressure_Control_Value_Stop = 0x02       //停止负压
};
/**
 负压模式调节
 */
#define Parameter_Pressure_Mode_Key @"Parameter_Pressure_Mode_Key"      //负压调节模式参数key
//负压调节模式参数value
typedef NS_ENUM(NSInteger, Parameter_Pressure_Mode_Value) {
    Parameter_Pressure_Mode_Value_1 = 0x01,     //模式1:高频刺激
    Parameter_Pressure_Mode_Value_2 = 0x02,     //模式2:舒缓吸吮
    Parameter_Pressure_Mode_Value_3 = 0x03      //模式3:持续牵引
};
#define Parameter_Pressure_Strength_Key @"Parameter_Pressure_Strength_Key"      //负压调节力度参数key
//负压调节力度参数value
typedef NS_ENUM(NSInteger, Parameter_Pressure_Strength_Value) {
    Parameter_Pressure_Strength_Value_1 = 0x01,     //负压调节力度档位1
    Parameter_Pressure_Strength_Value_2 = 0x02,     //负压调节力度档位2
    Parameter_Pressure_Strength_Value_3 = 0x03,     //负压调节力度档位3
    Parameter_Pressure_Strength_Value_4 = 0x04,
    Parameter_Pressure_Strength_Value_5 = 0x05,
    Parameter_Pressure_Strength_Value_6 = 0x06,
    Parameter_Pressure_Strength_Value_7 = 0x07,
    Parameter_Pressure_Strength_Value_8 = 0x08,
    Parameter_Pressure_Strength_Value_9 = 0x09,
    Parameter_Pressure_Strength_Value_10 = 0x0A
};
#define Parameter_Pressure_Time_Key @"Parameter_Pressure_Time_Key"      //负压开始的时间参数，单位：秒。若时间为0时，正计时；不为0时，倒计时
#define Parameter_Pressure_Time_Symbol_Key @"Parameter_Pressure_Time_Symbol_Key"      //负压计时模式，正计时或者倒计时
///负压计时标志
typedef NS_ENUM(NSInteger, Parameter_Pressure_Timer_Symbol) {
    Parameter_Pressure_Timer_Symbol_PlusTime = 0x01,     //正计时
    Parameter_Pressure_Timer_Symbol_ReduceTime = 0x02     //倒计时
};
///负压运行状态
typedef NS_ENUM(NSInteger, Parameter_Pressure_Running_Status) {
    Parameter_Pressure_Running_Status_Running = 0x01,       //运行
    Parameter_Pressure_Running_Status_Stop = 0x02       //停止
};
/**
 绑定从机账号
 */
//绑定从机账号参数key，value为字符串，需要转换为16进制，字符串长度16个字节
#define Parameter_BindID_Key @"Parameter_BindID_Key"
/**
 查询从机账号是否授权
 */
//查询从机账号是否授权参数key，value为字符串，需要转换为16进制，字符串长度16个字节
#define Parameter_Authorization_State_Key @"Parameter_Authorization_State_Key"
/**
 模式选择，0x01-运行模式（默认模式），0x02-老化模式。
 */
#define Parameter_Mode_Select_Key @"Parameter_Mode_Select_Key"      //模式选择参数key
//模式选择参数
typedef NS_ENUM(NSInteger, Parameter_Mode_Select_Value) {
    Parameter_Mode_Select_Value_Running = 0x01,     //运行模式（默认）
    Parameter_Mode_Select_Value_Ageing = 0x02           //老化模式
};
/**
 主动发送异常信息给设备
 */
#define Parameter_Exception_Key @"Parameter_Exception_Key"      //主动发送异常信息的参数key
#define Parameter_Exception_Time_Key @"Parameter_Exception_Time_Key"        //主动发送异常信息的时间参数key，单位：秒

#pragma - mark 异常信息定义-BTException
///异常名称
#define BTExceptionName @"设备异常"

typedef NS_ENUM(NSInteger, BTCommandException) {
    BTException_No_Exception = 0x0000,          //无异常
    
    BTException_Inner_Storage_Error = 0x8001,       //bit15:  0-无内部存储错误，1-有内部存储错误
    BTException_Outer_Storage_Error = 0x8002,     //bit14：1-有外部存储错误
    BTException_Massage_Error = 0xC000,           //bit1：0-按摩正常，1-按摩异常
    BTException_Pump_Error = 0x8004,          //1：真空泵异常
    BTException_Tap_Error = 0x8008,           //1：电磁阀异常
    
    //bit2-4：通道B异常信息，000-电极正常
    BTException_Electorde_B_Unconnect = 0x9000,       //B通道电极未连接
    BTException_Electorde_B_Unmatch = 0x9800,     //B通道电极不匹配
    BTException_Electorde_B_Drop = 0xA000,                //B通道电极脱落
    BTException_Electorde_B_Stimulate_Error = 0x8800,     //B通道电刺激输出异常
    
    //bit5-7：通道A异常信息，000-电极正常
    BTException_Electorde_A_Unconnect = 0x8200,       //A通道电极未连接
    BTException_Electorde_A_Unmatch = 0x8300,     //A通道电极不匹配
    BTException_Electorde_A_Drop = 0x8400,                //A通道电极脱落
    BTException_Electorde_A_Stimulate_Error = 0x8100      //A通道电刺激输出异常
};
/**异常信息文本定义*/
#define BTException_NoException @"无异常"

#define BTException_InnerStorageError @"内部存储错误"
#define BTException_OuterStorageError @"外部存储错误"
#define BTException_PumpError @"真空泵异常"
#define BTException_TapError @"电磁阀异常"
#define BTException_MassageError @"按摩异常"
#define BTException_ElectordeBUnconnect @"B通道电极未连接"
#define BTException_ElectordeBUnmatch @"B通道电极不匹配"
#define BTException_ElectordeBDrop @"B通道电极脱落"
#define BTException_ElectordeBStimulateError @"B通道电刺激输出异常"
#define BTException_ElectordeAUnconnect @"A通道电极未连接"
#define BTException_ElectordeAUnmatch @"A通道电极不匹配"
#define BTException_ElectordeADrop @"A通道电极脱落"
#define BTException_ElectordeAStimulateError @"A通道电刺激输出异常"

#pragma - mark 指令返回状态码定义-BTError
typedef NS_ENUM(NSInteger, BTCommandStatus) {
    BTCommandStatus_OK = 0x00,      //状态正常
    BTCommandStatus_WaitFinish = 0x30,          //等待指令传送完成，比如绑定账号
    
    BTCommandStatus_CommandError = 0x01,       //指令错误
    BTCommandStatus_CRCError = 0x02,      //校验错误
    BTCommandStatus_ParamError = 0x03,      //参数错误
    BTCommandStatus_LengthError = 0x04,     //数据长度不正确
    BTCommandStatus_IllegalError = 0x05,        //非法操作
    BTCommandStatus_BindError = 0x06,       //从机绑定账号失败<存储错误>
    BTCommandStatus_BindTooMoreError = 0x07,    //从机绑定账号超过上限
    BTCommandStatus_AuthorizationError = 0x08,                   //从机账号未授权
    BTCommandStatus_BusyError = 0x09,               //从机忙
    BTCommandStatus_DeviceError = 0x0A,       //设备类型不匹配
    
    BTCommandStatus_TimeoutError = 0x0B,     //通信超时，自定义
    BTCommandStatus_NoData = 0x999          //解析不到数据，自定义
    
};
/**状态码文本定义*/
#define BTCommandStatusOK @"数据包正确"
#define BTCommandStatusWaitFinish @"指令等待传送完成"

#define BTCommandStatusCommandError @"控制指令不正确"
#define BTCommandStatusCRCError @"数据校验错误"
#define BTCommandStatusParamError @"发送的控制参数错误"
#define BTCommandStatusLengthError @"数据长度不符合"
#define BTCommandStatusIllegalError @"不具备执行条件的操作"      //非法操作
#define BTCommandStatusBindError @"账号绑定失败"
#define BTCommandStatusBindTooMoreError @"从机绑定账号超过上限"
#define BTCommandStatusAuthorizationError @"从机账号不存在"
#define BTCommandStatusBusyError @"从机忙状态，暂时无法响应指令请求，请稍后再试"
#define BTCommandStatusDeviceError @"APP和设备类型不匹配"
#define BTCommandStatusTimeoutError @"通信超时"
#define BTCommandStatusNoData @"没有解析到数据"



#pragma - mark 指令调用返回参数定义
///指令返回一个NSDictionary，包含如下参数
#define Command_Status @"Command_Status"        //指令返回状态定义，1为成功，0为失败
#define Command_objValue @"Command_objValue"            //指令如果成功，那么返回objValue中取得需要的数据(比如：设备信息等)
#define Command_Error @"Command_Error"          //指令如果失败，那么从error中取得错误信息(Error)

///电极类型
typedef NS_ENUM(NSInteger, BTElectrodeType) {
    BTElectrodeTypeUnknown,         //未连接电极00
    BTElectrodeTypeBreast,       //乳房电极01
    BTElectrodeTypeWomb         //子宫电极10
};

///电刺激状态
typedef NS_ENUM(NSInteger, BTStimulatorStatus) {
    BTStimulatorStatusRunning = 0x01,      //运行001
    BTStimulatorStatusPause = 0x03,           //暂停010
    BTStimulatorStatusStop = 0x02          //停止011
};

///工作状态
typedef NS_ENUM(NSInteger, BTDeviceWorkStatus) {
    BTDeviceWorkStatusFree = 0x00,      //空闲
    BTDeviceWorkStatusStimulatorSetting = 0x01,         //电刺激设置模式
    BTDeviceWorkStatusStimulatorRunning = 0x02,     //电刺激运行模式
    BTDeviceWorkStatusVibration = 0x03,          //振动模式
    BTDeviceWorkStatusPressure = 0x04,           //负压模式
    BTDeviceWorkStatusReset = 0x05         //复位模式，说明设备刚刚开机
};

///运行模式
typedef NS_ENUM(NSInteger, BTDeviceWorkMode) {
    BTDeviceWorkModeNormal = 0x01,      //正常运行模式
    BTDeviceWorkModeAgeing = 0x02           //老化模式
};




#endif /* BTCommandDefine_h */
