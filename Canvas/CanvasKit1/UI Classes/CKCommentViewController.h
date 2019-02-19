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

@class CKSubmission,CKSubmissionComment,CKCommentAttachment, CKCanvasAPI;

@protocol CKCommentViewControllerDelegate <NSObject>
@optional
- (void)commentViewController:(id)sender didSelectAttachment:(CKCommentAttachment *)attachment;
- (void)commentViewController:(id)sender didPostNewAttachmentForSubmission:(CKSubmission *)submission;
@end



extern NSString *CKCommentsViewHeightDidChangeNotification;

@interface CKCommentViewController : UIViewController

@property CGFloat commentsHeight;
@property (strong) CKCanvasAPI *canvasAPI;
@property (nonatomic, strong) CKSubmission *submission;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *placeholderActivityView;

@property (weak) id<CKCommentViewControllerDelegate> delegate;

@property (readonly) BOOL hasPendingContent;

- (void)reload;
- (void)reloadIfVisible;
- (void)loadComment:(CKSubmissionComment *)comment;
- (void)scrollCommentsViewToBottom:(BOOL)force;
- (void)setCommentsHeightFromJavascript;
- (void)resizeCommentsPopover:(NSNotification *)note;
- (IBAction)flipInputPanel:(id)sender;

@end
