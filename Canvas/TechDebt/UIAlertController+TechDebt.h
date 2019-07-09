//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

@interface UIAlertController (Show)

- (void)show;
- (void)show:(void(^)(void))completion;

// Shows an alert with a title, message and dismiss message
// The alert is shown on the next tick of the run loop, so you the caller can make any configurations if needed
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

// Handler is called when the basic dismiss button is selected
+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void(^)(void))handler;

@end
