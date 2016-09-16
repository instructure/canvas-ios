//
//  CBITextInputViewController.m
//  iCanvas
//
//  Created by derrick on 2/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISubmissionInputViewController.h"
#import "CBISubmissionInputView.h"
#import "CKCanvasAPI+RealmAssignmentBridge.h"
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
    [canvasAPI postHTML:comment asSubmissionForAssignment:assignment session:TheKeymaster.currentClient.authSession completionBlock:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
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
