//
//  MGRecorder.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MGRecordMoldType) {
    MGRecordMoldTypeNone,
    MGRecordMoldTypeSnore,
    MGRecordMoldTypeSleepTalk,
    MGRecordMoldTypeNoise,
};

@interface MGRecorder : NSObject

@property (nonatomic, assign) MGRecordMoldType tRecordType;
@property (nonatomic, assign, getter=isRecording) BOOL tRecording;  // 是否正在录音

+ (instancetype)sharedRecord;




// 开始录音
- (void)record;

// 停止录音
- (void)stopRecord;

@property (nonatomic, copy) void(^finishRecord)(void);


@end

NS_ASSUME_NONNULL_END
