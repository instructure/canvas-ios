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

#import "CKIClient.h"

@class CKICourse;

@interface CKIClient (CKIUser)

/**
 Fetch all the users for the current course.
 */
- (RACSignal *)fetchUsersForContext:(id<CKIContext>)context;

/**
 Fetch all the students for the current course.
 */
- (RACSignal *)fetchStudentsForContext:(id<CKIContext>)context;

/**
 Fetch users for the current course filtered by parameters.
 
 @param parameters the parameters for fetching users in the course
 */
- (RACSignal *)fetchUsersWithParameters:(NSDictionary *)parameters context:(id <CKIContext>)context;

- (RACSignal *)fetchCurrentUser;

@end
