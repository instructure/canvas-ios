//
//  CKIClient+CKILiveAssessmentResult.h
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKILiveAssessment;

@interface CKIClient (CKILiveAssessmentResult)
- (RACSignal *)createResults:(NSArray *)results forLiveAssessment:(CKILiveAssessment *)assessment;
@end
