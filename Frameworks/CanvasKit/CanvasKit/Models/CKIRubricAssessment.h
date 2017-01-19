//
//  CKIRubricAssessment.h
//  CanvasKit
//
//  Created by Brandon Pluim on 8/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKIModel.h"

@interface CKIRubricAssessment : CKIModel

@property (nonatomic, strong) NSArray *ratings;

- (NSDictionary *)parametersDictionary;

@end
