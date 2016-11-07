//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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