//
//  BTDataParser.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTDataParser.h"
#import "BTCommandDefine.h"
#import "BTUtility.h"
#import "ReceivedCommandModel.h"
#import "BTConstDefine.h"
#import "BTDeviceModel.h"
#import "BTExceptionProcessor.h"
#import "BTException.h"
#import "BTStimulatorInfoModel.h"
#import "BigNumberInfoModel.h"
#import "VibrationInfoModel.h"
#import "PressureInfoModel.h"
#import "BTLogRecorder.h"


@interface BTDataParser()
@property(nonatomic, strong)BTExceptionProcessor *processor;

@end

@implementation BTDataParser

static BTDataParser *_parser = nil;
    ///单例类方法
+(BTDataParser *)parser
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parser = [[BTDataParser alloc] init];
    });
    return _parser;
}

///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _processor = [BTExceptionProcessor processor];
    }
    return self;
}

    ///解析一个接收到的指令对象
-(void)parseReceivedCommand:(ReceivedCommandModel *)receivedCommand
{
    if (!receivedCommand)
    {
        return;
    }
    //先校验CRC，如果CRC不正确，那么调用失败回调
    if (![BTUtility checkCRC:receivedCommand.commandDataFormat])
    {
        BTError *error = [[BTError alloc] initWithDomain:NSCocoaErrorDomain code:BTCommandStatus_CRCError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusCRCError, NSLocalizedFailureReasonErrorKey: BTCommandStatusCRCError}];
        if (receivedCommand.failure)
        {
            receivedCommand.failure(receivedCommand.commandEnumFormat, error);
        }
        return;
    }
    NSDictionary *dic = nil;
    switch (receivedCommand.commandEnumFormat)
    {
        case CommandType_DeviceInfo:        //设备信息
        {
            dic = [self parserDeviceInfo:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_DeviceState:       //设备状态
        {
            dic = [self parserDeviceState:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if ([dic[Command_objValue] isKindOfClass:[BTException class]])      //如果返回对象是异常对象，那么传出去
                {
                    if (self.delegate)
                    {
                        if ([self.delegate conformsToProtocol:@protocol(BTDataParserDelegate)] && [self.delegate respondsToSelector:@selector(dataParserDidCatchException:)])
                        {
                            [self.delegate dataParserDidCatchException:dic[Command_objValue]];
                        }
                    }
                }
                //不管返回的是不是异常对象，这个指令调用都是成功的，所以要调用成功的回调
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_StimulatorInfo:        //查询电刺激信息
        {
            dic = [self parserStimulatorInfo:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_StimulatorInitialization:        //电刺激初始化
        {
            dic = [self parserStimulatorSetting:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_BigNumber:        //查询手法大编号
        {
            dic = [self parserBigNumberList:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_AdjustStimulator_Setting:        //设置界面电刺激强度调节
        {
            dic = [self parserSettingAdjustStimulator:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_StartStimulator:        //电刺激方案开始运行
        {
            dic = [self parserStartStimulator:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_AdjustStimulator_Running:        //方案运行时电刺激电流调节
        {
            dic = [self parserRunningAdjustStimulator:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_StimulatorControl:        //电刺激控制，通道继续、暂停、停止
        {
            dic = [self parserStimulatorControl:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_VibartionMode:        //进入振动模式
        {
            dic = [self parserVibrationMode:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_VibartionMode_Setting:        //振动模式和强度设置
        {
            dic = [self parserVibrationModeSetting:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_VibartionControl:        //振动控制
        {
            dic = [self parserVibrationControl:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_VibartionInfo:        //振动信息查询，从机返回振动模式 振动强度 振动时间给主机；轮询指令
        {
            dic = [self parserVibrationInfo:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_BindID_High:        //账号绑定高16字节
        {
            dic = [self parserBindIdHigh:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_BindID_Low:        //账号绑定低16字节
        {
            dic = [self parserBindIdLow:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_AuthorizationState_High:        //查询从机账号是否授权，高16字节
        {
            dic = [self parserAuthorizationStateHigh:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_AuthorizationState_Low:        //查询从机账号是否授权，低16字节
        {
            dic = [self parserAuthorizationStateLow:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_ClearUserID:        //清除从机账号
        {
            dic = [self parserClearUserId:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_ModeSelect:        //模式选择；0x01-运行模式（默认模式），0x02-老化模式。
        {
            dic = [self parserModeSelect:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_Pressure_Control:      //负压控制
        {
            dic = [self parserPressureControl:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_AdjustPressure:        //负压调节
        {
            dic = [self parserPressureAdjust:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_StartPressure:     //负压开始
        {
            dic = [self parserPressureRunning:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_PollingPressureInfo:       //负压查询
        {
            dic = [self parserPressureQuery:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_Reset:        //恢复出厂设置
        {
            dic = [self parserReset:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_PowerDown:        //自动关机
        {
            dic = [self parserPowerDown:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_QueryUserID:        //查询账号信息，高16字节
        {
            dic = [self parserFetchUserIdHigh:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_QueryUserID_Low:        //查询账号信息，低16字节
        {
            dic = [self parserFetchUserIdLow:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_ExceptionInfo:     //设备主动发送的异常信息
        {
            dic = [self parserDeviceException:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if ([dic[Command_objValue] isKindOfClass:[BTException class]])      //如果返回对象是异常对象，那么传出去
                {
                    if (self.delegate)
                    {
                        if ([self.delegate conformsToProtocol:@protocol(BTDataParserDelegate)] && [self.delegate respondsToSelector:@selector(dataParserDidCatchException:)])
                        {
                            [self.delegate dataParserDidCatchException:dic[Command_objValue]];
                        }
                    }
                }
                    //不管返回的是不是异常对象，这个指令调用都是成功的，所以要调用成功的回调
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        case CommandType_SetException:      //主动发送异常信息的返回值
        {
            dic = [self parserSendException:receivedCommand];
            if ([dic[Command_Status] boolValue])
            {
                if (receivedCommand.success)
                {
                    receivedCommand.success(receivedCommand.commandEnumFormat, dic);
                }
            }
            else
            {
                if (receivedCommand.failure)
                {
                    receivedCommand.failure(receivedCommand.commandEnumFormat, dic[Command_Error]);
                }
            }
            break;
        }
        default:
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_NoData userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusNoData, NSLocalizedFailureReasonErrorKey: BTCommandStatusNoData}];
            if (receivedCommand.failure)
            {
                receivedCommand.failure(receivedCommand.commandEnumFormat, error);
            }
            NSLog(@"parser:%@", BTCommandStatusNoData);
            break;
        }
    }
    if (![dic[Command_Status] boolValue])       //如果发生了指令错误，记录日志
    {
        BTError *err = dic[Command_Error];
        [[BTLogRecorder recorder] logExceptionInfo:[NSString stringWithFormat:@"错误: %lx %@", (long)receivedCommand.commandEnumFormat, err.localizedDescription]];
    }
}

///取得数据字节
-(NSData *)getDataBytesFromCommand:(NSData *)commandData
{
    Byte *bytes = (Byte *)[commandData bytes];
    //取第二个字节
    Byte length = bytes[1];
    Byte dataBytes[20] = {0x00};       //数据字节数组
    for (int i = 0; i < length; ++i)
    {
        dataBytes[i] = bytes[i + 2];
    }
    NSData *data = [NSData dataWithBytes:dataBytes length:length];
    return data;
}

///取得数据字符串，ascii格式
-(NSString *)getDataStringFromCommand:(NSData *)commandData
{
    NSData *data = [self getDataBytesFromCommand:commandData];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

///解析设备信息数据
-(NSDictionary *)parserDeviceInfo:(ReceivedCommandModel *)model
{
    //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x01)      //正确
    {
            //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        NSString *string = [BTUtility convertDataToHexStr:data];
        BTDeviceModel *deviceModel = [[BTDeviceModel alloc] init];
            //从机序列号0~16位
        NSString *uuid = [string substringToIndex:16];
        deviceModel.uuid = uuid;
        //生产日期
        NSString *year = [uuid substringWithRange:NSMakeRange(2, 2)];
        NSString *month = [uuid substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [uuid substringWithRange:NSMakeRange(6, 2)];
        deviceModel.productDate = [NSString stringWithFormat:@"20%@年%@月%@日", year, month, day];
            //软件版本
        NSData *softwareData = [data subdataWithRange:NSMakeRange(8, 4)];
        Byte *softwareBytes = (Byte *)[softwareData bytes];
        NSString *softwareStr = [NSString stringWithFormat:@"%d.%d.%d.%d", softwareBytes[3], softwareBytes[2], softwareBytes[1], softwareBytes[0]];
        deviceModel.softwareVersion = softwareStr;
        //发布版本
        deviceModel.releaseVersion = [NSString stringWithFormat:@"V%d.0", softwareBytes[3]];
            //硬件版本
        NSData *hardwareData = [data subdataWithRange:NSMakeRange(12, 2)];
        Byte *hardwareBytes = (Byte *)[hardwareData bytes];
        NSString *hardwareStr = [NSString stringWithFormat:@"%d.%d", hardwareBytes[1], hardwareBytes[0]];
        deviceModel.hardwareVersion = hardwareStr;
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: deviceModel};
        return dic;
    }
    else        //出现了错误
    {
        //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }

}

///解析设备状态，状态轮询
-(NSDictionary *)parserDeviceState:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x02)      //指令返回正确，开始解析数据
    {
        //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        Byte *dataBytes = (Byte *)[data bytes];
        //异常信息
        NSData *exceptionData = [data subdataWithRange:NSMakeRange(3, 2)];
        //交换字节位置
        exceptionData = [BTUtility exchangeHighLowByte:exceptionData];
        NSString *exceptionHexStr = [BTUtility convertDataToHexStr:exceptionData];
        NSString *exceptionBitStr = [BTUtility turn16to2WithSpace:exceptionHexStr byteCount:exceptionData.length];      //两个字节的异常信息
        if ([[exceptionBitStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"])  //无异常，解析数据
        {
            BTDeviceModel *deviceModel = [[BTDeviceModel alloc] init];
                //电池电量
            NSString *battery = [NSString stringWithFormat:@"%d%%", dataBytes[0]];
            deviceModel.battery = battery;
                //电极信息
            NSData *electrodeData = [data subdataWithRange:NSMakeRange(1, 2)];
            //交换字节位置
            electrodeData = [BTUtility exchangeHighLowByte:electrodeData];
            NSString *electrodeHexStr = [BTUtility convertDataToHexStr:electrodeData];
            NSString *electrodeBitStr = [BTUtility turn16to2WithSpace:electrodeHexStr byteCount:electrodeData.length];      //两个字节的电极信息
            deviceModel.channelAType = [self getElectrodeType:[electrodeBitStr substringWithRange:NSMakeRange(3, 2)]];
            deviceModel.channelAStatus = [self getStimulatorStatus:[electrodeBitStr substringWithRange:NSMakeRange(5, 3)]];
            deviceModel.channelBType = [self getElectrodeType:[electrodeBitStr substringWithRange:NSMakeRange(11, 2)]];
            deviceModel.channelBStatus = [self getStimulatorStatus:[electrodeBitStr substringWithRange:NSMakeRange(13, 3)]];
                //工作状态
            deviceModel.workStatus = [self getWorkStatus:dataBytes[5]];
            deviceModel.workMode = [self getWorkMode:dataBytes[6]];
            NSDictionary *dic = @{Command_Status: @(1), Command_objValue: deviceModel};
            return dic;
        }
        else        //有异常，解析异常
        {
            BTException *exception = [_processor processorExceptionInfo:exceptionBitStr];
            NSDictionary *dic = @{Command_Status: @(1), Command_objValue: exception};
            return dic;
        }
    }
    else
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///获取电极类型
-(BTElectrodeType)getElectrodeType:(NSString *)elecrodeStr
{
    if ([elecrodeStr isEqualToString:@"00"])
    {
        return BTElectrodeTypeUnknown;
    }
    else if ([elecrodeStr isEqualToString:@"01"])
    {
        return BTElectrodeTypeBreast;
    }
    else if ([elecrodeStr isEqualToString:@"10"])
    {
        return BTElectrodeTypeWomb;
    }
    else
    {
        return BTElectrodeTypeUnknown;
    }
}

///获取电刺激状态
-(BTStimulatorStatus)getStimulatorStatus:(NSString *)statusStr
{
    if ([statusStr isEqualToString:@"001"])
    {
        return BTStimulatorStatusRunning;
    }
    else if ([statusStr isEqualToString:@"010"])
    {
        return BTStimulatorStatusPause;
    }
    else if ([statusStr isEqualToString:@"011"])
    {
        return BTStimulatorStatusStop;
    }
    else
    {
        return BTStimulatorStatusStop;
    }
}

///获得工作状态
-(BTDeviceWorkStatus)getWorkStatus:(Byte)byte
{
    if (byte == BTDeviceWorkStatusFree)
    {
        return BTDeviceWorkStatusFree;
    }
    else if (byte == BTDeviceWorkStatusStimulatorRunning)
    {
        return BTDeviceWorkStatusStimulatorRunning;
    }
    else if (byte == BTDeviceWorkStatusStimulatorSetting)
    {
        return BTDeviceWorkStatusStimulatorSetting;
    }
    else if (byte == BTDeviceWorkStatusVibration)
    {
        return BTDeviceWorkStatusVibration;
    }
    else
    {
        return BTDeviceWorkStatusFree;
    }
}

///获得运行模式
-(BTDeviceWorkMode)getWorkMode:(Byte)byte
{
    if (byte == BTDeviceWorkModeNormal)
    {
        return BTDeviceWorkModeNormal;
    }
    else if (byte == BTDeviceWorkModeAgeing)
    {
        return BTDeviceWorkModeAgeing;
    }
    else
    {
        return BTDeviceWorkModeNormal;
    }
}

///查询电刺激信息
-(NSDictionary *)parserStimulatorInfo:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x03)      //正确
    {
            //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        Byte *dataBytes = (Byte *)[data bytes];
        BTStimulatorInfoModel *stimInfo = [[BTStimulatorInfoModel alloc] init];
        //A通道电刺激状态
        stimInfo.channelAStimStatus = dataBytes[0];
        if (!(stimInfo.channelAStimStatus == BTStimulatorStatusStop))       //如果A通道不是停止状态需要查询后面的数据
        {
            //A通道方案编号
            NSData *channelAPlanNumberData = [data subdataWithRange:NSMakeRange(1, 1)];
            NSString *channelAPlanNumberStr = [NSString stringWithFormat:@"%04ld", (long)[BTUtility convertDataToInteger:channelAPlanNumberData]];
//            NSString *channelAPlanNumberStr = [BTUtility convertDataToHexStr:channelAPlanNumberData];
            stimInfo.channelAPlanNumber = channelAPlanNumberStr;
            //A通道电流是否可调
            Byte channelAEnabledByte = dataBytes[2];
            stimInfo.channelAEnabled = (channelAEnabledByte == 0x01) ? YES : NO;
            //A手法小编号
            NSData *channelASmallNumberData = [data subdataWithRange:NSMakeRange(3, 2)];
            NSInteger channelASmallNumber = [BTUtility convertDataToInteger:channelASmallNumberData];
            NSString *channelASmallNumberStr = [NSString stringWithFormat:@"%ld", (long)channelASmallNumber];
//            NSString *channelASmallNumberStr = [BTUtility convertDataToHexStr:channelASmallNumberData];
            stimInfo.channelASmallNumber = channelASmallNumberStr;
            //A电流强度
            stimInfo.channelAElectric = (NSInteger)dataBytes[5];
            //运行时间
            NSData *channelATimeData = [data subdataWithRange:NSMakeRange(6, 2)];
            stimInfo.channelATime = [BTUtility convertDataToInteger:channelATimeData];
        }
        //B通道电刺激状态
        stimInfo.channelBStimStatus = dataBytes[8];
        if (!(stimInfo.channelBStimStatus == BTStimulatorStatusStop))       //如果B通道电刺激状态不是停止，需要查询后面的数据
        {
                //B通道方案编号
            NSData *channelBPlanNumberData = [data subdataWithRange:NSMakeRange(9, 1)];
            NSString *channelBPlanNumberStr = [NSString stringWithFormat:@"%04ld", (long)[BTUtility convertDataToInteger:channelBPlanNumberData]];
//            NSString *channelBPlanNumberStr = [BTUtility convertDataToHexStr:channelBPlanNumberData];
            stimInfo.channelBPlanNumber = channelBPlanNumberStr;
                //B通道电流是否可调
            Byte channelBEnabledByte = dataBytes[10];
            stimInfo.channelBEnabled = (channelBEnabledByte == 0x01) ? YES : NO;
                //B手法小编号
            NSData *channelBSmallNumberData = [data subdataWithRange:NSMakeRange(11, 2)];
            NSInteger channelBSmallNumber = [BTUtility convertDataToInteger:channelBSmallNumberData];
            NSString *channelBSmallNumberStr = [NSString stringWithFormat:@"%ld", (long)channelBSmallNumber];
//            NSString *channelBSmallNumberStr = [BTUtility convertDataToHexStr:channelBSmallNumberData];
            stimInfo.channelBSmallNumber = channelBSmallNumberStr;
                //B电流强度
            stimInfo.channelBElectric = (NSInteger)dataBytes[13];
                //运行时间
            NSData *channelBTimeData = [data subdataWithRange:NSMakeRange(14, 2)];
            stimInfo.channelBTime = [BTUtility convertDataToInteger:channelBTimeData];
        }
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: stimInfo};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///进入电刺激设置初始化
-(NSDictionary *)parserStimulatorSetting:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///查询手法大编号列表
-(NSDictionary *)parserBigNumberList:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x05)      //正确
    {
            //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        Byte *dataBytes = (Byte *)[data bytes];
        //通道号
        BigNumberInfoModel *bigNumberInfo = [[BigNumberInfoModel alloc] init];
        bigNumberInfo.channel = (Parameter_Channel_Value)dataBytes[0];
        //方案编号
        NSData *planNumberData = [data subdataWithRange:NSMakeRange(1, 1)];
        NSString *planNumberStr = [NSString stringWithFormat:@"%04ld", (long)[BTUtility convertDataToInteger:planNumberData]];
//        NSString *planNumberStr = [BTUtility convertDataToHexStr:planNumberData];
        bigNumberInfo.planNumber = planNumberStr;
        //大编号列表
        //获取长度
        Byte secondByte = bytes[1];
        NSInteger count = (secondByte - 2) / 2;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < count; ++i)
        {
            NSData *numData = [data subdataWithRange:NSMakeRange(2 + i * 2, 2)];
            NSString *numStr = [NSString stringWithFormat:@"%ld", (long)[BTUtility convertDataToInteger:numData]];
//            NSData *numData1 = [data subdataWithRange:NSMakeRange(2 + 2 * i + 1, 1)];
//            NSData *numData2 = [data subdataWithRange:NSMakeRange(2 + 2 * i, 1)];
//            NSString *numStr1 = [BTUtility convertDataToHexStr:numData1];
//            NSString *numStr2 = [BTUtility convertDataToHexStr:numData2];
            if (![numStr isEqualToString:@"0"])     //编号不为0的时候才加入数组
            {
                [array addObject:numStr];
            }
        }
        bigNumberInfo.bigNumberArray = [array copy];
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: bigNumberInfo};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///设置界面电刺激强度调节
-(NSDictionary *)parserSettingAdjustStimulator:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///电刺激方案开始运行
-(NSDictionary *)parserStartStimulator:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///方案运行时电刺激电流调节
-(NSDictionary *)parserRunningAdjustStimulator:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///电刺激控制，通道继续、暂停、停止
-(NSDictionary *)parserStimulatorControl:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///进入振动模式
-(NSDictionary *)parserVibrationMode:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///振动模式和强度设置
-(NSDictionary *)parserVibrationModeSetting:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///振动控制
-(NSDictionary *)parserVibrationControl:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///振动信息查询，从机返回振动模式 振动强度 振动时间给主机；轮询指令
-(NSDictionary *)parserVibrationInfo:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x0D)      //正确
    {
        //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        Byte *dataBytes = (Byte *)[data bytes];
        VibrationInfoModel *vibrationInfo = [[VibrationInfoModel alloc] init];
        //振动模式
        vibrationInfo.vibrationMode = (Parameter_Vibartion_Mode_Setting_Value)dataBytes[0];
        //振动强度
        vibrationInfo.vibrationIntensity = (Parameter_Vibartion_Intensity_Setting_Value)dataBytes[1];
        //振动时间
        NSData *vibrationTimeData = [data subdataWithRange:NSMakeRange(2, 2)];
        vibrationInfo.vibrationTime = [BTUtility convertDataToInteger:vibrationTimeData];
        //计时标志
        vibrationInfo.timeSymbol = (Parameter_Vibartion_Timer_Symbol)dataBytes[4];
        //运行状态
        vibrationInfo.status = (Parameter_Vibartion_Running_Status)dataBytes[5];
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: vibrationInfo};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///账号绑定高16字节
-(NSDictionary *)parserBindIdHigh:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00 || secondByte == 0x30)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

    ///账号绑定低16字节
-(NSDictionary *)parserBindIdLow:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///查询从机账号是否授权，高16字节
-(NSDictionary *)parserAuthorizationStateHigh:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00 || secondByte == 0x30)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///查询从机账号是否授权，低16字节，如果返回0x08说明未授权
-(NSDictionary *)parserAuthorizationStateLow:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///清除从机账号
-(NSDictionary *)parserClearUserId:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///模式选择；0x01-运行模式（默认模式），0x02-老化模式。
-(NSDictionary *)parserModeSelect:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///负压控制（停止）
-(NSDictionary *)parserPressureControl:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///负压调节
-(NSDictionary *)parserPressureAdjust:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///负压运行
-(NSDictionary *)parserPressureRunning:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///负压查询
-(NSDictionary *)parserPressureQuery:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x1A)      //正确
    {
            //取得数据字节
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        Byte *dataBytes = (Byte *)[data bytes];
        PressureInfoModel *pressureInfo = [[PressureInfoModel alloc] init];
        //模式
        pressureInfo.mode = (Parameter_Pressure_Mode_Value)dataBytes[0];
        //力度
        pressureInfo.strength = (Parameter_Pressure_Strength_Value)dataBytes[1];
        //时间
        pressureInfo.runningTime = [BTUtility convertDataToInteger:[data subdataWithRange:NSMakeRange(2, 2)]];
        //计时标志
        pressureInfo.timeSymbol = (Parameter_Pressure_Timer_Symbol)dataBytes[4];
        //运行状态
        pressureInfo.status = (Parameter_Pressure_Running_Status)dataBytes[5];
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: pressureInfo};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///恢复出厂设置
-(NSDictionary *)parserReset:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///自动关机
-(NSDictionary *)parserPowerDown:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///查询账号信息，高16字节
-(NSDictionary *)parserFetchUserIdHigh:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x12)      //正确
    {
        NSString *str = [self getDataStringFromCommand:model.commandDataFormat];
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: str};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

    ///查询账号信息，低16字节
-(NSDictionary *)parserFetchUserIdLow:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x13)      //正确
    {
        NSString *str = [self getDataStringFromCommand:model.commandDataFormat];
        NSDictionary *dic = @{Command_Status: @(1), Command_objValue: str};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///解析设备主动发送的异常信息
-(NSDictionary *)parserDeviceException:(ReceivedCommandModel *)model
{
    //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte firstByte = bytes[0];
    if (firstByte == 0x33)  //正确
    {
            //取得数据字节，全部都是异常信息
        NSData *data = [self getDataBytesFromCommand:model.commandDataFormat];
        //交换两个字节位置
        data = [BTUtility exchangeHighLowByte:data];
            //异常信息
        NSString *exceptionHexStr = [BTUtility convertDataToHexStr:data];
        NSString *exceptionBitStr = [BTUtility turn16to2WithSpace:exceptionHexStr byteCount:data.length];      //两个字节的异常信息
        if ([[exceptionBitStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"])  //有异常，解析数据
        {
            BTException *exception = [_processor processorExceptionInfo:exceptionBitStr];
            NSDictionary *dic = @{Command_Status: @(1), Command_objValue: exception};
            return dic;
        }
        else        //无异常
        {
            NSDictionary *dic = @{Command_Status: @(1)};
            return dic;
        }
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}

///主动发送异常信息的返回
-(NSDictionary *)parserSendException:(ReceivedCommandModel *)model
{
        //判断数据是否正确
    Byte *bytes = (Byte *)[model.commandDataFormat bytes];
    Byte secondByte = bytes[1];
    if (secondByte == 0x00)      //正确
    {
        NSDictionary *dic = @{Command_Status: @(1)};
        return dic;
    }
    else        //出现了错误
    {
            //取得错误码
        BTError *error = [_processor processorCommandError:bytes[1]];
        NSDictionary *dic = @{Command_Status: @(0), Command_Error: error};
        return dic;
    }
}




@end
