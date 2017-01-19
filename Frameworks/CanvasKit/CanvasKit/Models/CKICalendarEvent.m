//
//  CalendarEvent.m
//  CanvasKit
//
//  Created by rroberts on 9/17/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKICalendarEvent.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKICalendarEvent
@synthesize description;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"title": @"title"
                               ,@"startAt": @"start_at"
                               ,@"endAt": @"end_at"
                               ,@"description": @"description"
                               ,@"locationName": @"location_name"
                               ,@"locationAddress": @"location_address"
                               ,@"contextCode": @"context_code"
                               ,@"workflowState": @"workflow_state"
                               ,@"hidden": @"hidden"
                               ,@"parentEventID": @"parent_event_id"
                               ,@"childEventsCount": @"child_events_count"
                               ,@"childEvents": @"child_events"
                               ,@"url": @"url"
                               ,@"htmlURL": @"html_url"
                               ,@"allDayDate": @"all_day_date"
                               ,@"allDay": @"all_day"
                               ,@"createdAt": @"created_at"
                               ,@"updatedAt": @"updated_at"
                               ,@"appointmentGroupID": @"appointment_group_id"
                               ,@"appointmentGroupURL": @"appointment_group_url"
                               ,@"ownReservation": @"own_reservation"
                               };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)appointmentGroupURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)htmlURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)parentEventIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)appointmentGroupIDJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

+ (NSValueTransformer *)startAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)endAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)createdAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

+ (NSValueTransformer *)allDayDateJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKIDateTransformerName];
}

- (NSString *)path
{
    return [[CKIRootContext.path stringByAppendingPathComponent:@"calendar_events"] stringByAppendingPathComponent:self.id];
}
@end
