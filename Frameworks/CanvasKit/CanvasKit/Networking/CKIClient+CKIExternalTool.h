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
@class CKIExternalTool;
@class RACSignal;

@interface CKIClient (CKIExternalTool)

/**
 Fetches all of the external tools for a course
 */
- (RACSignal *)fetchExternalToolsForCourse:(CKICourse *)course;

/**
 Get a sessionless launch url for an external tool with id.
 */
- (RACSignal *)fetchSessionlessLaunchURLWithURL:(NSString *)url course:(CKICourse *)course;

/**
 Get a single external tool
 */
- (RACSignal *)fetchExternalToolForCourseWithExternalToolID:(NSString *)externalToolID course:(CKICourse *)course;

@end
