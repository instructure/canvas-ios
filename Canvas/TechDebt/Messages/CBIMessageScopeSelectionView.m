//
//  CBIMessageScopeSelectionView.m
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageScopeSelectionView.h"

@interface CBIMessageScopeSelectionView ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation CBIMessageScopeSelectionView

- (id)init
{
    self = [[[UINib nibWithNibName:@"CBIMessageScopeSelectionView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:nil options:nil] firstObject];
    self.bounds = CGRectMake(0, 0, 320.f, 44.f);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Inbox", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Unread", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"Archived", nil) forSegmentAtIndex:2];
    [self.segmentedControl setTitle:NSLocalizedString(@"Sent", nil) forSegmentAtIndex:3];
    
    [self.segmentedControl.subviews enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL *stop) {
        [obj.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
                [obj setAdjustsFontSizeToFitWidth:YES];
            }
        }];     
    }];
    
    return self;
}

- (void)setSelectedScope:(CKIConversationScope)selectedScope
{
    _selectedScope = selectedScope;
    self.segmentedControl.selectedSegmentIndex = selectedScope;
}

- (IBAction)scopeChanged:(UISegmentedControl *)sender {
    self.selectedScope = sender.selectedSegmentIndex;
}


@end
