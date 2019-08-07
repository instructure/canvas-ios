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

#import "CBIAddSubmissionCommentViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIAddSubmissionCommentCell.h"
#import "CBIStudentSubmissionViewController.h"
#import "CBIResizableTextView.h"

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
                } onFailure:^{
                    self.isPostingComment = NO;
                }];
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
