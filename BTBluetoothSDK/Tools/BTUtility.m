//
//  BTUtility.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTUtility.h"
#import "BTConstDefine.h"


@implementation BTUtility

    ///取双字节数字的高字节
+(Byte)getDoubleByteHigh:(NSInteger)num
{
    Byte high = (Byte)((num >> 8) & 0xff);
    return high;
}

    ///取双字节数字的低字节
+(Byte)getDoubleByteLow:(NSInteger)num
{
    Byte low = (Byte)(num & 0xff);
    return low;
}

    ///将16进制数字字符串转换成2进制数字字符串，高位补0，以一个字节8位表示
+(NSString *)turn16to2WithSpace:(NSString *)str byteCount:(NSInteger)count
{
    NSString *s = [self turn16to2:str];
    NSInteger length = s.length;
    NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
    NSInteger zeroLength = 8 * count - length;
    for (int i = 0; i < zeroLength; ++i)
    {
        [string appendString:@"0"];
    }
        //拼接数据
    [string appendString:s];
    return [string copy];
}

///将16进制数字字符串转换成2进制数字字符串
+ (NSString *) turn16to2:(NSString *)str
{
    NSString *hexToTenStr = [BTUtility turn16to10:str];
    NSString *tenToTwoStr = [BTUtility turn10to2:hexToTenStr];
    return tenToTwoStr;
}

///将16进制数字字符串转换成10进制数字字符串
+ (NSString *) turn16to10:(NSString *)str
{
    unsigned long decimalData =  strtoul([str UTF8String], 0, 16);
    return [NSString stringWithFormat:@"%lu",decimalData];
    
}

///将10进制数字字符串转换成2进制数字字符串
+ (NSString *) turn10to2:(NSString *)str
{
    int num = [str intValue];
    NSMutableString * result = [[NSMutableString alloc] init];
    while (num > 0)
    {
        NSString * reminder = [NSString stringWithFormat:@"%d",num % 2];
        [result insertString:reminder atIndex:0];
        num = num / 2;
    }
    return result;
}

///将NSData转换成16进制字符串
+ (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0)
    {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2)
            {
                [string appendString:hexStr];
            }
            else
            {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
//    NSLog(@"strdata:%@", string);
    return string;
}

    ///交换高低字节的位置
+(NSData *)exchangeHighLowByte:(NSData *)originData
{
    NSMutableData *resultData = [NSMutableData data];
    for (NSInteger i = originData.length - 1; i >= 0; --i)
    {
        [resultData appendData:[originData subdataWithRange:NSMakeRange(i, 1)]];
    }
    return [resultData copy];
}

///将16进制字符串转换成NSData
+(NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0)
    {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    }
    else
    {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2)
    {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
//    NSLog(@"hexdata: %@", hexData);
    return hexData;
}

/**在主线程中异步执行代码，用于从后台线程返回主线程*/
+(void)asyncPerformActionOnMainThread:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

/**在主线程中同步执行代码*/
+(void)syncPerformActionOnMainThread:(dispatch_block_t)block
{
    dispatch_sync(dispatch_get_main_queue(), block);
}

/**在后台线程中异步执行代码*/
+(void)asyncPerformActionOnGlobalThread:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

/**在后台线程中同步执行代码*/
+(void)syncPerformActionOnGlobalThread:(dispatch_block_t)block
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

