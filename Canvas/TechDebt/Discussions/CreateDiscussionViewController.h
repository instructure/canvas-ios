
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
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/CKDiscussionTopic.h>
#import "CKRichTextInputView.h"

@protocol DiscussionCreationStrategy;
@class DiscussionsControllerHD;

@protocol CreateDiscussionDelegate <NSObject>
@required
- (void)showNewDiscussion:(CKDiscussionTopic *)discussionTopic;
@end

@interface CreateDiscussionViewController : UITableViewController <CKRichTextInputViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@property (weak, nonatomic) IBOutlet UISwitch *threadedDiscussionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *threadedSwitchLabel;

@property (nonatomic, strong) id <DiscussionCreationStrategy> createDiscussionStrategy;
@property (nonatomic,strong) CKCanvasAPI *canvasAPI;
@property (nonatomic,strong) CKContextInfo *contextInfo;
@property (nonatomic) BOOL iPadToolbarHidden;

@property id <CreateDiscussionDelegate> delegate;

- (id)initWithStrategy:(id <DiscussionCreationStrategy>)createDiscussionStrategy;

- (BOOL)hasContent;
- (void)dismissKeyboard;

@end
