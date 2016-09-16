//
//  CBIExternalToolViewModel.h
//  iCanvas
//
//  Created by Derrick Hathaway on 3/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@interface CBIExternalToolViewModel : CBIColorfulViewModel
@property (nonatomic) CKIExternalTool *model;
@property (nonatomic) NSInteger index;
@end
