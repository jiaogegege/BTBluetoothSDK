# BTBluetoothSDK
DaYue's Products iOS App Bluetooth SDK.

#  BTBluetoothSDK用户手册
## 文件列表

### Const常量定义
1. `BTBluetoothSDK.h`     
*外部程序使用SDK时引入的头文件*
2. `BTCommandDefine.h`    
*SDK指令定义和指令参数定义*
3. `BTConstDefine.h`      
*SDK中使用的常量定义*

### Manager管理器类
1. `BTManager`      
*这个类是整个sdk的管理器，管理所有SDK中的任务执行，以及处理和外部程序的交互*
2. `BTBluetoothAdapter`     
*蓝牙适配器，封装系统蓝牙相关功能*
3. `BTTaskDispatcher`
*任务调度器，主要管理各个线程的任务调度*
4. `BTCommandContainer`
*指令和数据容器*
5. `BTCommandBuilder`
*指令构造器*
6. `BTDataParser`
*指令数据解析器*
7. `BTExceptionProcessor`
*异常处理器*
8. `BTLogRecorder`
*日志记录器*

### Tools工具集
1. `BTUtility`
*常用工具集*
2. `BTQueue`
*基础队列，先进先出*
3. `BTPriorityQueue`
*优先级队列，先进先出*
4. `BTVector`
*向量容器：顺序存储，支持随机存取*
5. `BTError`
*指令错误对象，包含指令错误状态码*
6. `BTException`
*异常对象，包含异常等级，异常状态码等*

### Models数据模型对象
1. `BTPeripheralModel`
*蓝牙外围设备对象*
2. `BTDeviceModel`
*蓝牙设备对象*
3. `BaseCommandModel`
*指令对象基础*
4. `SendCommandModel`
*发送指令对象*
5. `ReceivedCommandModel`
*接收到的指令对象*
6. `BTStimulatorInfoModel`
*电刺激信息*
7. `BigNumberInfoModel`
*大编号列表信息*
8. `VibrationInfoModel`
*振动信息*
9. `PressureInfoModel`
*负压信息*

## 功能详述

### BTBluetoothSDK.h
外部程序如果要使用SDK的相关功能，只需要引入这个头文件就可以，该文件中包含所有SDK相关功能和类的头文件。

### BTCommandDefine.h
该文件定义了所有可使用的指令集、指令集的可用参数列表、参数传递时使用的key关键字、参数所有可选值(大部分以枚举类型提供)、指令的优先级定义、指令所有状态码定义、系统异常信息定义、指令调用返回参数key关键字定义。

#### 指令枚举类型定义

- `CommandType_None = 0x00`
> 无指令，如果出现这个值，说明有错误，需要debug

- `CommandType_DeviceInfo = 0x01`
> 功能：查询从机信息；返回序列号、软硬件版本
参数：设备类型；定义：CommandType_DeviceInfo_Key
优先级：default

- `CommandType_DeviceState = 0x02`
> 功能：查询从机状态；返回电池电量、电极信息、异常信息、工作状态运行模式；轮询指令
参数：无
优先级：default

- `CommandType_StimulatorInfo = 0x03`
> 功能：查询电刺激信息；返回运行状态、方案编号、电流强度调节标识、手法小编号、电流强度和运行时间；轮询指令
参数：无
优先级：default

- `CommandType_StimulatorInitialization = 0x04`
> 功能：进入电刺激设置初始化；返回成功或失败
参数1:A通道选择
参数2:A通道方案编号
参数3:B通道选择
参数4:B通道方案编号
优先级：default

- `CommandType_BigNumber = 0x05`
> 功能：查询手法大编号列表
参数：无
优先级：default

- `CommandType_AdjustStimulator_Setting = 0x06`
> 功能：设置界面电刺激强度调节
参数1:通道选择
参数2:手法大编号
参数3:电流强度
优先级：default

- `CommandType_StartStimulator = 0x07`
> 功能：电刺激方案开始运行
参数1：通道选择
参数2:方案编号
参数3:运行时间
优先级：high

- `CommandType_AdjustStimulator_Running = 0x08`
> 功能：方案运行时电刺激电流调节
参数1:通道选择
参数2:方案编号
参数3:手法小编号
参数4:电流强度
优先级：high

- `CommandType_StimulatorControl = 0x09`
> 功能：电刺激控制，通道继续、暂停、停止
参数1:bit7-4表示通道，0001-通道A，0010-通道B，0011-AB通道；bit3-0: 0001-电刺激停止，0010-电刺激暂停，0011-电刺激继续。
优先级：high

