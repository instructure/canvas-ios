//
//  CKILiveAssessmentResult.h
//  CanvasKit
//
//  Created by Derrick Hathaway on 6/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@class CKILiveAssessment;

@interface CKILiveAssessmentResult : CKIModel <MTLJSONSerializing>
@property (nonatomic) BOOL passed;
@property (nonatomic) NSDate *assessedAt;
@property (nonatomic) NSString *assessedUserID;
@property (nonatomic) NSString *assessorUserID;

@property (nonatomic) CKILiveAssessment *context;
@end
