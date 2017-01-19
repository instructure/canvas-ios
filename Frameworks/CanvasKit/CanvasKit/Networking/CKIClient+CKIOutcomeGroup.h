//
//  CKIClient+CKIOutcomeGroup.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKICourse;
@class CKIOutcomeGroup;

@interface CKIClient (CKIOutcomeGroup)

- (RACSignal *)fetchRootOutcomeGroupForCourse:(CKICourse *)course;
- (RACSignal *)fetchOutcomeGroupForCourse:(CKICourse *)course id:(NSString *)identifier;
- (RACSignal *)fetchSubGroupsForOutcomeGroup:(CKIOutcomeGroup *)group;

@end
