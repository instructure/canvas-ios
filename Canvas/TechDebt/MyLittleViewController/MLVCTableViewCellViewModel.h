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

#import <UIKit/UIKit.h>

@class MLVCTableViewController;

@protocol MLVCTableViewCellViewModel <NSObject>
- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)tableViewController:(MLVCTableViewController *)controller shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)tableViewController:(MLVCTableViewController *)controller willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableViewController:(MLVCTableViewController *)controller canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewController:(MLVCTableViewController *)tableViewController commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)tableViewController:(MLVCTableViewController *)tableViewController titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
