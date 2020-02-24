//
//  MGRecorderManager.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/6.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGRecorderManager : NSObject

+ (void)authorizationStatus:(void(^)(BOOL author))authorizationStatus;
+ (NSString *)createRecordFolderPath;

// 保存本地的mp3文件路径
+ (NSString *)saveRecordFile:(nullable NSString *)fileName;
// 录音的源caf文件路径
+ (NSString *)saveCafFilePath;
+ (NSString *)saveCafFilePathWithName:(NSString *)name;
+ (void)removeLastCafFile;
// 移除所有的caf文件
+ (void)clearCafFile;
// 移除所有上那次保存的音频文件（caf & mp3）
+ (void)removeAllCacheAudioFile;


@end

NS_ASSUME_NONNULL_END