/**清除字符串头尾空格*/
+(NSString *)trimString:(NSString *)originStr
{
    return [originStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

    ///判断字符串是否为空
+(BOOL)isEmptyString:(NSString *)str
{
    str = [BTUtility trimString:str];
    if (str == nil || [str isEqualToString:@""] || [str isEqualToString:@"(null)"] || str.length <= 0 || [str isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

///清除数据末尾的0，从后往前遍历，发现第一个不为0的字节就是有效数据结束的地方
+(NSData *)cleanDataEndZero:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    unsigned short effectiveIndex = 0;
    for (int i = (int)data.length - 1; i >= 0; --i)      //从后往前遍历，寻找不为0的数据字节
    {
        Byte b = bytes[i];
        if (b != 0x00)      //找到了第一个不为0的数据字节时结束
        {
            effectiveIndex = i;
            break;
        }
    }
    NSData *effData = [data subdataWithRange:NSMakeRange(0, effectiveIndex + 1)];
    return effData;
}

    ///CRC校验
+(BOOL)checkCRC:(NSData *)data
{
    data = [BTUtility cleanDataEndZero:data];
    if (data.length >= 4)
    {
        //计算crc数据
        NSData *crcData = [BTUtility getCRC16:data length:(data.length - 2)];
        //查询数据的CRC位
        NSData *fetchedCRCData = [BTUtility fetchCRCSubData:data];
        //进行判断
        BOOL ret = [BTUtility isCRCOK:crcData fetchedCRC:fetchedCRCData];
        return ret;
    }
    else
    {
        return NO;
    }
}

    ///查询指令某些字节，返回NSData
+(NSData *)fetchSubData:(NSData *)data fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSMutableString* dataStr = [[NSMutableString alloc] init];
    if(fromIndex >= 0 && toIndex > 0 && toIndex >= fromIndex && data != nil)
    {
        Byte *dataByte = (Byte *)[data bytes];
        NSInteger i = 0;
        for(i = fromIndex; i < toIndex; i++)
        {
            [dataStr appendFormat: @"%02x", dataByte[i]];
        }
    }
    return [BTUtility convertHexStrToData:dataStr];
}

    ///查询某条指令的CRC位，两个字节，返回NSData
+(NSData *)fetchCRCSubData:(NSData *)data
{
    return [BTUtility fetchSubData:data fromIndex:data.length - 2 toIndex:data.length];
}

    ///获得某条指令经过CRC校验后的数据，返回两个字节
+(NSData *)getCRC16:(NSData *)data length:(unsigned short)length
{
    unsigned char *buf = (unsigned char *)[data bytes];
    unsigned short crc = 0xFFFF;
    unsigned char shiftctr;
    bool flag = false;
    /* Initialize CRC to all ones.                             */
    while (length > 0)
    {                               /* Account for each byte of data                           */
        length--;
        crc ^= (unsigned short)*buf++;
        shiftctr  = 8;
        do
        {
            flag   = (crc & 0x0001) ? true : false; /* Determine if the shift out of rightmost bit is 1.  */
            crc  >>= 1;                                /* Shift CRC to the right one bit.                         */
            if (flag == true)
            {                                           /* If (bit shifted out of rightmost bit was a 1)           */
                crc ^= PLOY;              /*     Exclusive OR the CRC with the generating polynomial */
            }
            shiftctr--;
        } while (shiftctr > 0);
    }
    return [BTUtility shortToData:crc];
}

    ///将short类型转换为NSData
+(NSData *)shortToData:(unsigned short)shortValue
{
    Byte bytes[] = {0x00,0x00};
    Byte t= 0x00;
    for (int i = 0; i < 2; i++)
    {
        bytes[(1 - i)] = (Byte) (shortValue >> i * 8 & 0xFF);
    }
    t = bytes[0];
    bytes[0] = bytes[1];
    bytes[1] = t;
    NSData *hexData = [NSData dataWithBytes:bytes length:2];
    return hexData;
}

    ///检查CRC校验是否通过，参数1:计算出来的crc，参数2:查询到的crc
+(BOOL)isCRCOK:(NSData *)crcData fetchedCRC:(NSData *)fetchedData
{
    if ([crcData isEqualToData:fetchedData])
    {
        return YES;
    }
    return NO;
}

///将一个字节转化为NSData
+(NSData *) ucharToData:(unsigned char) ucharValue
{
    Byte bytes[] = {0x00};
    bytes[0] = (Byte)(ucharValue >> 0 & 0xFF);
    return [NSData dataWithBytes:bytes length:1];
}

    ///将字符串转换成NSData
+(NSData *)convertStringToData:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

///将字符串转换成16进制字符串
+(NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD=[string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes=(Byte *)[myD bytes];
    NSString *hexStr=nil;
    for (int i=0; i<[myD length];i++)
    {
        NSString *newHexStr=[NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if ([newHexStr length]==1)
        {
            hexStr=[NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else
        {
            hexStr=[NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

    ///获得NSData的数字大小，小端模式
+(NSInteger)convertDataToInteger:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    NSInteger length = data.length;
    NSInteger num = 0;
    for (long i = length - 1; i >= 0; --i)
    {
        num += bytes[i] << (8 * i);
    }
    return num;
}

    ///获取系统时间
+ (NSString *)fetchCurrentAccurateTime
{
    NSString *currentDate = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    currentDate = [dateFormatter stringFromDate:[NSDate date]];
    return currentDate;
}






@end
