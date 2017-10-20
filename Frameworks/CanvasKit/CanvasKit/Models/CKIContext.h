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

#import <Foundation/Foundation.h>

@protocol CKIContext <NSObject>

/**
 The parent object of this object, if any.
 
 e.g. The parent object of a Submission is the Assignment object
 that was used to fetch it.
 */
@property (nonatomic) id<CKIContext> context;

/**
 The api path of the object.
 
 e.g. An assignment's path might be /api/v1/courses/823991/assignments/322
 */
@property (nonatomic, readonly) NSString *path;

@end

#import "CKIAPIV1.h"
#define CKIRootContext [CKIAPIV1 context]
