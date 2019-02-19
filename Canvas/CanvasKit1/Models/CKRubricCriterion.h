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
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKRubric;

@interface CKRubricCriterion : CKModelObject

@property (nonatomic, weak) CKRubric *rubric;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *criterionDescription;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, assign) double points;
@property (strong, nonatomic, readonly) NSMutableArray *ratings;
@property (nonatomic, assign) BOOL useRange;

- (id)initWithInfo:(NSDictionary *)info andRubric:(CKRubric *)aRubric;
- (void)updateWithInfo:(NSDictionary *)info;

@end
