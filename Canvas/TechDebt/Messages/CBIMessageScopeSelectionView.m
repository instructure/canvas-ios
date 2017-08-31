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
