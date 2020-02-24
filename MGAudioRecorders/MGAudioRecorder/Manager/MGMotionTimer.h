//
//  MGMotionTimer.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/11.
//  Copyright © 2019 maling. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MGMotionTimeType) {
    MGMotionTimeTypeDB,
    MGMotionTimeTypeMotion
};

@protocol MGMotionTimerDelegate <NSObject>

- (void)motionTimeDoCheckoutSwayType:(MGMotionTimeType)timeType atIndex:(NSInteger)index;

@end
@interface MGMotionTimer : NSObject

@property (nonatomic, weak) id <MGMotionTimerDelegate> delegate;
+ (instancetype)sharedMotionTimeManager;

// 6分钟检查一次
- (void)checkoutFixedSwayTime;

- (void)timerInvalidate;

@end

NS_ASSUME_NONNULL_END
