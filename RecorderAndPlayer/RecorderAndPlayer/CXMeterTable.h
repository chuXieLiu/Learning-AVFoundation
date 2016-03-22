//
//  CXMeterTable.h
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//  分贝值转0-1浮点数

#import <Foundation/Foundation.h>

@interface CXMeterTable : NSObject

- (float)valueForPower:(float)power;

@end