- `CommandType_VibartionMode = 0x0A`
> 功能：进入振动模式
参数1:振动模式
参数2:振动强度
参数3:振动时间
参数4:计时标志
优先级：high

- `CommandType_VibartionMode_Setting = 0x0B`
> 功能：振动模式和强度设置
参数1:振动模式
参数2:振动强度
优先级：default

- `CommandType_VibartionControl = 0x0C`
> 功能：振动控制
参数1:启动或停止振动
优先级：high

- `CommandType_VibartionInfo = 0x0D`
> 振动信息查询，从机返回振动模式 振动强度 振动时间给主机；轮询指令
参数：无
优先级：default

- `CommandType_BindID_High = 0x0E`
> 功能：账号绑定高16字节
参数1：UserID高16字节
优先级：default

- `CommandType_BindID_Low = 0x0F`
> 功能：账号绑定低16字节
参数1：UserID低16字节
优先级：default

- `CommandType_AuthorizationState_High = 0x10`
> 功能：查询从机账号是否授权
参数1:UserID高16字节
优先级：default

- `CommandType_AuthorizationState_Low = 0x11`
> 功能：查询从机账号是否授权
参数1:UserID低16字节
优先级：default

- `CommandType_QueryUserID = 0x12`
`CommandType_QueryUserID_Low = 0x13`
> 功能：查询从机账号；嵌入式调试使用，app开发可不考虑
参数：无
优先级：low

- `CommandType_ClearUserID = 0x14`
> 功能：清除从机账号；0x14   0x03   0x43   0x4C  0x52   0x50   0xAE
参数1：“CLR”
优先级：low

- `CommandType_ModeSelect = 0x15`
> 功能：模式选择；0x01-运行模式（默认模式），0x02-老化模式。
参数1：模式
优先级：low

- `CommandType_Pressure_Control = 0x17`
> 功能：负压控制
参数1:只有一个参数值：0x02（停止负压）
优先级：high

- `CommandType_AdjustPressure = 0x18`
> 功能：调节负压模式和强度
参数1:模式；0x01-模式1（默认），0x02-模式2，0x03-模式3……，其它-无效
参数2:强度；0x01-强度1（默认），0x02-强度2，0x03-强度3……，其它-无效
优先级：default

- `CommandType_StartPressure = 0x19`
> 功能：负压运行
参数1:模式；0x01-模式1（默认），0x02-模式2，0x03-模式3……，其它-无效
参数2:强度；0x01-强度1（默认），0x02-强度2，0x03-强度3……，其它-无效
参数3:时间；负压运行时间，单位：秒。若时间为0时，正计时；不为0时，倒计时\
参数4:计时标志；0x01:正计时；0x02:倒计时
优先级：high

- `CommandType_PollingPressureInfo = 0x1A`
> 功能：负压查询
参数1:无
优先级：default

- `CommandType_Reset = 0x30`
> 功能：恢复出厂设置；0x30   0x02   0x46   0x52   0x1D   0x79
参数1:“FR”
优先级：low

- `CommandType_PowerDown = 0x31`
> 功能：自动关机；0x31   0x02   0x50   0x44  0x93   0x2B
参数1:“PD”
优先级：low

- `CommandType_ExceptionInfo = 0x33`
> 功能：设备主动发送异常信息过来，不需要app主动发起

- `CommandType_SetException = 0x50`
> 功能：主动给设备发送异常信息，经过延时之后，设备会返回异常信息----------测试异常专用
参数1：异常信息字段，和轮询获得的异常信息结构相同
参数2：异常延时时间
优先级：default

#### 指令参数定义

```objc
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
```

#### 指令优先级定义

```objc
/**
指令优先级
*/
typedef NS_ENUM(NSInteger, CommandPriority)
{
CommandPriorityHigh = 1000,    //高优先级，这个优先级的指令需要在队列中提前执行
CommandPriorityDefault = 0,     //默认优先级，默认位置
CommandPriorityLow = -1000      //低优先级，这个优先级的指令可以放到队列后面执行
};
```

#### 指令错误和异常信息定义

