
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
    
    

#import "CKAlertViewWithBlocks.h"

@interface CKAlertViewWithBlocks () <UIAlertViewDelegate>
@end

@implementation CKAlertViewWithBlocks {
    NSMutableDictionary *blocks;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        blocks = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler {
    int buttonIndex = [self addButtonWithTitle:title];
    NSNumber *buttonNumber = @(buttonIndex);
    
    blocks[buttonNumber] = [handler copy];
}


- (void)addCancelButtonWithTitle:(NSString *)title {
    int buttonIndex = [self addButtonWithTitle:title];
    self.cancelButtonIndex = buttonIndex;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSNumber *indexNumber = @(buttonIndex);
    
    void (^block)(void) = blocks[indexNumber];
    
    if (block) {
        block();
    }
    [blocks removeAllObjects];
}

@end
