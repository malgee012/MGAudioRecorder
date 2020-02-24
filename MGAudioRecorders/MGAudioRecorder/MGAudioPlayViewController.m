//
//  MGAudioPlayViewController.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/7.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGAudioPlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MGAudioPlayViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) NSTimer *playStatusTimer;

@end

@implementation MGAudioPlayViewController

- (void)clickClosePreview
{
    if (self.playStatusTimer) {
        [self.playStatusTimer invalidate];
        self.playStatusTimer = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"释放控制器");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 50)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [self.view addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(clickClosePreview) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.playTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 300, 20)];
    [self.view addSubview:self.playTimeLabel];
    
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.fileModel.mp3Path]) {
            NSLog(@"存在路径：%@", self.fileModel.mp3Path);
            
            
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.fileModel.mp3Path] error:nil];
            self.player.delegate = self;
            [self.player prepareToPlay];
            [self.player play];
            
            NSLog(@"todo 播放  %@", [NSURL fileURLWithPath:self.fileModel.mp3Path]);
            
            [self startPlayStatusTimer];
            
        } else {
            
            NSLog(@"不存在路径   %@", self.fileModel.mp3Path);
        }
        
    });
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完成");
    
    if (self.playStatusTimer) {
        [self.playStatusTimer invalidate];
        self.playStatusTimer = nil;
    }
}

- (void)startPlayStatusTimer
{
    if (!self.playStatusTimer) {
        NSLog(@"设置定时器");
        self.playStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [self.playStatusTimer setFireDate:[NSDate date]];
        [[NSRunLoop currentRunLoop] addTimer:self.playStatusTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updateTime{
    NSTimeInterval currentTime = self.player.currentTime;
    self.playTimeLabel.text = [self getFormatString:currentTime];
    
    NSLog(@"currentTime: %f    %@", currentTime, self.playTimeLabel.text);
}

- (NSString *)getFormatString:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if (hours <= 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes, (long)seconds];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

- (void)stopPlayStatusTimer
{
    if (self.playStatusTimer) {
        [self.playStatusTimer invalidate];
        self.playStatusTimer = nil;
        self.playTimeLabel.text = @"00:00";
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.player stop];
    [self stopPlayStatusTimer];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
