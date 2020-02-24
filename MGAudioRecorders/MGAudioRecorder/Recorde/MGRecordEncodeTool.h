//
//  MGRecordEncodeTool.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGRecordEncodeTool : NSObject

+ (instancetype)shareInstance;
    
/**
 pcm编码成Mp3文件
 @param pcmFilePath pcm源文件路径
 @param mp3FilePath 编码完成mp3文件路径
 @param sampleRate 采样率
 @param channels 通道数
 @param bitRate 码率 单位kbps
 
 返回编码成功结果
 */
- (void)encodeMp3FileWithPcmFilePath:(NSString *)pcmFilePath
                 destinationFilePath:(NSString *)mp3FilePath
                          sampleRate:(int)sampleRate
                            channels:(int)channels
                             bitRate:(int)bitRate;

- (void)encodeMp3ToMp3WithCafFilePath:(NSString *)cafFilePath
                          mp3FilePath:(NSString *)mp3FilePath
                           sampleRate:(int)sampleRate
                             callback:(void(^)(BOOL result))callback;

+ (void)encodeMp3ToMp3WithCafFilePath:(NSString *)cafFilePath
                          mp3FilePath:(NSString *)mp3FilePath
                           sampleRate:(int)sampleRate
                             callback:(void(^)(BOOL result))callback;

- (void)endRecord;

@end

NS_ASSUME_NONNULL_END
