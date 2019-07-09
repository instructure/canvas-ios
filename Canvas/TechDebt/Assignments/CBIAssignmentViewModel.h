//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import "CBILockableViewModel.h"
#import <TechDebt/MyLittleViewController.h>

@protocol CBISubmissionsViewModel <MLVCTableViewModel>
- (UIViewController *)createViewController;
@end

@class CKIAssignment;
@interface CBIAssignmentViewModel : CBILockableViewModel

@property (nonatomic, strong) CKIAssignment *model;
@property (nonatomic, assign) int index;

@property (nonatomic) NSDate *syllabusDate;
@property (nonatomic) NSDate *dueAt;

- (RACSignal *)fetchSubmissionsViewModel;

@end