```objc
/**
异常严重程度
*/
typedef NS_ENUM(NSInteger, BTExceptionSeverityRank)
{
BTExceptionSeverityRankVeryHigh = 1000,         //非常高的严重程度，一般是蓝牙系统或设备发生了不可恢复的故障；进入异常界面并断开连接
BTExceptionSeverityRankHigh = 100,        //错误严重程度高，需要特殊处理，可以通过弹框或者进入异常界面提示
BTExceptionSeverityRankNormal = 0,         //一般严重程度，一般为指令级别的错误，可以通过弹框提示
BTExceptionSeverityRankLow = -100,         //比较低的严重程度，可以以提醒的方式告知外部，比如电池电量低
BTExceptionSeverityVeryLow = -1000      //非常低的严重程度，认为无异常，比如一切正常
};
```

```objc
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
```

```objc
///指令返回状态码定义-BTError
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
```

#### 指令调用返回值定义

```objc
///指令返回一个NSDictionary，包含如下参数
#define Command_Status @"Command_Status"        //指令返回状态定义，1为成功，0为失败
#define Command_objValue @"Command_objValue"            //指令如果成功，那么返回objValue中取得需要的数据(比如：设备信息等)
#define Command_Error @"Command_Error"          //指令如果失败，那么从error中取得错误信息(Error)
```

### BTConstDefine.h
该文件定义了SDK中使用的常量、预编译宏等。

- 设备连接状态：`BTDeviceState`
- 断开设备时是否需要重连：`BTBluetoothDisconnectWay`
- 蓝牙框架工作模式： `BTManagerWorkMode`
- 接收到的指令的类型：`ReceivedCommandType`
- 指令最大重试次数，3次：`MAX_RETRY_COUNT`
- 重试时间间隔：`RETRY_TIME_INTERVAL`
- 最大重连时间：`MAX_RETRY_TIME`
- 指令最大并发数：`MAX_COMMAND_CONCURRENCY`
- 发送指令间隔：`TIME_INTERVAL_FOR_SEND_COMMAND`
- 接收指令的间隔：`TIME_INTERVAL_FOR_RECEIVE_COMMAND`
- 轮询指令间隔：`TIME_INTERVAL_FETCH_STATE`
- 延迟连接时间：`CONNECT_DELAY`
- 连接设备时间：`CONNECT_TIME`
- 蓝牙设备读写特征：
`#define SERVICE @"1000"`
`#define WRITE_CHARACTERISTIC @"1001"`
`#define READ_CHARACTERISTIC @"1002"`
- 记录日志相关目录信息

### BTManager
这个类是整个sdk的管理器，主要功能：
1.连接蓝牙，断开蓝牙
2.接收蓝牙发送的数据和发送数据给蓝牙的中转站，sdk全局控制管理中心
3.单例类
4.提供外部程序控制蓝牙的接口和服务，比如发送指令给蓝牙，传出指令数据给外部程序
5.管理前后台线程控制，指令传输
6.指令和数据流入流出的通道
7.提供一组服务，以协议的形式供外部程序实现，服务主要包括各种轮询指令的返回结果，比如：设备信息、异常信息、蓝牙连接状态等
8.提供一组接口给外部程序调用，用于发送指令并回调指令执行结果，类似网络接口的形式

### BTBluetoothAdapter
蓝牙适配器，封装系统蓝牙相关功能
1.包括蓝牙连接、断开蓝牙
2.传输指令原始数据
3.设备连接状态更新

###  BTTaskDispatcher
任务调度器，主要管理各个线程的任务调度
1.发送指令线程，从外部程序发送的指令进入任务调度器进行指令对象生成，指令进入派遣容器，从派遣容器中按规则读取指令并发送给中心管理器
2.接收指令线程，从容器中读取接收到的指令对象，匹配已发送队列中的指令对象，匹配到后就删除这个已发送指令，并将接收指令进行解析
3.待发送指令通过这个被放到容器中
4.接收到的指令通过这里被放入容器中

### BTCommandContainer
指令和数据容器
1.所有的发送指令和接收指令都存放在这个地方
2.任务调度器开启发送和接收指令的线程，从容器中存储和读取指令和数据
3.提供发送指令队列，其中的指令有优先级，优先级高的指令先出队列
4.提供接收指令队列，接收到的指令放在这里，先进先出
5.提供已发送指令队列，已发送的指令放在这里，用于等待指令返回结果
6.只提供指令和数据的存储和删除，不参与任何数据的操作和解析工作

### BTCommandBuilder
指令构造器
1.从指令枚举类型中创建发送指令对象
2.从接收到的指令数据中创建已接收指令对象

