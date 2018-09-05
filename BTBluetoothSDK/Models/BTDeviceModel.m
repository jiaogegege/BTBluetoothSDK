//
//  BTDeviceModel.m
//  PostpartumRehabilitation
//
//  Created by user on 2018/5/30.
//  Copyright © 2018年 dyimedical. All rights reserved.
//

#import "BTDeviceModel.h"

@implementation BTDeviceModel

    ///从父类创建一个子类
+(BTDeviceModel *)deviceFromPeripheral:(BTPeripheralModel *)peripheral
{
    if (peripheral)
    {
        BTDeviceModel *device = [[BTDeviceModel alloc] initWithID:peripheral.identifier name:peripheral.name];
        return device;
    }
    return nil;
}

///设置uuid的时候获得型号和颜色
-(void)setUuid:(NSString *)uuid
{
    _uuid = uuid;
    //获取型号和颜色描述字段，两个字符
    NSString *desStr = [uuid substringToIndex:1];
    if ([desStr isEqualToString:@"11"])
    {
        _model = MODEL_1;
        _color = COLOR_1;
    }
    else
    {
        _model = MODEL_1;
        _color = COLOR_1;
    }
}

    ///从一个对象实例中获取数据
-(void)getDataFromInstance:(BTDeviceModel *)model
{
   if (model.battery)
   {
       _battery = model.battery;
   }
    if (model.model)
    {
        _model = model.model;
    }
    if (model.color)
    {
        _color = model.color;
    }
    if (model.uuid)
    {
        _uuid = model.uuid;
    }
    if (model.productDate)
    {
        _productDate = model.productDate;
    }
    if (model.softwareVersion)
    {
        _softwareVersion = model.softwareVersion;
    }
    if (model.hardwareVersion)
    {
        _hardwareVersion = model.hardwareVersion;
    }
    if (model.releaseVersion)
    {
        _releaseVersion = model.releaseVersion;
    }
    _channelAType = model.channelAType;
    _channelBType = model.channelBType;
    _channelAStatus = model.channelAStatus;
    _channelBStatus = model.channelBStatus;
    _workMode = model.workMode;
    _workStatus = model.workStatus;
    
}

    ///重写复制方法
-(id)mutableCopyWithZone:(NSZone *)zone
{
    BTDeviceModel *instance = [[[self class] allocWithZone:zone] init];
    instance.identifier = [[self.identifier mutableCopy] copy];
    instance.name = [[self.name mutableCopy] copy];
    instance.battery = [[self.battery mutableCopy] copy];
    instance.model = [[self.model mutableCopy] copy];
    instance.color = [[self.color mutableCopy] copy];
    instance.state = self.state;
    instance.uuid = [[self.uuid mutableCopy] copy];
    instance.productDate = [[self.productDate mutableCopy] copy];
    instance.softwareVersion = [[self.softwareVersion mutableCopy] copy];
    instance.hardwareVersion = [[self.hardwareVersion mutableCopy] copy];
    instance.releaseVersion = [[self.releaseVersion mutableCopy] copy];
    
    instance.channelAType = self.channelAType;
    instance.channelBType = self.channelBType;
    instance.channelAStatus = self.channelAStatus;
    instance.channelBStatus = self.channelBStatus;
    instance.workStatus = self.workStatus;
    instance.workMode = self.workMode;
    
    return instance;
}

-(id)copyWithZone:(NSZone *)zone
{
    BTDeviceModel *instance = [[[self class] allocWithZone:zone] init];
    instance.identifier = [self.identifier copy];
    instance.name = [self.name copy];
    instance.battery = [self.battery copy];
    instance.model = [self.model copy];
    instance.color = [self.color copy];
    instance.state = self.state;
    instance.uuid = [self.uuid copy];
    instance.productDate = [self.productDate copy];
    instance.softwareVersion = [self.softwareVersion copy];
    instance.hardwareVersion = [self.hardwareVersion copy];
    instance.releaseVersion = [self.releaseVersion copy];
    
    instance.channelAType = self.channelAType;
    instance.channelBType = self.channelBType;
    instance.channelAStatus = self.channelAStatus;
    instance.channelBStatus = self.channelBStatus;
    instance.workStatus = self.workStatus;
    instance.workMode = self.workMode;
    
    return instance;
}


@end
