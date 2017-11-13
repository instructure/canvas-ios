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

@class CKRubricCriterion;

@interface CKRubricCriterionRating : CKModelObject <NSCopying>

@property (nonatomic, weak) CKRubricCriterion *criterion;
@property (nonatomic, strong) NSString *criterionId;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *ratingDescription;
@property (nonatomic, assign) double points;
@property (nonatomic, strong) NSString *comments;
@property (readonly) NSString *pointsDescription;

- (id)initWithInfo:(NSDictionary *)info andRubricCriterion:(CKRubricCriterion *)aCriterion;
- (id)initWithInfo:(NSDictionary *)info andCriterionIdent:(NSString *)criterionIdent;
- (id)initWithRubricCriterion:(CKRubricCriterion *)aCriterion;
- (void)updateWithInfo:(NSDictionary *)info;

@end
