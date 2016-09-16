//
//  CBISyllabusViewModel.h
//  iCanvas
//
//  Created by nlambson on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@class CKICourse;

@interface CBISyllabusViewModel : CBIColorfulViewModel
@property (nonatomic) CKICourse *model;
@property (nonatomic) NSDate *syllabusDate;
@property (nonatomic) NSInteger index;
@end
