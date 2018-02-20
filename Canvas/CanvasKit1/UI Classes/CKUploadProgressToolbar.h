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
