//
//  CKCommentAttachment.h
//  CanvasKit
//
//  Created by Zach Wily on 6/4/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKAttachment.h"

@class CKSubmissionComment;

@interface CKCommentAttachment : CKAttachment

@property (nonatomic, strong) CKSubmissionComment *comment;

@end