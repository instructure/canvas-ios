//
//  CSGAudioManager.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 11/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CSGAudioManager;

typedef void (^UpdateTimeBlock)(NSInteger currentTime);
typedef void (^FinishedPlaybackBlock)();

@interface CSGAudioManager : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSURL *audioRecorderFileURL;

- (instancetype)initWithView:(UIView *)view;

- (BOOL)recordAudioCommentWithUpdateTimeBlock:(UpdateTimeBlock)updateBlock finishedBlock:(FinishedPlaybackBlock)finishedRecordBlock;
- (void)stopAudioRecording;
- (BOOL)deleteAudioRecording;
- (void)setupAudioPlaybackWithSuccess:(void (^)())success Failure:(void (^)())failure;
- (void)playWithUpdateTimeBlock:(UpdateTimeBlock)updateBlock finishedBlock:(FinishedPlaybackBlock)finishedPlaybackBlock;
- (void)pause;
- (NSInteger)totalAudioTimeInSeconds;

@end