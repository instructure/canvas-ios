//
//  CKIPollSession.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIPollSession : CKIModel

@property (nonatomic) BOOL isPublished;

@property (nonatomic) BOOL hasPublicResults;

@property (nonatomic, copy) NSString *courseID;

@property (nonatomic, copy) NSString *sectionID;

@property (nonatomic, copy) NSString *pollID;

@property (nonatomic, copy) NSDate *created;

@property (nonatomic, copy) NSDictionary *results;

@property (nonatomic) BOOL hasSubmitted;

@property (nonatomic, copy) NSArray *submissions;

@end
