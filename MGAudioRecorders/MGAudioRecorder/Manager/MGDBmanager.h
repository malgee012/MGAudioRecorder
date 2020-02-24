//
//  MGDBmanager.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MGDBmanager;
@protocol MGDBmanagerDelegate <NSObject>

// 传递分贝值
- (void)manager:(MGDBmanager *)manager DB:(NSInteger)db;

@end
@interface MGDBmanager : NSObject

@property (nonatomic, weak) id <MGDBmanagerDelegate> delegate;
- (void)startRecord;
- (void)stopRecord;

// 每一分钟监测一次
- (void)motionTimeDoCheckoutDBAtIndex:(NSInteger)index;
// 用户是否在使用手机状态, 第几分钟了  1次 6分钟
- (void)motionDoUsingPhone:(BOOL)isUse minuteIndex:(NSInteger)minuteIndex;



@end

NS_ASSUME_NONNULL_END