### BTDataParser
指令数据解析器
1.用于解析蓝牙返回的数据
2.解析成功后，调用指令对象相应的block（success/failure），并传入解析后的数据。
3.如果指令状态码不正确，说明发生了错误，交给异常处理器解析出错误信息并返回一个错误对象
4.如果解析到了异常信息，那么调用代理方法将异常信息传出去

### BTExceptionProcessor
异常处理器
1.解析轮询中发现的异常信息，并返回一个异常对象
2.解析指令中发生的错误，并返回一个错误对象

### BTLogRecorder
Log记录器
1.记录SDK运行中的log，包括：
(1)发送接收指令，指令时间/指令数据
(2)
单例模式

### BTUtility
常用工具集，包括：

- 蓝牙二进制数据转换相关方法
- 线程相关方法，比如开启子线程，回到主线程等
- 字符串判空、清除头尾空格等方法
- CRC校验相关方法
- 取字节相关方法
- 二进制/NSData/NSString/十六进制相关转换方法
- 获取系统时间

### BTQueue
 基础队列，先进先出
 
 ```objc
 /**容器方法*/
 ///追加一个元素到容器尾部
 -(void)push:(id)obj;
 
 ///弹出最前面一个元素，弹出后该元素不再存在容器中，如果没有元素则返回nil
 -(id)pop;
 
 ///获得容器最前面的元素，元素还在容器中
 -(id)firstObject;
 
 ///判断容器是否为空
 -(BOOL)isEmpty;
 
 ///清空容器
 -(void)clear;
 ```
 
### BTPriorityQueue
指令优先级队列
发送指令定制版容器，包含高中低3个优先级，如果没有指定优先级，就存放到父类容器中
 
### BTVector
向量容器：序列存储
1.可以返回头尾元素，有一个指针可以移动用来操作容器中的元素
2.在头尾都可添加元素，一般在尾部添加

```objc
 ///在头部添加一个元素
 -(void)pushFront:(id)obj;
 
 ///在尾部添加一个元素
 -(void)pushBack:(id)obj;
 
 ///返回头部元素，元素还在容器中，不存在返回nil
 -(id)firstObject;
 
 ///返回尾部元素，元素还在容器中，不存在返回nil
 -(id)lastObject;
 
 ///返回index的元素，元素还在容器中
 -(id)objectAtIndex:(NSInteger)index;
 
 ///弹出头部元素，元素不在容器中
 -(id)popFirst;
 
 ///弹出尾部元素，元素不在容器中
 -(id)popLast;
 
 ///弹出index的某个元素，元素不在容器中，如果index的元素不存在，返回nil
 -(id)popAtIndex:(NSInteger)index;
 
 ///弹出某个元素，返回YES，元素不在容器中，如果元素不存在容器中，返回NO
 -(BOOL)pop:(id)obj;
 
 ///获得下一个元素，元素还在容器中，如果index超过容器最大范围或容器为空，返回nil，并自动返回容器头部，返回当前index成功后index再+1
 -(id)next;
 
 ///重置指针为容器头部元素，index为0
 -(void)moveToFront;
 
 ///获得元素在容器中的index，不存在返回-1
 -(NSInteger)indexOfObject:(id)obj;
 
 ///判断容器是否为空
 -(BOOL)isEmpty;
 
 ///获得元素个数
 -(NSInteger)count;
 
 ///清空容器
 -(void)clear;
```
 
### BTError
指令错误对象，包含指令错误状态码
 
### BTException
异常对象，包含异常等级，异常状态码等
 
### BTPeripheralModel
蓝牙外围设备对象，包括设备id、设备名称等信息，用于显示蓝牙搜索时设备选择
  
### BTDeviceModel
继承自`BTPeripheralModel`
蓝牙设备对象，包括设备id、设备名称、设备电量、设备型号等信息
   
### BaseCommandModel
指令对象基础，定义指令对象的一些通用属性和方法

```objc
/**
指令返回成功的回调
参数1:指令类型
参数2:传给回调对象的数据，一般指令成功的话，object为true，附带上一些信息，比如设备信息、电极信息、状态查询数据等；还会返回异常信息
可用参数key：
"Command_Status"：1成功，0有异常
"Command_objValue"：数据对象，如果有的话
"Command_Error"：异常对象
*/
typedef void(^CommandSuccessBlock)(CommandType commandType, NSDictionary *object);
```

