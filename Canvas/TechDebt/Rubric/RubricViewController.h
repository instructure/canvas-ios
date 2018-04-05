//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import <UIKit/UIKit.h>

@class CKSubmission, CKAssignment, CKCanvasAPI, CKContextInfo;

@interface RubricViewController : UIViewController

/** @name Initializers */

- (id)init;

/**
 Designated initializer.
 */
- (id)initWithSubmission:(CKSubmission *)aSubmission;

/** @name Required properties */

/**
 The canvas API is required unless the assignment and submission
 are both provided.
 */
@property CKCanvasAPI *canvasAPI;

/**
 The assignment id may be provided, if the assignment is not
 available in the contstructing context.
 */
@property (nonatomic) uint64_t assignmentId;

/**
 If the assignmentId is provided, then the contextInfo must
 also be provided.
 */
@property CKContextInfo *contextInfo;

/**
 Either the assignment or the assignment id must be provided.
 */
@property (nonatomic) CKAssignment *assignment;

/** @name Optional properties */

/**
 The submission may be provided if it is available in the
 constructing context.
 */
@property (nonatomic) CKSubmission *submission;

@property (nonatomic, readonly) UITableView *rubricTableView;

@property (nonatomic) NSString * pageViewName;
@end
