//
//  CKCanvasAPI+UpcomingEvents.m
//  CanvasKit
//
//  Created by Miles Wright on 7/19/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI+UpcomingEvents.h"

#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"
#import "CKCalendarItem.h"

@implementation CKCanvasAPI (UpcomingEvents)

- (void)getUpcomingEventsWithBlock:(CKArrayBlock)block
{
    NSString * urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/upcoming_events", self.apiProtocol, self.hostname];
    
    NSURL * url = [NSURL URLWithString:urlString];

    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse * apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *newUpcomingEvents = [apiResponse JSONValue];
                  NSMutableArray *upcomingEvents = [NSMutableArray array];
                  
                  for (NSDictionary *upcomingEventInfo in newUpcomingEvents) {
                      CKCalendarItem *calendarItem = [[CKCalendarItem alloc] initWithInfo:upcomingEventInfo];
                      [upcomingEvents addObject:calendarItem];
                  }
                  block(nil, isFinalValue, upcomingEvents);
              }];
}

@end