```objc
/**
指令失败的回调
参数1:指令类型
参数2:指令回调的数据，一般为错误对象
参数2:错误信息。如果接收指令中有任何错误码出现，那么调用失败的回调
*/
typedef void(^CommandFailureBlock)(CommandType commandType, BTError *error);
```

```objc
/**
指令枚举类型
*/
@property(nonatomic, assign, readonly)CommandType commandEnumFormat;
/**
指令字符串格式，包含完整的指令格式，16进制字符串格式
*/
@property(nonatomic, copy, readonly)NSString *commandStringFormat;
/**
指令二进制格式，包含完整的指令格式Byte数组
*/
@property(nonatomic, strong, readonly)NSData *commandDataFormat;
/**
指令成功的回调
*/
@property(nonatomic, copy, readonly)CommandSuccessBlock success;
/**
指令失败的回调
*/
@property(nonatomic, copy, readonly)CommandFailureBlock failure;
```

### SendCommandModel
发送出去的指令对象
继承自`BaseCommandModel`
定义了一些发送指令才会有的属性和方法

```objc
/**
重试的回调，3次重试的回调会传入新复制的发送指令对象，这个对象仅用于重试发送指令，不保存到已发送队列中，没有任何回调，这个对象希望直接被发送出去，该block在启动定时器时由任务派发器赋值
*/
typedef void(^CommandRetryBlock)(CommandType commandType, SendCommandModel *retryCommand);

/**
3次重试失败后的回调，一般是告知外部代码重试失败，然后断开蓝牙连接，该block在启动定时器时被赋值
参数1:指令类型
参数2:指令错误信息，固定为通信超时错误
*/
typedef void(^CommandRetryFailureBlock)(CommandType commandType, BTError *error);
```

```objc
/**
指令获得的参数
*/
@property(nonatomic, strong, readonly)NSDictionary *parameters;
/**
指令的优先级
*/
@property(nonatomic, assign, readonly)CommandPriority priority;
/**
指令是否需要回复，如果需要回复，那么要被放到已发送队列中等待回应并执行相应的block；如果不需要回应，说明是重试指令，发送后直接丢弃
*/
@property(nonatomic, assign, readonly)BOOL needResponse;

/**
重试的block
*/
@property(nonatomic, copy, readonly)CommandRetryBlock retry;
/**
3次重试失败的block
*/
@property(nonatomic, copy, readonly)CommandRetryFailureBlock retryFailure;


/**
初始化方法：初始化一个新指令对象
参数1:指令枚举类型
参数2:指令获得的参数
参数3:指令字符串格式
参数4:指令二进制格式
参数5:指令优先级
参数6:指令成功的回调
参数7:指令失败的回调
参数8:是否需要回复
*/
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure response:(BOOL)response;

/**
初始化方法：初始化一个重试指令对象
参数1:指令类型
参数2:指令获得的参数
参数3:指令字符串类型
参数4:指令二进制格式
参数5:指令优先级
参数6:指令是否需要回复，一般传NO
*/
-(instancetype)initWithEnumFormat:(CommandType)type parameters:(NSDictionary *)parameters stringFormat:(NSString *)string dataFormat:(NSData *)data priority:(CommandPriority)priority response:(BOOL)noResponse;

/**
启动指令倒计时
*/
-(void)startTimerWithRetry:(CommandRetryBlock)retry retryFailure:(CommandRetryFailureBlock)retryFailure;

/**
结束定时器，外部也有调用的需要
*/
-(void)stopTimer;

/**
匹配接收到的指令，如果和属性中的枚举类型匹配，那么取消3次重试定时器，说明这个指令获得了回复
返回值：参数bool，true为匹配成功
*/
-(BOOL)confirmReceivedCommand:(BaseCommandModel *)receivedCommand;
```

### ReceivedCommandModel
接收到的指令对象

```objc
/**
指令类型，标明该指令的具体类型，比如：数据指令/控制指令/设备主动发起的指令/等待回复的指令
*/
@property(nonatomic, assign, readonly)ReceivedCommandType receivedType;


/**
初始化方法，初始化一个接收指令对象
*/
-(instancetype)initWithEnumFormat:(CommandType)type stringFormat:(NSString *)string dataFormat:(NSData *)data receivedType:(ReceivedCommandType)receivedType success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure;

/**
获得回调block的方法
返回值：true，赋值成功；false，赋值失败
*/
-(BOOL)getCallbackCommand:(BaseCommandModel *)sendCommand;
```

