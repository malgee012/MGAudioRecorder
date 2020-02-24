//
//  MGRecorder.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "MGRecorderManager.h"
#import "MGRecordEncodeTool.h"

#define ETRECORD_RATE 44100

@interface MGRecorder ()<AVAudioRecorderDelegate>

@property (nonatomic, copy) NSString *cafFilePath;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end
@implementation MGRecorder

+ (instancetype)sharedRecord
{
    static MGRecorder *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)record
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    self.cafFilePath = [MGRecorderManager saveCafFilePathWithName:[NSString stringWithFormat:@"%@_segment_name", @"2"]];
    NSURL *url= [NSURL fileURLWithPath:self.cafFilePath];
    NSDictionary *setting = [self getAudioSetting];
    NSError *error=nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;  // 如果要监控声波则必须设置为YES
    [recorder prepareToRecord];
    [recorder record];
    self.recorder = recorder;
}

- (void)stopRecord
{
    [self.recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        NSLog(@"----- 录音  完毕");
        
        NSString *mp3Path = [MGRecorderManager saveRecordFile:nil];
        NSString *cafPath = self.cafFilePath;
        
        __weak typeof(self)weakSelf = self;
        [MGRecordEncodeTool encodeMp3ToMp3WithCafFilePath:cafPath mp3FilePath:mp3Path sampleRate:ETRECORD_RATE callback:^(BOOL result) {
            
            NSLog(@"转换完成");
            
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf getMp3DataSource];
                    if (weakSelf.finishRecord) {
                        weakSelf.finishRecord();
                    }
                });
            }
        }];
    }
}


/**
 *  录音参数设置
 */
- (NSDictionary *)getAudioSetting
{
//    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    [dicM setObject:@(ETRECORD_RATE) forKey:AVSampleRateKey]; //44.1khz的采样率
//    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];    // 通道数目，双通道
//    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey]; //16bit的PCM数据（采样位数）
//    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    
//    [dicM setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsFloatKey]; // 采样信号是整数还是浮点数， X
//    [dicM setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey]; // 大端还是小端是内存的组织方式
    
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(ETRECORD_RATE) forKey:AVSampleRateKey];

    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
//
    
    return dicM;
}

@end
