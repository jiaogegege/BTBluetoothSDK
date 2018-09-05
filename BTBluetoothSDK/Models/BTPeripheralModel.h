//
//  BTPeripheralModel.h
//  PostpartumRehabilitation
//
//  Created by 蒋雪姣 on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//


/**
 蓝牙外围设备对象，包括设备id、设备名称等信息，用于显示蓝牙搜索时设备选择
 **/

#import <Foundation/Foundation.h>

@interface BTPeripheralModel : NSObject

@property(nonatomic, copy)NSString *identifier;     //设备id
@property(nonatomic, copy)NSString *name;           //设备名称

///初始化方法
-(instancetype)initWithID:(NSString *)identifier name:(NSString *)name;




@end
