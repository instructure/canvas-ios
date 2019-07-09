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

@interface CKUploadProgressToolbar : UIView

@property (copy) NSString *uploadCompleteText;
@property (copy) NSString *uploadInProgressText;
@property (copy) NSString *cancelText;

// Clients set this to add a cancel button
@property (nonatomic, copy) void (^cancelBlock)(void);

+ (CGFloat)preferredHeight;

- (void)cancel;
- (void)updateProgressViewWithProgress:(float)progress;
- (void)updateProgressViewWithIndeterminateProgress;
- (void)transitionToUploadCompletedWithError:(NSError *)error completion:(dispatch_block_t)completion;
- (void)showMessage:(NSString *)message;
- (void)hideMessageWithCompletionBlock:(dispatch_block_t)completionBlock;

@end
