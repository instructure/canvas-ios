//
//  CKStreamAnnouncementItem.h
//  CanvasKit
//
//  Created by Mark Suman on 8/11/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamItem.h"

@interface CKStreamAnnouncementItem : CKStreamItem

@property (nonatomic, assign) uint64_t announcementIdent;

- (id)initWithInfo:(NSDictionary *)info;

@end
