//
//  CKIClient+CKILiveAssessment.h
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@interface CKIClient (CKILiveAssessment)
- (RACSignal *)createLiveAssessments:(NSArray *)assessments;
@end
