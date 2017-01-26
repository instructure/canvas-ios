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

@protocol VideoRecorderViewDelegate;

@interface VideoRecorderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *videoPostButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoStatusActivityImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoStatusActivityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoStatusActivityIndicator;

@property (nonatomic, weak) id <VideoRecorderViewDelegate> delegate;

- (void)deleteVideo;
- (void)reset;

@end

@protocol VideoRecorderViewDelegate <NSObject>

@optional

- (void)videoStartedRecording;
- (void)videoDeletedRecording;
- (void)videoFinishedRecording;
- (void)postVideo:(NSURL *)videoURL;

@end
