//
//  MGMotionTimer.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/11.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGMotionTimer.h"
@interface MGMotionTimer ()

@property (nonatomic, assign) NSInteger index_db;  // 第几次的1分钟检查
@property (nonatomic, assign) NSInteger index_motion;  // 第几次的6分钟检查
@property (nonatomic, assign) NSInteger second_db;  // 计时秒-1分钟检查一次
@property (nonatomic, assign) NSInteger second_motion;  // 计时秒-6分钟检查一次
//@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) NSTimer *displayLink;

@end
@implementation MGMotionTimer

+ (instancetype)sharedMotionTimeManager
{
    static MGMotionTimer *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)checkoutFixedSwayTime
{
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handelDisplayLink:)];
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    self.displayLink.preferredFramesPerSecond = 1;
    
    self.displayLink = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handelDisplayLink:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.displayLink forMode:NSRunLoopCommonModes];
    
}

- (void)handelDisplayLink:(NSObject *)object
{
    _second_db += 1;
    _second_motion += 1;
    
    NSLog(@"...... %ld    %ld", _second_db, (long)_second_motion);
    
    // 监测分贝值 1 分钟监测一次
    if (_second_db >= 60) {
        _index_db += 1;
        if ([self.delegate respondsToSelector:@selector(motionTimeDoCheckoutSwayType:atIndex:)]) {
            [self.delegate motionTimeDoCheckoutSwayType:MGMotionTimeTypeDB atIndex:_index_db];
        }
        _second_db = 0;
    }
    
    // 监测抖动次数 6 分钟监测一次
    if (_second_motion >= 360) {
        _index_motion += 1;
        if ([self.delegate respondsToSelector:@selector(motionTimeDoCheckoutSwayType:atIndex:)]) {
            [self.delegate motionTimeDoCheckoutSwayType:MGMotionTimeTypeMotion atIndex:_index_motion];
        }
        _second_motion = 0;
    }
}

- (void)timerInvalidate
{
    if (self.displayLink) {
//        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.displayLink invalidate];
        self.displayLink = nil;
        _second_db = 0;
    }
}

@end
