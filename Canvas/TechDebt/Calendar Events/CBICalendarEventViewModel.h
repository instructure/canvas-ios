//
//  CBICalendarEventViewModel.h
//  iCanvas
//
//  Created by nlambson on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@class CKICalendarEvent;

@interface CBICalendarEventViewModel : CBIColorfulViewModel
@property (nonatomic) CKICalendarEvent *model;
@property (nonatomic) NSDate *syllabusDate;
@property (nonatomic) NSInteger index;
@end
