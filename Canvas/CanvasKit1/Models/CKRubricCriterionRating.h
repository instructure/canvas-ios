//
//  CKRubricCriterionRating.h
//  CanvasKit
//
//  Created by Mark Suman on 11/29/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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

- (id)initWithInfo:(NSDictionary *)info andRubricCriterion:(CKRubricCriterion *)aCriterion;
- (id)initWithInfo:(NSDictionary *)info andCriterionIdent:(NSString *)criterionIdent;
- (id)initWithRubricCriterion:(CKRubricCriterion *)aCriterion;
- (void)updateWithInfo:(NSDictionary *)info;

@end
