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
    
    

#import "CBISubmissionInputViewController.h"
#import "CBISubmissionInputView.h"
#import "CKIClient+CBIClient.h"
@import CanvasKeymaster;

@interface CBISubmissionInputViewController () <CKRichTextInputViewDelegate>

@property (weak, nonatomic) IBOutlet CBISubmissionInputView *submissionInputView;

@end

@implementation CBISubmissionInputViewController
- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"CBISubmissionInputViewController" bundle:[NSBundle bundleForClass:[self class]]] instantiateViewControllerWithIdentifier:@"CBISubmissionInputViewController"];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(480, 360);
    }
    return self;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.submissionInputView.delegate = self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1) {
        return 44;
    }

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return 300;
    }
    
    return 180;
}

#pragma mark - CKIRichTextInputViewDelegate

- (void)resizeRichTextInputViewToHeight:(CGFloat)height
{
    // not resizing
}

- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray *)attachments andCompletionBlock:(CKSimpleBlock)block {
    
    CKCanvasAPI *canvasAPI = self.canvasAPI;
    CKAssignment *assignment = self.assignment;
    
    [inputView dismissKeyboard];

    @weakify(self);
    [canvasAPI postHTML:comment asSubmissionForAssignment:assignment completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
        @strongify(self);
        if (error) {
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (self.submissionCompletionBlock) {
            self.submissionCompletionBlock(submission, error);
        }
    }];
}



@end
