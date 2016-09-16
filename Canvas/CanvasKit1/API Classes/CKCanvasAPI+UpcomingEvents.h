//
//  CKCanvasAPI+UpcomingEvents.h
//  CanvasKit
//
//  Created by Miles Wright on 7/19/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"

@interface CKCanvasAPI (UpcomingEvents)

- (void)getUpcomingEventsWithBlock:(CKArrayBlock)block;

@end
