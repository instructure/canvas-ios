//
//  CKCanvasAPI+ActivityStream.h
//  CanvasKit
//
//  Created by nlambson on 6/11/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"

@interface CKCanvasAPI (ActivityStream)
- (void)fetchActivityStreamSummaryWithBlock:(CKObjectBlock)block;
@end
