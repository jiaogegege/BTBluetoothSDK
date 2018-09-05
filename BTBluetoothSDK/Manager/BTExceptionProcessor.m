//
//  BTExceptionProcessor.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTExceptionProcessor.h"
#import "BTError.h"
#import "BTException.h"
#import "BTConstDefine.h"


@implementation BTExceptionProcessor

static BTExceptionProcessor *_processor = nil;
    ///单例类方法
+(BTExceptionProcessor *)processor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _processor = [[BTExceptionProcessor alloc] init];
    });
    return _processor;
}

    ///解析指令错误
-(BTError *)processorCommandError:(Byte)errorByte
{
    switch (errorByte)
    {
        case 0x00:      //一切正常
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_OK userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusOK, NSLocalizedFailureReasonErrorKey: BTCommandStatusOK}];
            return error;
            break;
        }
        case 0x30:      //等待指令传输完成
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_WaitFinish userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusWaitFinish, NSLocalizedFailureReasonErrorKey: BTCommandStatusWaitFinish}];
            return error;
            break;
        }
        case 0x01:      //指令错误
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_CommandError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusCommandError, NSLocalizedFailureReasonErrorKey: BTCommandStatusCommandError}];
            return error;
            break;
        }
        case 0x02:      //校验错误
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_CRCError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusCRCError, NSLocalizedFailureReasonErrorKey: BTCommandStatusCRCError}];
            return error;
            break;
        }
        case 0x03:      //参数错误
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_ParamError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusParamError, NSLocalizedFailureReasonErrorKey: BTCommandStatusParamError}];
            return error;
            break;
        }
        case 0x04:      //数据长度不正确
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_LengthError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusLengthError, NSLocalizedFailureReasonErrorKey: BTCommandStatusLengthError}];
            return error;
            break;
        }
        case 0x05:      //非法操作
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_IllegalError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusIllegalError, NSLocalizedFailureReasonErrorKey: BTCommandStatusIllegalError}];
            return error;
            break;
        }
        case 0x06:      //账号绑定失败
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_BindError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusBindError, NSLocalizedFailureReasonErrorKey: BTCommandStatusBindError}];
            return error;
            break;
        }
        case 0x07:      //账号绑定超过上限
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_BindTooMoreError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusBindTooMoreError, NSLocalizedFailureReasonErrorKey: BTCommandStatusBindTooMoreError}];
            return error;
            break;
        }
        case 0x08:      //账号未授权
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_AuthorizationError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusAuthorizationError, NSLocalizedFailureReasonErrorKey: BTCommandStatusAuthorizationError}];
            return error;
            break;
        }
        case 0x09:      //设备忙
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_BusyError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusBusyError, NSLocalizedFailureReasonErrorKey: BTCommandStatusBusyError}];
            return error;
            break;
        }
        case 0x0A:      //设备类型不匹配
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_DeviceError userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusDeviceError, NSLocalizedFailureReasonErrorKey: BTCommandStatusDeviceError}];
            return error;
            break;
        }
        default:        //解析不到数据
        {
            BTError *error = [BTError errorWithDomain:NSCocoaErrorDomain code:BTCommandStatus_NoData userInfo:@{NSLocalizedDescriptionKey: BTCommandStatusNoData, NSLocalizedFailureReasonErrorKey: BTCommandStatusNoData}];
            return error;
            break;
        }
    }
}

    ///解析异常信息，参数16个字符
