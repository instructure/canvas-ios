//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import <UIKit/UIKit.h>
#import "CKStylingButton.h"

typedef enum {
    CKMediaCommentModeAudio = 1,
    CKMediaCommentModeVideo = 2
} CKMediaCommentMode;

@interface CKMediaCommentRecorderView : UIView

@property CKMediaCommentMode mode;
- (void)setMode:(CKMediaCommentMode)mode animated:(BOOL)animated;

@property (weak, nonatomic, readonly) NSURL *recordedFileURL;
@property (nonatomic, readonly, strong) CKStylingButton *flipToTextCommentButton;
@property (nonatomic, readonly, strong) CKStylingButton *postMediaCommentButton;


- (id)init;
- (void)rotateVideoToOrientation:(UIInterfaceOrientation)orientation;
- (void)stopAllMedia;
- (IBAction)tappedDonePlayingVideoButton:(id)sender;

- (void)clearRecordedMedia;

@end
