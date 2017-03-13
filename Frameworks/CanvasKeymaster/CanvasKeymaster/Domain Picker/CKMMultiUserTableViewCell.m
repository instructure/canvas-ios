//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKMMultiUserTableViewCell.h"

@implementation CKMMultiUserTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.backgroundColor =  [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.8f];
    self.selectedBackgroundView = selectedBackgroundView;

    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.deleteButton setImage:[[UIImage imageNamed:@"icon_x_delete" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self.deleteButton setAccessibilityLabel:NSLocalizedString(@"remove user", @"Placeholder for delete icon in Multi User Table View Cell")];
    
    [self.deleteButton setTintColor:[UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1.f]];
}

@end
