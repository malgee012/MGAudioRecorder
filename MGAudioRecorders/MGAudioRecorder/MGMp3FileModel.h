//
//  MGMp3FileModel.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/7.
//  Copyright © 2019 maling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGMp3FileModel : NSObject


//Mp3路径
@property (nonatomic,copy)NSString *mp3Path;

//Mp3名字
@property (nonatomic,copy)NSString *mp3Name;

@end

NS_ASSUME_NONNULL_END
