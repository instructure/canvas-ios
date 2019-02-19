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
#import <CanvasKit1/CKStylingButton.h>

@interface CKAudioCommentRecorderView : UIView

@property (weak, nonatomic, readonly) NSURL *recordedFileURL;
@property (nonatomic, weak) IBOutlet UIView *mediaPanelBaseView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

// Hidden by default, use at will
@property (weak, nonatomic) IBOutlet CKStylingButton *leftButton;
@property (weak, nonatomic) IBOutlet CKStylingButton *rightButton;

- (id)init;
- (void)stopAllMedia;
- (void)clearRecordedMedia;
@end
