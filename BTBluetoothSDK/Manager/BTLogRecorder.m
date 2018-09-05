//
//  BTLogRecorder.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/8/21.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTLogRecorder.h"
#import "BTConstDefine.h"
#import "BTUtility.h"


@implementation BTLogRecorder

/**
 获取单例类方法
 */
static BTLogRecorder *_recorder = nil;
+(BTLogRecorder *)recorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _recorder = [[BTLogRecorder alloc] init];
    });
    return _recorder;
}

    ///初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        _logEnabled = NO;       //默认不记录log
    }
    return self;
}

/**获得Documents文件夹路径*/
-(NSString *)getDocumentPath
{
        // 检索指定路径
        // 第一个参数：指定的搜索路径
        // 第二个参数：检索的范围（沙盒内）
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths firstObject];
    return docPath;
}

/**获取documents路径下的某个路径*/
-(NSString *)documentPathByAppending:(NSString *)path
{
    NSString *dir = [[self getDocumentPath] stringByAppendingPathComponent:path];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:dir])       //目录不存在，创建目录
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

/**获得log目录路径*/
-(NSString *)getLogPath
{
    NSString *path = [self documentPathByAppending:LOG_DIR];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])       //目录不存在，创建目录
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

/**获得记录指令的文件路径*/
-(NSString *)getCommandLogFilePath
{
    NSString *filePath = [[self getLogPath] stringByAppendingPathComponent:LOG_COMMAND_FILE];
    return filePath;
}

///获得记录错误信息的文件路径
-(NSString *)getExceptionLogFilePath
{
    NSString *filePath = [[self getLogPath] stringByAppendingPathComponent:LOG_EXCEPTION_FILE];
    return filePath;
}

    ///记录一条指令数据，发送指令或接收指令；包括：发送接收时间/类型/二进制数据
-(void)logDataString:(NSString *)contentStr Path:(NSString *)filePath
{
    if (_logEnabled)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:filePath]) //如果不存在
        {
            NSString *str = @"";
            [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];     //更新模式打开文件
        [fileHandle seekToEndOfFile];  //将写入句柄跳到文件的末尾
        [fileHandle writeData:[contentStr dataUsingEncoding:NSUTF8StringEncoding]]; //追加写入数据
        [fileHandle synchronizeFile];
        [fileHandle closeFile];
    }
}

-(void)logSendCommandData:(NSData *)data
{
    if (_logEnabled)
    {
        NSString *time = [BTUtility fetchCurrentAccurateTime];      //系统时间
        NSString *flag = @"S";      //发送指令
        NSString *str = [NSString stringWithFormat:@"[%@]: %@  %@\n", time, flag, data];
        [self logDataString:str Path:[self getCommandLogFilePath]];
    }
}

-(void)logReceivedCommandData:(NSData *)data
{
    if (_logEnabled)
    {
        NSString *time = [BTUtility fetchCurrentAccurateTime];      //系统时间
        NSString *flag = @"R";      //接收指令
        NSString *str = [NSString stringWithFormat:@"[%@]: %@  %@\n", time, flag, data];
        [self logDataString:str Path:[self getCommandLogFilePath]];
    }
}

    ///记录错误信息，包括：超时/指令错误/异常
-(void)logExceptionInfo:(NSString *)str
{
    if (_logEnabled)
    {
        NSString *time = [BTUtility fetchCurrentAccurateTime];      //系统时间
        [self logDataString:[NSString stringWithFormat:@"[%@]: %@\n", time, str] Path:[self getExceptionLogFilePath]];
    }
}




@end
