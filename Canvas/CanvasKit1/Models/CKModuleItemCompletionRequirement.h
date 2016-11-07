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
    
    

//
// Created by jasonl on 3/20/13.
//

#import <Foundation/Foundation.h>

typedef enum CKModuleItemCompletionRequirementType {
    CKModuleItemCompletionRequirementTypeMustView,
    CKModuleItemCompletionRequirementTypeMustSubmit,
    CKModuleItemCompletionRequirementTypeMustContribute,
    CKModuleItemCompletionRequirementTypeMinScore,
} CKModuleItemCompletionRequirementType;

@interface CKModuleItemCompletionRequirement : NSObject
- (id)initWithInfo:(NSDictionary *)info;
+ (id)requirementWithInfo:(NSMutableDictionary *)info;

@property (readonly) CKModuleItemCompletionRequirementType type;
@property (readonly) float minScore; // only valid when of type MinScore
@property (readonly) BOOL completed; // only valid if user is a student
@end