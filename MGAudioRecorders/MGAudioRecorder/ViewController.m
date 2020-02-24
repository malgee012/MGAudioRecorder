//
//  ViewController.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import "ViewController.h"
#import "MGRecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MGRecordEncodeTool.h"
#import "MGMp3FileModel.h"
#import "MGAudioPlayViewController.h"
#import "MGMotionManager.h"
//#import "MGMotionTimer.h"
#import "MGDBmanager.h"
#import "MGSleepRecordActiveManager.h"

#import "ConvertAudioFile.h"
#import "MGRecorder.h"

static NSString * const reuseIdentifier_cell = @"reuseIdentifier_cell";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate>


@property (nonatomic, strong) NSTimer *recordTimer;
@property (weak, nonatomic) IBOutlet UILabel *recorderTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *dbLabel;

@property (nonatomic, strong) AVAudioRecorder *recorder;  // 分段录音

@property (nonatomic, copy) NSString *cafFilePath;

@property (nonatomic, strong) UITableView *displayTableView;
@property (nonatomic, strong) NSMutableArray *mp3FileModelArray;



//@property (nonatomic, strong) MGMotionManager *motionManager;

@property (nonatomic, strong) MGSleepRecordActiveManager *activeManager;

@end



#define ETRECORD_RATE 11025   // 44100   11025.0
#define ENCODE_MP3    1

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
//    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging) {
//        NSLog(@"正在充电  %ld", [[UIDevice currentDevice] batteryState]);
//    } else {
//        NSLog(@"没有充电  %ld", [[UIDevice currentDevice] batteryState]);
//    }

    
    
    NSLog(@"path:::  %@", [MGRecorderManager createRecordFolderPath]);
    
    //
    _activeManager = [[MGSleepRecordActiveManager alloc] init];
    __weak typeof(self)weakSelf = self;
    [_activeManager setBlcokBackDb:^(NSInteger db) {
        weakSelf.dbLabel.text = [NSString stringWithFormat:@"db:%ld", db];
    }];
    
//    AudioUnit 可以更加灵活的处理录音数据，混音等
    
    
    [MGRecorderManager removeAllCacheAudioFile];
//    [MGRecorderManager clearCafFile];

    
    [self.view addSubview:self.displayTableView];
    [MGRecorderManager authorizationStatus:^(BOOL author) {
        NSLog(@"可以访问录音");
    }];

    // 录音完成刷新数据
    [[MGRecorder sharedRecord] setFinishRecord:^{
        [weakSelf getMp3DataSource];
    }];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int  i = 0; i < 20; i++) {
        
        [arr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    
    NSInteger i = arr.count;
    NSLog(@"..  %@", arr[i - 1]);
    NSLog(@"..  %@", arr[i - 2]);
    NSLog(@"..  %@", arr[i - 3]);
    NSLog(@"..  %@", arr[i - 4]);
    
    
    
}



/** 刷新数据 */
- (void)getMp3DataSource
{
    _mp3FileModelArray = [[NSMutableArray alloc] init];
//    //先清空原来的数组
//    [self.mp3FileModelArray removeAllObjects];

    NSString *folderPath = [MGRecorderManager createRecordFolderPath];
    
    //查找文件夹下的所有文件
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *filename in tmplist) {
        if ([filename hasSuffix:@"mp3"]) {
            NSString *fullpath = [folderPath stringByAppendingPathComponent:filename];
            MGMp3FileModel *model = [[MGMp3FileModel alloc]init];
            model.mp3Path = fullpath;
            model.mp3Name = filename;
            [self.mp3FileModelArray addObject:model];
        }
    }
    
    [self.mp3FileModelArray sortUsingComparator:^NSComparisonResult(MGMp3FileModel *obj1, MGMp3FileModel *obj2) {
        return [obj1.mp3Name compare:obj2.mp3Name];
    }];
    
    [self.displayTableView reloadData];
}

- (void)clearCafFile
{
    [MGRecorderManager clearCafFile];
}

- (void)segmmentRecord
{
    NSString *mp3Path = [MGRecorderManager saveRecordFile:nil];
    NSString *cafPath = self.cafFilePath;
    
//    [[MGRecordEncodeTool shareInstance] encodeMp3FileWithPcmFilePath:cafPath destinationFilePath:mp3Path sampleRate:44100 channels:2 bitRate:128];
    
//    [[MGRecordEncodeTool shareInstance] encodeMp3ToMp3WithCafFilePath:cafPath mp3FilePath:mp3Path sampleRate:11025.0 callback:^(BOOL result) {
//        NSLog(@"转化完成");
//    }];
    
        NSLog(@"KKKKKK  %@  \n %@", cafPath, mp3Path);
//       [[ConvertAudioFile sharedInstance] conventToMp3WithCafFilePath:cafPath
//                                                         mp3FilePath:mp3Path
//                                                          sampleRate:ETRECORD_RATE
//                                                            callback:^(BOOL result) {
//           if (result) {
//               NSLog(@"mp3 file compression sucesss");
//           }
//       }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self stopRecord];
//
//    [self startRecord];
}


// 开始录音 & 暂停
- (IBAction)clickRecorder:(UIButton *)button {
    
    button.selected = !button.selected;
    
    if (button.selected) {
        
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(recordTimerAction) userInfo:nil repeats:YES];
        [self.recordTimer setFireDate:[NSDate distantPast]];
//        [self startRecord];
        
        [self clearCafFile];
//        [[MGRecorder sharedRecord] record];
        [_activeManager startRecord];
        
        [button setTitle:@"停止⏹" forState:UIControlStateNormal];
        
    } else {
        
        
        recorderSeconds = 0;
        [button setTitle:@"开始录音" forState:UIControlStateNormal];
        [[MGRecorder sharedRecord] stopRecord];
        [_activeManager stopRecord];

        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mp3FileModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier_cell];
    MGMp3FileModel *model = self.mp3FileModelArray[indexPath.row];
    cell.textLabel.text = model.mp3Name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MGAudioPlayViewController *playVc = [[MGAudioPlayViewController alloc]init];
    playVc.fileModel = self.mp3FileModelArray[indexPath.row];
    [self presentViewController:playVc animated:YES completion:^{
        
    }];
}


NSInteger recorderSeconds = 0;
- (void)recordTimerAction
{
    NSString *time = nil;
    NSInteger seconds = recorderSeconds % 60;
    NSInteger minutes = (recorderSeconds / 60) % 60;
    NSInteger hours = recorderSeconds / 3600;
    if (hours <= 0) {
        time = [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes, (long)seconds];
    }
    time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    
    
    self.recorderTimeLable.text = time;
    recorderSeconds += 1;
}


- (UITableView *)displayTableView
{
    if (!_displayTableView) {
        _displayTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 250, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - 250)];
        _displayTableView.delegate = self;
        _displayTableView.dataSource = self;
        [_displayTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier_cell];
        _displayTableView.backgroundColor = [UIColor orangeColor];
    }
    return _displayTableView;
}

@end
