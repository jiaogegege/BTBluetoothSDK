//
//  BTCommandBuilder.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTCommandBuilder.h"
#import "BTUtility.h"


@implementation BTCommandBuilder

static BTCommandBuilder *_instance = nil;
/**
 获取单例方法
 */
+(BTCommandBuilder *)builder
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    });
    return _instance ;
}

///初始化方法


/**
 创建一个发送指令对象
 */
-(SendCommandModel *)buildSendCommand:(CommandType)type parameters:(NSDictionary *)parameters success:(CommandSuccessBlock)success failure:(CommandFailureBlock)failure
{
    NSData *dataFormat = [self buildDataCommandWithType:type parameters:parameters];
    NSString *stringFormat = [BTUtility convertDataToHexStr:dataFormat];
    SendCommandModel *model = [[SendCommandModel alloc] initWithEnumFormat:type parameters:parameters stringFormat:stringFormat dataFormat:dataFormat priority:[self getCommandPriority:type] success:success failure:failure response:YES];
    return model;
}

/**
 创建一个接收指令对象
 */
-(ReceivedCommandModel *)buildReceivedCommand:(NSData *)data
{
    NSString *stringFormat = [BTUtility convertDataToHexStr:data];
    CommandType type = [self getCommandTypeWithData:data];
    if (type != CommandType_None)
    {
        ReceivedCommandType commandType = [self getReceivedCommandTypeWithCommandType:type];
        ReceivedCommandModel *model = [[ReceivedCommandModel alloc] initWithEnumFormat:type stringFormat:stringFormat dataFormat:data receivedType:commandType success:nil failure:nil];
        return model;
    }
    else
    {
        return nil;
    }
}

///获取指令优先级
-(CommandPriority)getCommandPriority:(CommandType)type
{
    CommandPriority priority;
    switch (type)
    {
        case CommandType_DeviceInfo:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_DeviceState:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_StimulatorInfo:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_StimulatorInitialization:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_BigNumber:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_AdjustStimulator_Setting:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_StartStimulator:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_AdjustStimulator_Running:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_StimulatorControl:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_VibartionMode:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_VibartionMode_Setting:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_VibartionControl:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_VibartionInfo:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_BindID_High:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_BindID_Low:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_AuthorizationState_High:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_AuthorizationState_Low:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_QueryUserID:
        {
            priority = CommandPriorityLow;
            break;
        }
        case CommandType_ClearUserID:
        {
            priority = CommandPriorityLow;
            break;
        }
        case CommandType_ModeSelect:
        {
            priority = CommandPriorityLow;
            break;
        }
        case CommandType_Pressure_Control:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_AdjustPressure:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_StartPressure:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_PollingPressureInfo:
        {
            priority = CommandPriorityDefault;
            break;
        }
        case CommandType_Reset:
        {
            priority = CommandPriorityLow;
            break;
        }
        case CommandType_PowerDown:
        {
            priority = CommandPriorityLow;
            break;
        }
        case CommandType_ExceptionInfo:
        {
            priority = CommandPriorityHigh;
            break;
        }
        case CommandType_SetException:
        {
            priority = CommandPriorityDefault;
            break;
        }
        default:
        {
            priority = CommandPriorityDefault;
            break;
        }
    }
    return priority;
}

///根据指令类型构建指令的NSData格式
-(NSData *)buildDataCommandWithType:(CommandType)type parameters:(NSDictionary *)parameters
{
    NSMutableData *data = [[NSMutableData alloc] init];
    //获得第一个字节
    [data appendData:[self getFirstByteWithCommandType:type]];
    //获得参数字节（中间数据），包括长度字节
    [data appendData:[self getParametersData:parameters commandType:type]];
    //获得CRC字节（两个字节）
    [data appendData:[BTUtility getCRC16:[data copy] length:data.length]];
    return [data copy];
}

