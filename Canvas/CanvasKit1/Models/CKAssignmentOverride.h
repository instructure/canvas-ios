//
//  CKAssignmentOverride.h
//  CanvasKit
//
//  Created by BJ Homer on 11/16/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@interface CKAssignmentOverride : CKModelObject

@property uint64_t ident;
@property uint64_t assignmentIdent;

// Only one of these three should come from the API; the others will be nil
@property NSArray *studentIdents;
@property uint64_t groupIdent;
@property uint64_t sectionIdent;

@property NSString *title;
@property NSDate *dueDate;
@property NSDate *allDayDate; // nil unless the due date should be treated as only a date, w/o a time.

@property NSDate *unlockAtDate;
@property NSDate *lockAtDate;

- (id)initWithInfo:(NSDictionary *)info;

@end
