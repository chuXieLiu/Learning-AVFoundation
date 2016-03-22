//
//  CXMemo.h
//  RecorderAndPlayer
//
//  Created by c_xie on 16/3/22.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXMemo : NSObject

@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) NSURL *url;

@property (nonatomic,copy) NSString *formattedTime;


@end
