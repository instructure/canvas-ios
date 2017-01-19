//
//  CKIPollChoice.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

@interface CKIPollChoice : CKIModel

@property (nonatomic) BOOL isCorrect;

@property (nonatomic, copy) NSString *text;

@property (nonatomic) NSNumber *pollID;

@property (nonatomic) NSNumber *index;

@end
