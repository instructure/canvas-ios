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

@interface CKIOutcomeGroup : CKIModel

/**
 The title for the outcome group.
 */
@property (nonatomic, copy) NSString *title;

/**
 The description for the outcome group.
 */
@property (nonatomic, copy) NSString *details;

/**
 The context type of the outcome group.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 The context owning the outcome group. may be null for global outcome groups. Omitted in the abbreviated form
 */
@property (nonatomic, copy) NSString *contextID;

/**
 The URL for fetching/updating the outcome group. should be treated as opaque
 */
@property (nonatomic, copy) NSString *url;

/**
 The URL for listing/creating subgroups under the outcome group.
 */
@property (nonatomic, copy) NSString *subgroupsURL;

/**
 The URL for listing/creating outcome links under the outcome group.
 */
@property (nonatomic, copy) NSString *outcomesURL;

/**
 OutcomeGroup object representing the parent group of this outcome group, if any
 */
@property (nonatomic, copy) CKIOutcomeGroup *parent;

@end