//
//  CBIAddSubmissionCommentViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIAddSubmissionCommentViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIAddSubmissionCommentCell.h"
#import "CBIStudentSubmissionViewController.h"
#import "CBIResizableTextView.h"
#import "CBILog.h"

@interface CBIAddSubmissionCommentViewModel ()
@property (nonatomic) CBIAddSubmissionCommentCell *cell;
@end

@implementation CBIAddSubmissionCommentViewModel

- (UITableViewCell *)tableViewController:(CBIStudentSubmissionViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(controller, self);
    if (self.cell == nil) {
        self.cell = [[UINib nibWithNibName:@"CBIAddSubmissionCommentCell" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:nil options:nil].firstObject;
        
        self.cell.sendButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(controller, self);
            if (self.isPostingComment == NO) {
                self.isPostingComment = YES;
                NSString *text = self.cell.resizeableTextView.text;
                [controller submitComment:text onSuccess:^{
                    self.isPostingComment = NO;
                    DDLogVerbose(@"Sent comment - %@",NSStringFromClass([self class]));
                } onFailure:^{
                    self.isPostingComment = NO;
                    DDLogVerbose(@"Failed to send comment - %@", NSStringFromClass([self class]));
                }];
            } else {
                DDLogVerbose(@"User tapped send while already attempting to send. Tap happy? - %@", NSStringFromClass([self class]));
            }
            return [RACSignal empty];
        }];
        
        [self.cell.attachButton addTarget:controller action:@selector(chooseMediaComment:) forControlEvents:UIControlEventTouchUpInside];

        RAC(self, cell.tintColor) = RACObserve(self, tintColor);
        self.cell.viewModel = self;
    }
    
    [RACObserve(self, cell.height) subscribeNext:^(id x) {
        if ([x floatValue] <= 0) {
            return;
        }
        @strongify(controller);
        [controller.tableView beginUpdates];
        [controller.tableView endUpdates];
    }];
    
    return self.cell;
}

-(NSIndexPath *)tableViewController:(MLVCTableViewController *)controller willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
