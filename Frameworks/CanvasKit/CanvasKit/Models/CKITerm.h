//
//  CKITerm.h
//  CanvasKit
//
//  Created by derrick on 11/21/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKITerm : CKIModel
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *startAt;
@property (nonatomic) NSDate *endAt;
@end

