//
//  CKStreamMessageItem.h
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamItem.h"

@interface CKStreamMessageItem : CKStreamItem

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) uint64_t assignmentId;
@property (nonatomic, assign) uint64_t submissionId;
@property (nonatomic, assign) uint64_t calendarEventId;

@end
