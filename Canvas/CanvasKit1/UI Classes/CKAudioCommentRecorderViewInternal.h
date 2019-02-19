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
    
    

#import "CKAudioCommentRecorderView.h"
#import "INAVPlayerView.h"

@interface CKAudioCommentRecorderView () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

// Main UI
@property (strong, nonatomic) IBOutlet UIView *mediaPanel;

@property (nonatomic, strong) IBOutlet UIView *mediaPanelHeadView;
// see public header for @property (nonatomic, strong) IBOutlet UIView *mediaPanelBaseView;

// LED panel
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *ledMicImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledRecordingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledReadyImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ledPlaybackImageView;

// Audio recording
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *recorderFilePath;
@property (nonatomic, strong) NSMutableDictionary *recorderSettings;
@property (nonatomic, assign) NSTimeInterval recordingDuration;


// IBActions
- (IBAction)tappedRecordButton:(id)sender;
- (IBAction)tappedPlayButton:(id)sender;

// Internal methods
//- (void)populateCaptureDevices;

- (BOOL)recordAudioComment;
- (void)stopRecordingAudioComment;

- (BOOL)playAudioComment;
- (void)stopPlayingAudioComment;

@end