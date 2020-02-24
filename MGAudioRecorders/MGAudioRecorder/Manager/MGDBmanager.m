//
//  MGDBmanager.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/12.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGDBmanager.h"
#import <AVFoundation/AVFoundation.h>
#import "MGRecorderManager.h"
#import "MGMotionTimer.h"
#import "MGRecorder.h"


#define beyondDB 60

@interface MGDBmanager ()<AVAudioRecorderDelegate, MGMotionTimerDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;  // 整体的录音
@property (nonatomic, strong) NSTimer *decibelTimer;  // 分贝值timer

@property (nonatomic, strong) NSTimer *deferTimer;  // 5秒之后停止录制timer (可能计时时长大于5秒)
@property (nonatomic, assign) NSInteger deferCount;  // 计秒
@property (nonatomic, assign) NSInteger deferRandomSecond;  // 延迟的随机秒数


// 超过指定分贝次数，
@property (nonatomic, strong) NSMutableArray *beyondPointDBArray;
// 存放分贝值的数组
@property (nonatomic, strong) NSMutableArray *dBArray;

@end
@implementation MGDBmanager


- (instancetype)init
{
    if (self = [super init]) {
        
        
        [MGRecorder sharedRecord].tRecordType = MGRecordMoldTypeNone;
        _beyondPointDBArray = [[NSMutableArray alloc] init];
        _dBArray = [[NSMutableArray alloc] init];
    }
    return self;
}


// 每1分钟检查一次
- (void)motionTimeDoCheckoutDBAtIndex:(NSInteger)index
{
    NSLog(@"分贝—————————— 第 %ld 次检查   超过60分贝 %lu 次", (long)index, (unsigned long)_beyondPointDBArray.count);
    
    NSInteger beyondCount = _beyondPointDBArray.count;
//    if (beyondCount <= 3) {
//        NSLog(@"睡眠质量很好。。。。。。");
//    } else if (beyondCount > 3 && beyondCount <= 15) {
//        NSLog(@"打鼾了。。。。。。");
//    } else if (beyondCount > 15 && beyondCount < 25){
//        NSLog(@"说梦话。。。。。。。");
//    } else {
//        NSLog(@"环境噪音。。。。。。。");
//    }
    
    [_beyondPointDBArray removeAllObjects];
}

// 用户是否在使用手机状态, 第几分钟了 1次 6分钟
- (void)motionDoUsingPhone:(BOOL)isUse minuteIndex:(NSInteger)minuteIndex
{
    if (isUse) {
        NSLog(@"手机在使用状态-- 代表还没有睡着, 清醒状态");
        
    } else {
        NSLog(@"手机闲置状态---  在睡觉呢 (浅睡 + 深睡)");
    }
        
}


// 开始录音
- (void)startRecord
{
    [self removeTimer];
    
    [self.audioRecorder record];
    self.decibelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordDecibelLevel) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.decibelTimer forMode:NSRunLoopCommonModes];
}

- (void)stopRecord
{
    [self.audioRecorder stop];
    [self removeTimer];
}

- (void)recordDecibelLevel
{
    [self.audioRecorder updateMeters];
    float power = [self.audioRecorder peakPowerForChannel:0];
//    CGFloat progress = (1.0 / 160.0) * (power + 160.0);
    
    power = power + 160  - 50;
    
    double dB = 0;
    if (power < 0.f) {
        dB = 0;
    } else if (power < 40.f) {
        dB = (int)(power * 0.875);
    } else if (power < 100.f) {
        dB = (int)(power - 35);
    } else if (power < 110.f) {
        dB = (int)(power * 2.5 - 165);
    } else {
        dB = 110;
    }
    
    
    NSInteger DB = [NSString stringWithFormat:@"%.f", dB].integerValue;
    
    NSLog(@"^^^^^^^^^^^^^^^^^^^^   %.f    %ld",  power,   (long)DB );
    
    [_dBArray addObject:@(DB)];

    // 传递 显示的分贝值
//    if ([self.delegate respondsToSelector:@selector(manager:DB:)]) {
//        [self.delegate manager:self DB:DB];
//    }
    
//    if (_dBArray.count < 10) {
//        return;
//    }
//
//    // 确定是超过指定的 60分贝
//    if ([self judgeBeyondDBs:_dBArray]) {
//        [self handelSleepElement:DB];
//
//        _deferCount = 0;
//    }
//
//    if (_dBArray.count >= 600) {
//        [_dBArray removeAllObjects];
//    }
}

// 最后8个数据都是大于60可以确定是
- (BOOL)judgeBeyondDBs:(NSArray <NSNumber *>*)array
{
    NSInteger totalNum = array.count;
    if (array[totalNum - 1].intValue > beyondDB &&
        array[totalNum - 2].intValue > beyondDB &&
        array[totalNum - 3].intValue > beyondDB &&
        array[totalNum - 4].intValue > beyondDB &&
        array[totalNum - 5].intValue > beyondDB &&
        array[totalNum - 6].intValue > beyondDB &&
        array[totalNum - 7].intValue > beyondDB &&
        array[totalNum - 8].intValue > beyondDB &&
        array[totalNum - 9].intValue > beyondDB ) {
        return YES;
    }
    return NO;
}