-(BTException *)processorExceptionInfo:(NSString *)exceptionStr
{
    if ([[exceptionStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"1"])     //有异常
    {
        //内部存储bit
        NSString *innerStorageBit = [exceptionStr substringWithRange:NSMakeRange(15, 1)];
        //外部存储bit
        NSString *outerStorageBit = [exceptionStr substringWithRange:NSMakeRange(14, 1)];
        //真空泵bit
        NSString *pumpBit = [exceptionStr substringWithRange:NSMakeRange(13, 1)];
        //电磁阀bit
        NSString *tapBit = [exceptionStr substringWithRange:NSMakeRange(12, 1)];
        //A通道异常信息bit
        NSString *channelABit = [exceptionStr substringWithRange:NSMakeRange(5, 3)];
        //B通道异常信息bit
        NSString *channelBBit = [exceptionStr substringWithRange:NSMakeRange(2, 3)];
            //按摩bit
        NSString *vibrationBit = [exceptionStr substringWithRange:NSMakeRange(1, 1)];
        if ([innerStorageBit isEqualToString:@"1"])      //内部存储异常
        {
            BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Inner_Storage_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Inner_Storage_Error] reason:BTException_InnerStorageError userInfo:nil];
            return exception;
        }
        else if ([outerStorageBit isEqualToString:@"1"])     //外部存储异常
        {
            BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Outer_Storage_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Outer_Storage_Error] reason:BTException_OuterStorageError userInfo:nil];
            return exception;
        }
        else if ([pumpBit isEqualToString:@"1"])        //真空泵异常
        {
            BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Pump_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Pump_Error] reason:BTException_PumpError userInfo:nil];
            return exception;
        }
        else if ([tapBit isEqualToString:@"1"])     //电磁阀异常
        {
            BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Tap_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Tap_Error] reason:BTException_TapError userInfo:nil];
            return exception;
        }
        else if (![channelABit isEqualToString:@"000"])     //A通道异常
        {
            if ([channelABit isEqualToString:@"001"])       //电刺激输出异常
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_A_Stimulate_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_A_Stimulate_Error] reason:BTException_ElectordeAStimulateError userInfo:nil];
                return exception;
            }
            else if ([channelABit isEqualToString:@"010"])      //电极未连接
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_A_Unconnect rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_A_Unconnect] reason:BTException_ElectordeAUnconnect userInfo:nil];
                return exception;
            }
            else if ([channelABit isEqualToString:@"011"])      //电极不匹配
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_A_Unmatch rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_A_Unmatch] reason:BTException_ElectordeAUnmatch userInfo:nil];
                return exception;
            }
            else if ([channelABit isEqualToString:@"100"])      //电极脱落
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_A_Drop rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_A_Drop] reason:BTException_ElectordeADrop userInfo:nil];
                return exception;
            }
            else //无异常
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_No_Exception rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_No_Exception] reason:BTException_NoException userInfo:nil];
                return exception;
            }
        }
        else if (![channelBBit isEqualToString:@"000"])     //B通道异常
        {
            if ([channelBBit isEqualToString:@"001"])       //电刺激输出异常
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_B_Stimulate_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_B_Stimulate_Error] reason:BTException_ElectordeBStimulateError userInfo:nil];
                return exception;
            }
            else if ([channelBBit isEqualToString:@"010"])      //电极未连接
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_B_Unconnect rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_B_Unconnect] reason:BTException_ElectordeBUnconnect userInfo:nil];
                return exception;
            }
            else if ([channelBBit isEqualToString:@"011"])      //电极不匹配
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_B_Unmatch rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_B_Unmatch] reason:BTException_ElectordeBUnmatch userInfo:nil];
                return exception;
            }
            else if ([channelBBit isEqualToString:@"100"])      //电极脱落
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Electorde_B_Drop rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Electorde_B_Drop] reason:BTException_ElectordeBDrop userInfo:nil];
                return exception;
            }
            else //无异常
            {
                BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_No_Exception rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_No_Exception] reason:BTException_NoException userInfo:nil];
                return exception;
            }
        }
        else if ([vibrationBit isEqualToString:@"1"])       //按摩异常
        {
            BTException *exception = [[BTException alloc] initWithName:BTExceptionName code:BTException_Massage_Error rank:[BTExceptionProcessor getExceptionSeverityRank:BTException_Massage_Error] reason:BTException_MassageError userInfo:nil];
            return exception;
        }
        else
        {
            NSLog(@"processor:没有发现异常");
            return nil;
        }
    }
    else
    {
        NSLog(@"processor:没有发现异常");
    }
    return nil;
}

///获得异常的等级
+(BTExceptionSeverityRank)getExceptionSeverityRank:(BTCommandException)exception
{
    switch (exception)
    {
        case BTException_Inner_Storage_Error:   //内部存储错误
        {
            return BTExceptionSeverityRankVeryHigh;
            break;
        }
        case BTException_Outer_Storage_Error:       //外部存储错误
        {
            return BTExceptionSeverityRankVeryHigh;
            break;
        }
        case BTException_Electorde_A_Stimulate_Error:       //电刺激异常
        {
            return BTExceptionSeverityRankVeryHigh;
            break;
        }
        case BTException_Electorde_B_Stimulate_Error:       //电刺激异常
        {
            return BTExceptionSeverityRankVeryHigh;
            break;
        }
        case BTException_Massage_Error:         //按摩异常
        {
            return BTExceptionSeverityRankVeryHigh;
            break;
        }
        case BTException_Pump_Error:        //真空泵异常
        {
            return BTExceptionSeverityRankHigh;
            break;
        }
        case BTException_Tap_Error:     //电磁阀异常
        {
            return BTExceptionSeverityRankHigh;
            break;
        }
        case BTException_Electorde_A_Unconnect:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        case BTException_Electorde_B_Unconnect:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        case BTException_Electorde_A_Unmatch:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        case BTException_Electorde_B_Unmatch:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        case BTException_Electorde_A_Drop:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        case BTException_Electorde_B_Drop:
        {
            return BTExceptionSeverityRankNormal;
            break;
        }
        default:
        {
            return BTExceptionSeverityRankLow;
            break;
        }
    }
}





@end
