//
//  MGAudioPlayViewController.h
//  MGAudioRecorder
//
//  Created by maling on 2019/11/7.
//  Copyright © 2019 maling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGMp3FileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MGAudioPlayViewController : UIViewController

@property (nonatomic, strong) MGMp3FileModel *fileModel;

@end

NS_ASSUME_NONNULL_END
