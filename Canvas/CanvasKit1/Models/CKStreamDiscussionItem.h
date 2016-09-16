//
//  CKStreamDiscussionItem.h
//  CanvasKit
//
//  Created by Mark Suman on 8/27/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamItem.h"

@interface CKStreamDiscussionItem : CKStreamItem

@property (nonatomic, assign) uint64_t discussionTopicId;
@property (nonatomic, assign) int totalRootEntries;
@property (nonatomic, strong) NSArray *rootEntries;

- (NSDictionary *)latestEntry;

@end
