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

/**
 The name for a value transfomer that converts NSNumbers to NSStrings and back.
 */
extern NSString * const CKINumberStringTransformerName;

/**
 The name for a value transfomer that converts NSNumbers or NSStrings to NSStrings.
 */
extern NSString * const CKINumberOrStringToStringTransformerName;

/**
 The name for a value transfomer that converts ISO8601 date-strings to NSDates and back.
 */
extern NSString * const CKIDateTransformerName;

/**
 The name for a value transfomer that converts the dictionary returned by the API into CKIRubricAssessments and back.
 */
extern NSString * const CKIRubricAssessmentTransformerName;
