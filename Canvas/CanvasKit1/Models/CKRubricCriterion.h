//
//  CKRubricCriterion.h
//  CanvasKit
//
//  Created by Mark Suman on 11/29/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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

- (id)initWithInfo:(NSDictionary *)info andRubric:(CKRubric *)aRubric;
- (void)updateWithInfo:(NSDictionary *)info;

@end
