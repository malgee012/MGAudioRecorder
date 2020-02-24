//
//  MGSleepRecordActiveManager.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGSleepRecordActiveManager.h"

@interface MGSleepRecordActiveManager () <MGDBmanagerDelegate>

@end
@implementation MGSleepRecordActiveManager

- (instancetype)init
{
    if (self = [super init]) {
        
        _tDbManager = [[MGDBmanager alloc] init];
        _tMotionManager = [[MGMotionManager alloc] init];
        _tMotionManager.dbManager = _tDbManager;
        
        _tDbManager.delegate = self;
    }
    return self;
}


- (void)startRecord
{
    [_tDbManager startRecord];
    [_tMotionManager startRecord];
}

- (void)stopRecord
{
    [_tDbManager stopRecord];
    [_tMotionManager stopRecord];
}

- (void)pushAccelerometerData
{
    [_tMotionManager accelerometerPush];
}

- (void)manager:(MGDBmanager *)manager DB:(NSInteger)db
{
    if (self.blcokBackDb) {
        self.blcokBackDb(db);
    }
}


@end
