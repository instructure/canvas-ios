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
    
    

#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIColorfulCell.h"
#import "Router.h"
#import "CBILog.h"

@implementation CBIColorfulViewModel (CellViewModel)

- (UITableViewCell *)tableViewController:(UITableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIColorfulCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIColorfulCell"];
    cell.viewModel = self;
    return cell;
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"didSelectRowAtIndexPath - %@ : model : %@", NSStringFromClass([self class]), NSStringFromClass([self.model class]));
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        controller.tableView.userInteractionEnabled = NO;
    }
    [[Router sharedRouter] routeFromController:controller toViewModel:self];
}

@end
