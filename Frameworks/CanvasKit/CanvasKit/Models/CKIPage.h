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

#import "CKILockableModel.h"

@class CKIUser;

@interface CKIPage : CKILockableModel

/**
 The title of the page.
 */
@property (nonatomic, copy) NSString *title;

/**
 The date the page was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 The date the page was last updated.
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 This page is hidden from students.
 
 @note Students will never see this true; pages hidden
 from them will be omitted from results
 */
@property (nonatomic) BOOL hideFromStudents;

/**
 The user that last edited this page.
 */
@property (nonatomic, readonly) CKIUser *lastEditedBy;

@property (nonatomic) BOOL published;

@property (nonatomic) BOOL frontPage;

@end
