//
//  CXMeterTable.m
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//  将对数形式的分贝转为线性0-1

#import "CXMeterTable.h"

static float const kMinDB = -60.0f; // 设置计算的最小分贝值（声音分贝值域为-160DB至0DB）


static NSInteger const kTableSize = 300;    // 设置可查浮点数表值个数为300


@interface CXMeterTable ()

@property (nonatomic,assign) float scaleFactor;

@property (nonatomic,strong) NSMutableArray *meterTable;

@end


@implementation CXMeterTable

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _scaleFactor = kTableSize / kMinDB;
        _meterTable = [NSMutableArray arrayWithCapacity:kTableSize];
        
        float minAmp = dbToAmp(kMinDB); // 最小浮点数（amp：Action Per Minute）
        float ampRange = 1.0 - minAmp;  // 列表的可取值范围
        
        float perAmpRange = 1.0 / ampRange; // 精准取值在0到1的范围内
        
        float dbResolution = kMinDB / (kTableSize - 1); // 平均一位所占db
        for (int i = 0; i < kTableSize; i ++) {
            float db = i * dbResolution;
            float amp = dbToAmp(db);    // 转浮点数
            float adjAmp = (amp - minAmp) * perAmpRange;    // 在0至1的范围内所对应的数字
            _meterTable[i] = @(adjAmp);
        }
    }
    return self;
}

// 0.05 * -60 = -3
// 10^(-3) = 1 / (10^3) = 0.001 最小值 | 最大值为10^0 = 1;
/**
 *  对数转浮点数
 *
 *  @param db
 *
 *  @return
 */
float dbToAmp(float db) {
    return powf(10.0f, 0.05 * db);
}


- (float)valueForPower:(float)power
{
    if (power < kMinDB) {
        return 0.f;
    } else if (power >= 0.f) {
        return 1.f;
    } else {
        // 计算该分贝值在表格的索引，并取出对应的浮点数
        int index = (int)(power * _scaleFactor);
        return [_meterTable[index] floatValue];
    }
}



@end
