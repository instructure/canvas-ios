//
//  DropViewManager.m
//  CanvasCore
//
//  Created by Layne Moseley on 10/25/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
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
    UIDragInteraction *drop = [[UIDropInteraction alloc] initWithDelegate:self];
    [self addInteraction:drop];
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    NSLog(@"%@", session);
    
    NSProgress *progess = [session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
        NSLog(@"%@", objects);
    }];
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    NSLog(@"%@", session);
    UIDropProposal *proposal = [[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
    return proposal;
}

- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    return NO;
    //return [session canLoadObjectsOfClass:[UIImage class]];
}

@end
