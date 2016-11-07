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
    
    

#import "CBINotificationTableViewModel.h"
#import "CBINotificationViewModel.h"
#import "EXTScope.h"
@import CanvasKeymaster;

@interface CBINotificationTableViewModel () 

@end

@implementation CBINotificationTableViewModel
@synthesize collectionController;

- (id)init
{
    static NSCalendar *cal;
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    static NSInteger today;
    dispatch_once(&onceToken, ^{
        cal = [NSCalendar currentCalendar];
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterLongStyle;
        
        NSDateComponents *todayComponents = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        today = todayComponents.year * 10000 + todayComponents.month * 100 + todayComponents.day;
    });
    
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(CBINotificationViewModel *notification) {
            NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:notification.updatedAt];
            NSInteger thisMessagesDay = components.year *10000 + components.month * 100 + components.day;
            return @(today - thisMessagesDay);
        } groupTitleBlock:^(CBINotificationViewModel *notification) {
            return [dateFormatter stringFromDate:notification.updatedAt];
        } sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    }
    return self;
}

- (RACSignal *)refreshViewModelsSignal
{
    return [[[CKIClient currentClient] fetchActivityStreamForContext:(self.model ?: CKIRootContext)] map:^id(NSArray *streamItems) {
        return [[[streamItems.rac_sequence filter:^BOOL(id model) {
            return ![model isKindOfClass:[CKIActivityStreamConversationItem class]];
        }] map:^id(CKIActivityStreamItem *streamItem) {
            CBINotificationViewModel *viewModel = [CBINotificationViewModel new];
            viewModel.model = streamItem;
            return viewModel;
        }] array];
    }];
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulSubtitleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
    tableViewController.tableView.rowHeight = 50;
}

@end
