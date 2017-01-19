//
//  CKIActivityStreamAnnouncementItem.h
//  CanvasKit
//
//  Created by Jason Larsen on 11/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIActivityStreamDiscussionTopicItem.h"

@interface CKIActivityStreamAnnouncementItem : CKIActivityStreamDiscussionTopicItem

/**
 The ID of the announcement.
 */
@property (nonatomic, copy)  NSString *announcementID;

@end
