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
    
    

#import "CKActionSheetWithBlocks.h"

//External Constants
NSString * const CKActionSheetDidShowNotification = @"CKAlertViewDidShowNotification";

@interface CKActionSheetWithBlocks () <UIActionSheetDelegate>
@end

@implementation CKActionSheetWithBlocks {
    NSMutableDictionary *blocks;
}

@synthesize dismissalBlock;

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        blocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [super showInView:view];
    [[NSNotificationCenter defaultCenter] postNotificationName:CKActionSheetDidShowNotification object:self];
}

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler {
    NSInteger buttonIndex = [super addButtonWithTitle:title];
    if (handler) {
        blocks[@(buttonIndex)] = [handler copy];
    }
}

- (void)addCancelButtonWithTitle:(NSString *)title {
    NSInteger buttonIndex = [super addButtonWithTitle:title];
    self.cancelButtonIndex = buttonIndex;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    void (^handler)(void) = blocks[@(buttonIndex)];
    if (handler) {
        handler();
    }
    [blocks removeAllObjects];
    
    if (dismissalBlock) {
        dismissalBlock();
    }
}

#pragma GCC diagnostic pop

@end