### Models
这些模型对象都是根据具体的蓝牙通信需求定义好的，在不同的通信需求下，这些模型对象会不一样，需要自定义。
- 电刺激信息：`BTStimulatorInfoModel`
- 电刺激初始化时候大编号的信息：`BigNumberInfoModel`
-  振动信息：`VibrationInfoModel`
- 负压信息：`PressureInfoModel`

## SDK结构和工作流程
![模块结构图](https://github.com/jiaogegege/BTBluetoothSDK/blob/master/BTBluetoothSDK/Docs/SDK%E6%A8%A1%E5%9D%97%E8%AE%BE%E8%AE%A1.png "SDK模块结构图")

### 工作流程
`BTManager`是整个SDK的入口，`BTManager`被初始化的时候，同时初始化所有相关的Manager类型对象，包括：`BTBluetoothAdapter`、`BTTaskDispatcher`、`BTCommandContainer`、`BTCommandBuilder`、`BTDataParser`、`BTExceptionProcessor`、`BTLogRecorder`。  

当外部程序发起搜索和连接蓝牙的请求的时候，`BTManager`调用`BTBluetoothAdapter`的方法和系统蓝牙进行交互，并将交互结果返回给外部程序，比如搜索到设备，连接上蓝牙等。连接蓝牙有30s的时间，关于连接上蓝牙的判断需要满足以下条件：(1)设备连接到蓝牙；(2)搜索到服务和特征；(3)发送查询从机信息指令返回成功。如果其中任何一个条件不满足就认为这次连接失败，断开蓝牙连接并且不自动重连。

设备连接成功后，`BTManager`调用`BTTaskDispatcher`的开始工作方法，让`BTTaskDispatcher`开始运转起来。`BTTaskDispatcher`创建两条子线程，一条接收子线程，一条发送子线程；发送子线程不停从容器对象中取待发送指令对象，然后交给`BTManager`去发送，`BTManager`会将指令数据交给`BTBluetoothAdapter`最终发送出去；发送完一条指令后，将发送指令放入已发送队列中，发送线程休息一定时间，防止CPU占用过高，然后发送下一条指令。接收子线程不停从容器对象中取已接收指令对象，然后和已发送队列中的指令匹配，如果匹配到对应的指令则获取发送指令的成功和失败回调，然后开始解析接收指令，解析到数据后调用成功或失败的回调，最终将结果传给外部程序。如果解析到异常，那么告知`BTManager`，`BTManager`再告知外部程序，外部程序可以进行界面上的处理。在异常过程中，轮询和线程并不会停止，因为SDK认为程序并没有发生错误，并且异常是人为定义的，具体的处理方法需要交给外部程序处理，SDK只做桥梁的作用。  

`BTManager`主动发起轮询请求，并维持请求不停更新。到目前为止，设备连接成功，并且开始正常工作。发送指令从外部程序进入`BTManager`，然后进入`BTTaskDispatcher`，再进入`BTCommandContainer`，然后通过发送子线程进入`BTTaskDispatcher`，在进入`BTManager`，然后进入`BTBluetoothAdapter`，最终被发送给蓝牙设备。接收指令从系统蓝牙进入`BTBluetoothAdapter`，然后进入`BTManager`，然后进入`BTTaskDispatcher`，再进入`BTCommandContainer`，接着通过接收子线程进入`BTTaskDispatcher`，然后进入`BTDataParser`，最后通过block回调返回结果到调用指令的地方，一般是外部程序。

发送指令被发送之后，会开启一个定时器，500ms检查一次，如果定时器还没有被取消，那么就执行一次重试的block，如果执行完3次重试block之后该指令还是没有被匹配到，那么认为这条指令超时，就执行超时的block，`BTManager`会自动断开蓝牙连接并自动尝试重新连接。

目前根据需求同时并发的指令条数为1条，已经写入并发多条指令的机制，可修改参数来实现多指令并发执行。

整个SDK中，大部分Manager类型的对象是固定的，包括(`BTManager`、`BTBluetoothAdapter`、`BTTaskDispatcher`、`BTCommandContainer`)，控制整个SDK的运行流程和数据存储，具有通用性，容器也可以复用，指令对象也可以复用，数据模型对象应根据具体的需求定义。其中`BTCommandBuilder`、`BTDataParser`、`BTExceptionProcessor`是根据具体的项目需求自定义的，因为其中涉及指令定义和解析，具体的指令格式要根据通讯协议中定义好的需求设计。

**以上**


