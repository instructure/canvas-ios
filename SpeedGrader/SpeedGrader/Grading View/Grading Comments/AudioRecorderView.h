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

#import <UIKit/UIKit.h>

@protocol AudioRecorderViewDelegate;

typedef NS_ENUM(NSUInteger, CSGAudioRecordingState) {
    CSGAudioRecordingStart,
    CSGAudioRecordingStop,
    CSGAudioRecordingPlay,
    CSGAudioRecordingPause
};

@interface AudioRecorderView : UIView

@property (nonatomic, weak) id <AudioRecorderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIImageView *audioActivityStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioActivityStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *audioActivityIndicator;

- (void)audioDeleteRecording;

@end

@protocol AudioRecorderViewDelegate <NSObject>

@optional

- (void)audioStartedRecording;
- (void)audioFinishedRecording;
- (void)audioDeleteRecording;
- (void)audioPlaybackRecording;
- (void)audioPauseRecording;
- (void)postAudio:(NSURL *)audioURL;

@end
