//
//  CKIClient+CKIActivityStreamItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class RACSignal;
@class CKICourse;

@interface CKIClient (CKIActivityStreamItem)


/**
 Fetches the activity stream for the current user.
 
 @return A signal that will deliver pages of stream items.
 */
- (RACSignal *)fetchActivityStream;

/**
 Fetches the activity stream for the given context.
 
 @param context the context for the stream i.e. a course
 @return a signal of pages (NSArray *) of stream items.
 */
- (RACSignal *)fetchActivityStreamForContext:(id<CKIContext>)context;

@end
