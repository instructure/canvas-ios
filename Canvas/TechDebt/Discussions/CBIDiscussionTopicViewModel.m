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
    
    

#import "CBIDiscussionTopicViewModel.h"
#import "Router.h"
#import "ThreadedDiscussionViewController.h"
#import "CBIDiscussionTopicCell.h"

@implementation CBIDiscussionTopicViewModel
@synthesize model=_model, index=_index, position=_position;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, lockedItemName) = RACObserve(self, model.title);
        RAC(self, subtitle) = [RACObserve(self, model.lastReplyAt) map:^(NSDate * value) {
            static NSDateFormatter *formatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterShortStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
            });
            if (value == nil) {
                return @"";
            }
            return [formatter stringFromDate:value];
        }];
    }
    return self;
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIDiscussionTopicCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIDiscussionTopicCell"];
    cell.viewModel = self;
    return cell;
}

@end
