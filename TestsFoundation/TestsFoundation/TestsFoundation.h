//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

#import <UIKit/UIKit.h>

#include <XCTest/XCTest.h>
@interface XCUIElementQuery ()
- (NSArray<XCUIElementSnapshot> *) allMatchingSnapshotsWithError:(NSError **)err;
@end


//! Project version number for TestsFoundation.
FOUNDATION_EXPORT double TestsFoundationVersionNumber;

//! Project version string for TestsFoundation.
FOUNDATION_EXPORT const unsigned char TestsFoundationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TestsFoundation/PublicHeader.h>
