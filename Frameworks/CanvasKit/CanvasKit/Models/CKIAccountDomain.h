//
// Created by Brandon Pluim on 3/3/15.
// Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CKIModel.h"


@interface CKIAccountDomain : CKIModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, strong) NSNumber *distance;

+ (CKIAccountDomain *)canvasNetSchool;
+ (CKIAccountDomain *)cantFindSchool;
+ (NSArray *)developmentSchools;

@end