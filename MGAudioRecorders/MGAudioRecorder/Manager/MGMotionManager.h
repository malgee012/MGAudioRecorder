//
//  MGMotionManager.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/7.
//  Copyright © 2019 maling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGDBmanager.h"

NS_ASSUME_NONNULL_BEGIN


@interface MGMotionManager : NSObject

@property (nonatomic, strong) MGDBmanager *dbManager;



// 获取加速计数据
- (void)accelerometerPush;


// 开始记录
- (void)startRecord;
// 停止记录
- (void)stopRecord;


// 获取陀螺仪数据
- (void)gyroPush;

// 设备运动
- (void)startDeviceMotionData;



// 手机晃动次数
- (NSInteger)getTotalSwayCount;

@end

NS_ASSUME_NONNULL_END
