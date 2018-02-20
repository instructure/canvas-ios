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
    
    

#import "CBISubmissionCommentViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBISubmissionCommentCell.h"
@import CanvasKeymaster;

static NSString *const CBISubmissionCommentCell_Mine = @"CBISubmissionCommentCell-Mine";
static NSString *const CBISubmissionCommentCell_Theirs = @"CBISubmissionCommentCell-Theirs";
static NSString *const CBISubmissionCommentCell_MyVideo = @"CBISubmissionCommentCell-MyVideo";
static NSString *const CBISubmissionCommentCell_TheirVideo = @"CBISubmissionCommentCell-TheirVideo";
static NSString *const CBISubmissionCommentCell_MyAudio = @"CBISubmissionCommentCell-MyAudio";
static NSString *const CBISubmissionCommentCell_TheirAudio = @"CBISubmissionCommentCell-TheirAudio";

@interface CBISubmissionCommentViewModel ()
@property (nonatomic) NSString *cellReuseID;
@end


@implementation CBISubmissionCommentViewModel

@dynamic model;

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, date) = RACObserve(self, model.createdAt);
        RAC(self, name) = RACObserve(self, model.authorName);
        
        RAC(self, cellReuseID) = [RACObserve(self, model) map:^(CKISubmissionComment *comment) {
            BOOL mine = [comment.authorID isEqualToString:TheKeymaster.currentClient.currentUser.id];
            if (comment.mediaComment) {
                if ([comment.mediaComment.mediaType isEqualToString:CKIMediaCommentMediaTypeAudio]) {
                    return mine ? CBISubmissionCommentCell_MyAudio : CBISubmissionCommentCell_TheirAudio;
                } else {
                    return mine ? CBISubmissionCommentCell_MyVideo : CBISubmissionCommentCell_TheirVideo;
                }
            } else {
                return mine ? CBISubmissionCommentCell_Mine : CBISubmissionCommentCell_Theirs;
            }
        }];
    }
    return self;
}

+ (void)registerCellsForTableView:(UITableView *)tableView {
    for (NSString *reuseIDAndNibName in @[
        CBISubmissionCommentCell_Mine,
        CBISubmissionCommentCell_MyVideo,
        CBISubmissionCommentCell_MyAudio,
        CBISubmissionCommentCell_Theirs,
        CBISubmissionCommentCell_TheirVideo,
        CBISubmissionCommentCell_TheirAudio,
        ]) {
        [tableView registerNib:[UINib nibWithNibName:reuseIDAndNibName bundle:[NSBundle bundleForClass:self]] forCellReuseIdentifier:reuseIDAndNibName];
    }
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSMutableDictionary *calcCellsByReuseID;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calcCellsByReuseID = [NSMutableDictionary dictionary];
    });
    
    CBISubmissionCommentCell *cell = calcCellsByReuseID[self.cellReuseID];
    if (!cell) {
        cell = [controller.tableView dequeueReusableCellWithIdentifier:self.cellReuseID];
        calcCellsByReuseID[self.cellReuseID] = cell;
    }

    cell.bounds = CGRectMake(0, 0, controller.tableView.bounds.size.width, 80.f);
    cell.viewModel = self;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // make room for the separator.
    return height + 1;
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBISubmissionCommentCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:self.cellReuseID forIndexPath:indexPath];
    
    cell.viewModel = self;
    return cell;
}

-(NSIndexPath *)tableViewController:(MLVCTableViewController *)controller willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
