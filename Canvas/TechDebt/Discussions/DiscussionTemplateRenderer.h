//
//  DiscussionTemplateRenderer.h
//  iCanvas
//
//  Created by BJ Homer on 11/8/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKDiscussionTopic;
@class CKDiscussionEntry;

@interface DiscussionTemplateRenderer : NSObject

- (NSString *)htmlStringForThreadedEntry:(CKDiscussionEntry *)entry;

@end
