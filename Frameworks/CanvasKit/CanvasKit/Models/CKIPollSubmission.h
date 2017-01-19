//
//  CKIPollSubmission.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIPollSubmission : CKIModel

@property (nonatomic) NSString *pollChoiceID;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSDate *created;

@end