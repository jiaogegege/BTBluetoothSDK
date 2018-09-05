//
//  BTUtility.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
常用工具集 
 **/

#import <Foundation/Foundation.h>

@interface BTUtility : NSObject

    ///取双字节数字的高字节
+(Byte)getDoubleByteHigh:(NSInteger)num;

    ///取双字节数字的低字节
+(Byte)getDoubleByteLow:(NSInteger)num;

///将16进制数字字符串转换成2进制数字字符串，高位补0
///参数1:需要转换的16进制字符串；参数2:字节数
+(NSString *)turn16to2WithSpace:(NSString *)str byteCount:(NSInteger)count;

    ///将16进制数字字符串转换成2进制数字字符串
+ (NSString *) turn16to2:(NSString *)str;

    ///将16进制数字字符串转换成10进制数字字符串
+ (NSString *) turn16to10:(NSString *)str;

    ///将10进制数字字符串转换成2进制数字字符串
+ (NSString *) turn10to2:(NSString *)str;

    ///将16进制字符串转换成NSData
+(NSData *)convertHexStrToData:(NSString *)str;

    ///将NSData转换成16进制字符串
+ (NSString *)convertDataToHexStr:(NSData *)data;

///交换高低字节的位置
+(NSData *)exchangeHighLowByte:(NSData *)originData;

/**在主线程中异步执行代码，用于从后台线程返回主线程*/
+(void)asyncPerformActionOnMainThread:(dispatch_block_t)block;
/**在主线程中同步执行代码*/
+(void)syncPerformActionOnMainThread:(dispatch_block_t)block;
/**在后台线程中异步执行代码*/
+(void)asyncPerformActionOnGlobalThread:(dispatch_block_t)block;
/**在后台线程中同步执行代码*/
+(void)syncPerformActionOnGlobalThread:(dispatch_block_t)block;

/**清除字符串头尾空格*/
+(NSString *)trimString:(NSString *)originStr;

    ///判断字符串是否为空
+(BOOL)isEmptyString:(NSString *)str;

    ///清除数据末尾的0
+(NSData *)cleanDataEndZero:(NSData *)data;

///CRC校验
+(BOOL)checkCRC:(NSData *)data;

///查询指令某些字节，返回NSData
+(NSData *)fetchSubData:(NSData *)data fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

///查询某条指令的CRC位，两个字节，返回NSData
+(NSData *)fetchCRCSubData:(NSData *)data;

///获得某条指令经过CRC校验后的数据，返回两个字节
+(NSData *)getCRC16:(NSData *)data length:(unsigned short)length;

    ///检查CRC校验是否通过，参数1:计算出来的crc，参数2:查询到的crc
+(BOOL)isCRCOK:(NSData *)crcData fetchedCRC:(NSData *)fetchedData;

///将short类型转换为NSData
+(NSData *)shortToData:(unsigned short)shortValue;

    ///将一个字节转化为NSData
+(NSData *) ucharToData:(unsigned char) ucharValue;

///将字符串转换成NSData
+(NSData *)convertStringToData:(NSString *)string;

    ///将字符串转换成16进制字符串
+(NSString *)hexStringFromString:(NSString *)string;

///获得NSData的数字大小，小端模式
+(NSInteger)convertDataToInteger:(NSData *)data;

    ///获取系统时间
+ (NSString *)fetchCurrentAccurateTime;












@end
