//
//  CKStreamSubmissionItem.h
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamItem.h"

@interface CKStreamSubmissionItem : CKStreamItem

@property (nonatomic, strong) NSString *grade;
@property (nonatomic, assign) double score;
@property (nonatomic, strong) NSDictionary *assignmentDict;
@property (nonatomic, strong) NSArray *submissionComments;

- (NSDictionary *)latestComment;

@end