- (void)handelSleepElement:(NSInteger)db
{
    [_beyondPointDBArray addObject:@(db)];
    NSInteger count = _beyondPointDBArray.count;

    if (count <= 3) {
        
        if ([MGRecorder sharedRecord].isRecording == YES ) {
            
            if ([MGRecorder sharedRecord].tRecordType == MGRecordMoldTypeSleepTalk) {
                NSLog(@"结束。。梦话录制11111");
            } else if ([MGRecorder sharedRecord].tRecordType == MGRecordMoldTypeSnore ) {
                NSLog(@"结束。。打鼾录制11111");
            }
            
            [self doStopRecord];
        }
        
    } else if (count > 3 && count <= 15) {
        
        // 如果前面在录梦话 结束录制梦话
        if ([MGRecorder sharedRecord].isRecording == YES && [MGRecorder sharedRecord].tRecordType == MGRecordMoldTypeSleepTalk) {
            NSLog(@"结束。。梦话录制");
            [self doStopRecord];
        }

        if ([MGRecorder sharedRecord].isRecording == NO) {
            [self doRecordSnore];
        }
        
    } else if (count > 15) {
        
        // 如果前面在录打鼾 结束录制打鼾
        if ([MGRecorder sharedRecord].isRecording == YES && [MGRecorder sharedRecord].tRecordType == MGRecordMoldTypeSnore) {
            NSLog(@"结束。。打鼾录制");
            [self doStopRecord];
        }
        
        if ([MGRecorder sharedRecord].isRecording == NO) {
            [self doRecordSleepTalk];
        }
    }
}

// 停止录音
- (void)doStopRecord
{
    [self.deferTimer setFireDate:[NSDate distantFuture]];
    _deferCount = 0;
    
    
    [[MGRecorder sharedRecord] stopRecord];
    [MGRecorder sharedRecord].tRecording = NO;
    [MGRecorder sharedRecord].tRecordType = MGRecordMoldTypeNone;
    
}

// 录音打鼾
- (void)doRecordSnore
{
    _deferRandomSecond = [self getRandomNumber];
    
    NSLog(@"打鼾录制   %ld", _deferRandomSecond);
    
    [self.deferTimer setFireDate:[NSDate date]];
    
    [[MGRecorder sharedRecord] record];
    [MGRecorder sharedRecord].tRecording = YES;
    [MGRecorder sharedRecord].tRecordType = MGRecordMoldTypeSnore;
}

// 录音梦话
- (void)doRecordSleepTalk
{
    _deferRandomSecond = [self getRandomNumber];
    
    NSLog(@"梦话录制   %ld", _deferRandomSecond);
    
    [self.deferTimer setFireDate:[NSDate date]];
    
    [[MGRecorder sharedRecord] record];
    [MGRecorder sharedRecord].tRecording = YES;
    [MGRecorder sharedRecord].tRecordType = MGRecordMoldTypeSleepTalk;
}

// 开始录音之后延迟执行停止录音
- (void)deferDoStopRecord
{
    _deferCount += 1;
    
    NSLog(@"..........................................................................  %ld", _deferCount);
    
    if (_deferCount >= _deferRandomSecond) {
        
        [self doStopRecord];
        
    }
    
}

- (NSInteger)getRandomNumber
{
    NSInteger from = 5, to = 12;
    return (from + (arc4random() % (to - from + 1)));
}


#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"分贝————————————————录音完成...............");
    }
}

- (void)removeTimer
{
    if (self.decibelTimer) {
        [self.decibelTimer invalidate];
        self.decibelTimer = nil;
    }
    
    if (self.deferTimer) {
        [self.deferTimer invalidate];
        self.deferTimer = nil;
    }
}

- (NSTimer *)deferTimer
{
    if (!_deferTimer) {
        _deferTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(deferDoStopRecord) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_deferTimer forMode:NSRunLoopCommonModes];
        [_deferTimer setFireDate:[NSDate distantFuture]];
    }
    return _deferTimer;
}

/**
 *  录音参数设置
 */
- (NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(11025) forKey:AVSampleRateKey]; //44.1khz的采样率  // 11025
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];    // 通道数目，双通道
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey]; //16bit的PCM数据（采样位数）
    [dicM setObject:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    
//    [dicM setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsFloatKey]; // 采样信号是整数还是浮点数， X
    [dicM setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey]; // 大端还是小端是内存的组织方式
    return dicM;
}


- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {

        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord  error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
   
        
        //创建录音的caf文件保存路径(源文件路径PCM,没经过压缩的文件)
        NSURL *url= [NSURL fileURLWithPath:[MGRecorderManager saveCafFilePath]];
        
        NSDictionary *setting = [self getAudioSetting];
        NSError *error=nil;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;  // 如果要监控声波则必须设置为YES
        [_audioRecorder prepareToRecord];
        if (error) {
            NSLog(@"创建AVAudioRecorder Error：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

@end