///根据指令类型获取指令第一个字节的值
-(NSData *)getFirstByteWithCommandType:(CommandType)type
{
    return [BTUtility ucharToData:(Byte)type];
}

///获得中间字节（参数字节），包括长度字节
-(NSData *)getParametersData:(NSDictionary *)parameters commandType:(CommandType)type
{
    switch (type)
    {
        case CommandType_DeviceInfo:        //查询从机信息
        {
            Byte bytes[] = {0x04, 0x43, 0x2D, 0x43, 0x4B};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_DeviceState:       //查询从机状态
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_StimulatorInfo:       //查询电刺激信息
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_StimulatorInitialization:       //进入电刺激设置初始化
        {
            Byte bytes[] = {0x04, 0x00, 0x00, 0x00, 0x00};
            //A通道
            bytes[1] = (Byte)[parameters[Parameter_Stimulator_Initialization_Channel_A_Key] unsignedCharValue];
            bytes[2] = (Byte)[parameters[Parameter_Stimulator_A_Plan_Key] unsignedCharValue];
            //B通道
            bytes[3] = (Byte)[parameters[Parameter_Stimulator_Initialization_Channel_B_Key] unsignedCharValue];
            bytes[4] = (Byte)[parameters[Parameter_Stimulator_B_Plan_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_BigNumber:       //查询手法大编号
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_AdjustStimulator_Setting:       //电刺激频率脉宽电流调节
        {
            Byte bytes[] = {0x04, 0x00, 0x00, 0x00, 0x00};
            //通道号
            bytes[1] = (Byte)[parameters[Parameter_Channel_Key] unsignedCharValue];
            //手法大编号
            bytes[2] = [BTUtility getDoubleByteLow:[parameters[Parameter_Big_Number_Key] integerValue]];
            bytes[3] = [BTUtility getDoubleByteHigh:[parameters[Parameter_Big_Number_Key] integerValue]];
            //电流强度
            bytes[4] = (Byte)[parameters[Parameter_Setting_Electric_Intensity_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_StartStimulator:       //电刺激方案开始运行
        {
            Byte bytes[] = {0x03, 0x00, 0x00, 0x00};
            //通道号
            bytes[1] = (Byte)[parameters[Parameter_Channel_Key] unsignedCharValue];
            //方案编号
            bytes[2] = (Byte)[parameters[Parameter_Stimulator_Plan_Key] unsignedCharValue];
            //运行时间，是一个数字字符串
            bytes[3] = (Byte)[parameters[Parameter_Plan_Time_Key] integerValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_AdjustStimulator_Running:       //方案运行时电刺激电流调节
        {
            Byte bytes[] = {0x05, 0x00, 0x00, 0x00, 0x00, 0x00};
                //通道号
            bytes[1] = (Byte)[parameters[Parameter_Channel_Key] unsignedCharValue];
            //方案编号
            bytes[2] = (Byte)[parameters[Parameter_Stimulator_Plan_Key] unsignedCharValue];
            //手法小编号
            bytes[3] = [BTUtility getDoubleByteLow:[parameters[Parameter_Small_Number_Key] integerValue]];
            bytes[4] = [BTUtility getDoubleByteHigh:[parameters[Parameter_Small_Number_Key] integerValue]];
            //电流强度
            bytes[5] = (Byte)[parameters[Parameter_Running_Electric_Intensity_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_StimulatorControl:       //电刺激控制
        {
            Byte bytes[] = {0x01, 0x00};
                //通道号和控制参数
            bytes[1] = (Byte)[parameters[Parameter_Stimulator_Control_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_VibartionMode:       //进入振动模式
        {
            Byte bytes[] = {0x05, 0x00, 0x00, 0x00, 0x00, 0x00};
            //振动模式
            bytes[1] = (Byte)[parameters[Parameter_VibartionMode_Setting_Key] unsignedCharValue];
            //振动强度
            bytes[2] = (Byte)[parameters[Parameter_Vibartion_Intensity_Setting_Key] unsignedCharValue];
            //振动时间
            bytes[3] = [BTUtility getDoubleByteLow:[parameters[Parameter_VibartionMode_Time_key] integerValue]];
            bytes[4] = [BTUtility getDoubleByteHigh:[parameters[Parameter_VibartionMode_Time_key] integerValue]];
            //计时标志
            bytes[5] = (Byte)[parameters[Parameter_VibartionMode_Time_Symbol_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_VibartionMode_Setting:       //振动模式强度设置
        {
            Byte bytes[] = {0x02, 0x00, 0x00};
                //振动模式
            bytes[1] = (Byte)[parameters[Parameter_VibartionMode_Setting_Key] unsignedCharValue];
            //振动强度
            bytes[2] = (Byte)[parameters[Parameter_Vibartion_Intensity_Setting_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_VibartionControl:       //振动控制
        {
            Byte bytes[] = {0x01, 0x00};
                //振动模式
            bytes[1] = (Byte)[parameters[Parameter_Vibartion_Control_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_VibartionInfo:       //振动信息查询
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_BindID_High:       //账号绑定高16字节
        {
            Byte bytes[] = {0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            NSData *strData = [BTUtility convertStringToData:parameters[Parameter_BindID_Key]];
            Byte *strBytes = (Byte *)[strData bytes];
            for (int i = 0; i < strData.length; ++i)
            {
                bytes[i + 1] = strBytes[i];
            }
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_BindID_Low:       //账号绑定低16字节
        {
            Byte bytes[] = {0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            NSData *strData = [BTUtility convertStringToData:parameters[Parameter_BindID_Key]];
            Byte *strBytes = (Byte *)[strData bytes];
            for (int i = 0; i < strData.length; ++i)
            {
                bytes[i + 1] = strBytes[i];
            }
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_AuthorizationState_High:       //查询从机账号是否授权高16字节
        {
            Byte bytes[] = {0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            NSData *strData = [BTUtility convertStringToData:parameters[Parameter_Authorization_State_Key]];
            Byte *strBytes = (Byte *)[strData bytes];
            for (int i = 0; i < strData.length; ++i)
            {
                bytes[i + 1] = strBytes[i];
            }
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_AuthorizationState_Low:       //查询从机账号是否授权低16字节
        {
            Byte bytes[] = {0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            NSData *strData = [BTUtility convertStringToData:parameters[Parameter_Authorization_State_Key]];
            Byte *strBytes = (Byte *)[strData bytes];
            for (int i = 0; i < strData.length; ++i)
            {
                bytes[i + 1] = strBytes[i];
            }
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_QueryUserID:       //查询从机账号
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_ClearUserID:       //清除从机账号
        {
            Byte bytes[] = {0x03, 0x43, 0x4C, 0x52};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_ModeSelect:       //模式选择
        {
            Byte bytes[] = {0x01, 0x00};
            bytes[1] = (Byte)[parameters[Parameter_Mode_Select_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_Pressure_Control:      //负压控制
        {
            Byte bytes[] = {0x01, 0x00};
            bytes[1] = (Byte)[parameters[Parameter_Pressure_Control_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_AdjustPressure:        //负压参数调节
        {
            {
                Byte bytes[] = {0x02, 0x00, 0x00};
                bytes[1] = (Byte)[parameters[Parameter_Pressure_Mode_Key] unsignedCharValue];       //模式
                bytes[2] = (Byte)[parameters[Parameter_Pressure_Strength_Key] unsignedCharValue];       //力度
                return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
                break;
            }
        }
        case CommandType_StartPressure:        //开始负压运行
        {
            {
                Byte bytes[] = {0x05, 0x00, 0x00, 0x00, 0x00, 0x00};
                bytes[1] = (Byte)[parameters[Parameter_Pressure_Mode_Key] unsignedCharValue];       //模式
                bytes[2] = (Byte)[parameters[Parameter_Pressure_Strength_Key] unsignedCharValue];       //力度
                //时间
                bytes[3] = [BTUtility getDoubleByteLow:[parameters[Parameter_Pressure_Time_Key] integerValue]];
                bytes[4] = [BTUtility getDoubleByteHigh:[parameters[Parameter_Pressure_Time_Key] integerValue]];
                //计时标志
                bytes[5] = (Byte)[parameters[Parameter_Pressure_Time_Symbol_Key] unsignedCharValue];
                return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
                break;
            }
        }
        case CommandType_PollingPressureInfo:       //负压查询
        {
            Byte bytes[] = {0x00};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_Reset:       //恢复出厂设置
        {
            Byte bytes[] = {0x02, 0x46, 0x52};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_PowerDown:       //自动关机
        {
            Byte bytes[] = {0x02, 0x50, 0x44};
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        case CommandType_SetException:      //主动发送异常信息给设备
        {
            Byte bytes[] = {0x03, 0x00, 0x00, 0x00};
            //异常信息
            bytes[1] = [BTUtility getDoubleByteLow:[parameters[Parameter_Exception_Key] integerValue]];
            bytes[2] = [BTUtility getDoubleByteHigh:[parameters[Parameter_Exception_Key] integerValue]];
            //延时时间，单位：秒
            bytes[3] = (Byte)[parameters[Parameter_Exception_Time_Key] unsignedCharValue];
            return [NSData dataWithBytes:bytes length:(sizeof(bytes) / sizeof(Byte))];
            break;
        }
        default:
        {
            return [NSData data];
            break;
        }
    }
}

///根据指令的二进制格式得到指令的类型
-(CommandType)getCommandTypeWithData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    Byte byte = (Byte)(bytes[0]);
    switch (byte)
    {
        case 0x01:
        {
            return CommandType_DeviceInfo;
            break;
        }
        case 0x81:
        {
            return CommandType_DeviceInfo;
            break;
        }
        case 0x02:
        {
            return CommandType_DeviceState;
            break;
        }
        case 0x82:
        {
            return CommandType_DeviceState;
            break;
        }
        case 0x03:
        {
            return CommandType_StimulatorInfo;
            break;
        }
        case 0x83:
        {
            return CommandType_StimulatorInfo;
            break;
        }
        case 0x04:
        {
            return CommandType_StimulatorInitialization;
            break;
        }
        case 0x84:
        {
            return CommandType_StimulatorInitialization;
            break;
        }
        case 0x05:
        {
            return CommandType_BigNumber;
            break;
        }
        case 0x85:
        {
            return CommandType_BigNumber;
            break;
        }
        case 0x06:
        {
            return CommandType_AdjustStimulator_Setting;
            break;
        }
        case 0x86:
        {
            return CommandType_AdjustStimulator_Setting;
            break;
        }
        case 0x07:
        {
            return CommandType_StartStimulator;
            break;
        }
        case 0x87:
        {
            return CommandType_StartStimulator;
            break;
        }
        case 0x08:
        {
            return CommandType_AdjustStimulator_Running;
            break;
        }
        case 0x88:
        {
            return CommandType_AdjustStimulator_Running;
            break;
        }
        case 0x09:
        {
            return CommandType_StimulatorControl;
            break;
        }
        case 0x89:
        {
            return CommandType_StimulatorControl;
            break;
        }
        case 0x0A:
        {
            return CommandType_VibartionMode;
            break;
        }
        case 0x8A:
        {
            return CommandType_VibartionMode;
            break;
        }
        case 0x0B:
        {
            return CommandType_VibartionMode_Setting;
            break;
        }
        case 0x8B:
        {
            return CommandType_VibartionMode_Setting;
            break;
        }
        case 0x0C:
        {
            return CommandType_VibartionControl;
            break;
        }
        case 0x8C:
        {
            return CommandType_VibartionControl;
            break;
        }
        case 0x0D:
        {
            return CommandType_VibartionInfo;
            break;
        }
        case 0x8D:
        {
            return CommandType_VibartionInfo;
            break;
        }
        case 0x0E:
        {
            return CommandType_BindID_High;
            break;
        }
        case 0x8E:
        {
            return CommandType_BindID_High;
            break;
        }
        case 0x0F:
        {
            return CommandType_BindID_Low;
            break;
        }
        case 0x8F:
        {
            return CommandType_BindID_Low;
            break;
        }
        case 0x10:
        {
            return CommandType_AuthorizationState_High;
            break;
        }
        case 0x90:
        {
            return CommandType_AuthorizationState_High;
            break;
        }
        case 0x11:
        {
            return CommandType_AuthorizationState_Low;
            break;
        }
        case 0x91:
        {
            return CommandType_AuthorizationState_Low;
            break;
        }
        case 0x12:
        {
            return CommandType_QueryUserID;
            break;
        }
        case 0x92:
        {
            return CommandType_QueryUserID;
            break;
        }
        case 0x13:
        {
            return CommandType_QueryUserID_Low;
        }
        case 0x93:
        {
            return CommandType_QueryUserID_Low;
        }
        case 0x14:
        {
            return CommandType_ClearUserID;
            break;
        }
        case 0x94:
        {
            return CommandType_ClearUserID;
            break;
        }
        case 0x15:
        {
            return CommandType_ModeSelect;
            break;
        }
        case 0x97:
        {
            return CommandType_Pressure_Control;
            break;
        }
        case 0x98:
        {
            return CommandType_AdjustPressure;
            break;
        }
        case 0x99:
        {
            return CommandType_StartPressure;
            break;
        }
        case 0x1A:
        {
            return CommandType_PollingPressureInfo;
            break;
        }
        case 0x9A:
        {
            return CommandType_PollingPressureInfo;
            break;
        }
        case 0x95:
        {
            return CommandType_ModeSelect;
            break;
        }
        case 0x30:
        {
            return CommandType_Reset;
            break;
        }
        case 0xB0:
        {
            return CommandType_Reset;
            break;
        }
        case 0x31:
        {
            return CommandType_PowerDown;
            break;
        }
        case 0xB1:
        {
            return CommandType_PowerDown;
            break;
        }
        case 0x33:
        {
            return CommandType_ExceptionInfo;
            break;
        }
        case 0xD0:
        {
            return CommandType_SetException;
        }
        default:
        {
            return CommandType_None;
            break;
        }
    }
}

///根据指令的标签获得指令的类型
-(ReceivedCommandType)getReceivedCommandTypeWithCommandType:(CommandType)type
{
    switch (type) {
        case CommandType_DeviceInfo:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_DeviceState:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_StimulatorInfo:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_StimulatorInitialization:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_BigNumber:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_AdjustStimulator_Setting:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_StartStimulator:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_AdjustStimulator_Running:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_StimulatorControl:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_VibartionMode:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_VibartionMode_Setting:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_VibartionControl:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_VibartionInfo:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_BindID_High:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_BindID_Low:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_AuthorizationState_High:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_AuthorizationState_Low:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_QueryUserID:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_QueryUserID_Low:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_ClearUserID:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_ModeSelect:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_Pressure_Control:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_AdjustPressure:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_StartPressure:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_PollingPressureInfo:
        {
            return ReceivedCommandTypeSendedData;
            break;
        }
        case CommandType_Reset:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_PowerDown:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        case CommandType_ExceptionInfo:     //设备主动发送的异常信息
        {
            return ReceivedCommandTypeNoSendException;
            break;
        }
        case CommandType_SetException:
        {
            return ReceivedCommandTypeSendedCommand;
            break;
        }
        default:
        {
            return ReceivedCommandTypeNone;
            break;
        }
    }
}






@end
