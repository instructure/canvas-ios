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

//
// CSGCourseCell.h
// Created by Jason Larsen on 4/30/14.
//

#import <Foundation/Foundation.h>

@class CSGBadgeView;

@interface CSGCourseCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *courseNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *courseCodeLabel;
@property (nonatomic, weak) IBOutlet CSGBadgeView *needsGradingBadgeView;
@property (nonatomic, weak) IBOutlet UIView *courseColorView;
@property (nonatomic, weak) IBOutlet UIView *contentContainerView;

@property (nonatomic, strong) CKICourse *course;

- (void)didPickColor:(UIColor *)color;

@end