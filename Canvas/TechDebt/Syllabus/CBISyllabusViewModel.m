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
    
    

#import "CBISyllabusViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "UIImage+TechDebt.h"
#import "CKCourse.h"

@implementation CBISyllabusViewModel

@dynamic model;

- (UIImage *)imageForTypeName:(NSString *)typeString
{
    return [[UIImage techDebtImageNamed:@"icon_syllabus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Syllabus", @"Title for Syllabus screen");
        self.icon = [self imageForTypeName:nil];
        self.syllabusDate = [NSDate date];
        self.viewControllerTitle = self.name;
    }
    return self;
}

@end
