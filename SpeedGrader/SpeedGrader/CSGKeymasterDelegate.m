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
// CSGKeymasterDelegate.m
// Created by Jason Larsen on 4/28/14.
//

#import "CSGKeymasterDelegate.h"

@interface CSGKeymasterDelegate ()

@end

@implementation CSGKeymasterDelegate

@synthesize logFilePath;

- (NSString *)appNameForMobileVerify
{
    return @"SpeedGrader";
}

- (UIView *)backgroundViewForDomainPicker
{
    UIImage *backgroundImage = [UIImage imageNamed:@"domain_picker_bg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    return backgroundImageView;
}

- (UIImage *)logoForDomainPicker
{
    return [UIImage imageNamed:@"logo"];
}


@end