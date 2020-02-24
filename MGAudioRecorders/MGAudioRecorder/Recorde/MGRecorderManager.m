//
//  MGRecorderManager.m
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import "MGRecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

static NSString *const MP3SaveFilePath = @"MP3RecordFile";

@implementation MGRecorderManager


+ (void)authorizationStatus:(void(^)(BOOL author))authorizationStatus
{
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        //第一次询问用户是否进行授权
        __weak typeof(self)weakSelf = self;
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                //授权成功
                if (authorizationStatus) {
                    authorizationStatus(YES);
                }
            } else {
                //授权失败
                [weakSelf showSetAlertView];
            }
        }];
    } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        // 未授权
        [self showSetAlertView];
    } else{
        // 已授权
        if (authorizationStatus) {
            authorizationStatus(YES);
        }
    }
}

//提示用户进行麦克风使用授权
+ (void)showSetAlertView
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"麦克风权限未开启" message:@"麦克风权限未开启，请进入系统【设置】>【隐私】>【麦克风】中打开开关,开启麦克风功能" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳入当前App设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:setAction];
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window.rootViewController presentViewController:alertVC animated:YES completion:nil];
}

+ (NSString *)createRecordFolderPath
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:MP3SaveFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (isDirExist) {
//        NSLog(@"已创建， 不再创建文件路径:::  %@", path);
        return path;
    }
    
    BOOL createFolderSuc = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if(createFolderSuc){
//        NSLog(@"创建Mp3保存路径成功");
    }
    return path;
}

+ (NSString *)saveRecordFile:(nullable NSString *)fileName
{
    NSString *folderPath = [self createRecordFolderPath];
    NSString *mp3FileName = [NSString stringWithFormat:@"%@.mp3",[self getCurrentTimeString]];
    return [folderPath stringByAppendingPathComponent:mp3FileName];
}

+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY_MM_dd_HH_mm_ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSString *)saveCafFilePathWithName:(NSString *)name
{
    NSString *folderPath = [self createRecordFolderPath];
    NSString *cafPath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", name]];
    return cafPath;
}

+ (NSString *)saveCafFilePath
{
    NSString *folderPath = [self createRecordFolderPath];
    NSString *cafPath = [folderPath stringByAppendingPathComponent:@"record.caf"];
    return cafPath;
}

+ (void)removeLastCafFile
{
    NSString *lastCafFilePath = [self saveCafFilePath];
    if (lastCafFilePath) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:lastCafFilePath isDirectory:&isDir];
        if (isDirExist) {
            [fileManager removeItemAtPath:lastCafFilePath error:nil];
            NSLog(@"清除上一次的Caf文件");
        }
    }
}

+ (void)clearCafFile
{
    NSString *folderPath = [MGRecorderManager createRecordFolderPath];
    
    //查找文件夹下的所有文件
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *filename in tmplist) {
        if ([filename hasSuffix:@"segment_name.caf"]) {
            NSString *cafFullpath = [folderPath stringByAppendingPathComponent:filename];
            if ([[NSFileManager defaultManager] fileExistsAtPath:cafFullpath isDirectory:nil]) {
                 [[NSFileManager defaultManager] removeItemAtPath:cafFullpath error:nil];
            }
        }
    }
}

+ (void)removeAllCacheAudioFile
{
    NSString *folderPath = [MGRecorderManager createRecordFolderPath];
    
    //查找文件夹下的所有文件
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *filename in tmplist) {
        NSString *cafFullpath = [folderPath stringByAppendingPathComponent:filename];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cafFullpath isDirectory:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:cafFullpath error:nil];
        }
        
    }
}



@end
