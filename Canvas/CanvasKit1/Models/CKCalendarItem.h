//
//  CKCalendarItem.h
//  CanvasKit
//
//  Created by Mark Suman on 10/13/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKAssignment, CKCourse;

@interface CKCalendarItem : CKModelObject

@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, assign) uint64_t typeId;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) CKAssignment *assignment;
@property (nonatomic, strong) NSString *contextCode;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, strong) CKCourse *course;
@property (nonatomic, strong) NSArray *actionPath;

- (id)initWithInfo:(NSDictionary *)info;
- (void)updateWithInfo:(NSDictionary *)info;

- (void)populateActionPath;

@end
