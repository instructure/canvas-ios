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

#import "CKActionSheetWithBlocks.h"

//External Constants
NSString * const CKActionSheetDidShowNotification = @"CKAlertViewDidShowNotification";

@interface CKActionSheetWithBlocks () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableDictionary *blocks;
@end

@implementation CKActionSheetWithBlocks {
}

@synthesize dismissalBlock;

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    self.title = title;
    if (self) {
        self.blocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)showfromViewController:(UIViewController *_Nullable)viewController
{
    [viewController presentViewController: self animated: YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CKActionSheetDidShowNotification object:self];
}

- (void)addButtonWithTitle:(NSString *_Nullable)title handler:(void (^ _Nullable )(void))handler
{
    UIAlertAction * action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler) { handler(); }
    }];

    [self addAction: action];
}

- (void)addCancelButtonWithTitle:(NSString *_Nullable)title {
    __weak CKActionSheetWithBlocks *weakSelf = self;
    UIAlertAction * action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.dismissalBlock) {
            weakSelf.dismissalBlock();
        }
        [weakSelf.blocks removeAllObjects];
    }];
    [self addAction: action];
}
@end
