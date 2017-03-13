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

#import "CKIModel.h"

@class CKIOutcomeGroup;
@class CKIOutcome;

@interface CKIOutcomeLink : CKIModel

/**
 The context type of the outcome.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 The context owning the outcome. may be null for global outcomes.
 */
@property (nonatomic, copy) NSString *contextID;

/**
 The URL for fetching/updating the outcome
 */
@property (nonatomic, copy) NSString *url;

/**
 OutcomeGroup object representing the outcome group of this outcome link
 */
@property (nonatomic, copy) CKIOutcomeGroup *outcomeGroup;

/**
 Abbreviated outcome object representing the outcome linked to
 */
@property (nonatomic, copy) CKIOutcome *outcome;

@end
