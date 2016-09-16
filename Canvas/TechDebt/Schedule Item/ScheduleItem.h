//
//  ScheduleItem.h
//  iCanvas
//
//  Created by Mark Suman on 9/27/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CNVScheduleItemTypeUnknown,
    CNVScheduleItemTypeAssignment,
    CNVScheduleItemTypeCalendar
} CNVScheduleItemType;

@interface ScheduleItem : NSObject

@property (nonatomic) CNVScheduleItemType type;
@property (nonatomic, strong) id itemObject;

@property (readonly) uint64_t ident;
@property (weak,readonly) NSDate *eventDate;
@property (weak,readonly) NSString *title;
@property (weak,readonly) NSString *itemDescription;
@property (weak,readonly) NSString *typeDescription;

- (id)initWithObject:(id)anObject;

- (BOOL)isEqual:(id)object;

@end
