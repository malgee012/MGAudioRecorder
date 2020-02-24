//
//  MGSleepRecordActiveManager.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGDBmanager.h"
#import "MGMotionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MGSleepRecordActiveManager : NSObject

@property (nonatomic, copy) void(^blcokBackDb)(NSInteger db);
@property (nonatomic, strong) MGDBmanager *tDbManager;
@property (nonatomic, strong) MGMotionManager *tMotionManager;

- (void)startRecord;
- (void)stopRecord;

- (void)pushAccelerometerData;


@end

NS_ASSUME_NONNULL_END
