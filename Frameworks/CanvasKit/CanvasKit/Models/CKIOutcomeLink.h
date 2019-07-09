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
