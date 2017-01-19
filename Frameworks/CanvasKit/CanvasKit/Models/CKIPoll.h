//
//  CKIPoll.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIPoll : CKIModel

/*
 The title of the poll
 */
@property (nonatomic, copy) NSString *question;

@property (nonatomic, copy) NSDate *created;


@end
