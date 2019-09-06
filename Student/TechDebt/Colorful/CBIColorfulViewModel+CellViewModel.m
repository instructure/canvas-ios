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

#import <CanvasKit1/NSString+CKAdditions.h>
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIColorfulCell.h"
#import "Routing.h"

@implementation CBIColorfulViewModel (CellViewModel)

- (UITableViewCell *)tableViewController:(UITableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIColorfulCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIColorfulCell"];
    cell.viewModel = self;
    return cell;
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        controller.tableView.userInteractionEnabled = NO;
    }
    NSURL *url = [NSURL URLWithString:[self.model.path realURLEncodedString]];
    Routing.routeToURL(url, controller);
}

@end
