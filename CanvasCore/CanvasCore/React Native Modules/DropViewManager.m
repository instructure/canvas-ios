//
// Copyright (C) 2017-present Instructure, Inc.
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

#import "DropViewManager.h"
#import <React/RCTBridge.h>
#import <React/RCTView.h>

@interface DropView: RCTView <UIDropInteractionDelegate>

@end

@implementation DropViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[DropView alloc] init];
}

@end

@implementation DropView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (@available(iOS 11.0, *)) {
        UIDropInteraction *drop = [[UIDropInteraction alloc] initWithDelegate:self];
        [self addInteraction:drop];
    } else {}
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    NSLog(@"%@", session);
    
//    NSProgress *progess = [session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
//        NSLog(@"%@", objects);
//    }];
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    NSLog(@"%@", session);
    if (@available(iOS 11.0, *)) {
        UIDropProposal *proposal = [[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
        return proposal;
    } else {
        return nil;
    }
}

- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    return NO;
    //return [session canLoadObjectsOfClass:[UIImage class]];
}

@end
