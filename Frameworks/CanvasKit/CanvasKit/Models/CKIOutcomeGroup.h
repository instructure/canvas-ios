//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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