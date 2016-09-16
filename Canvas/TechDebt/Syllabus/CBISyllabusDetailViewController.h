//
//  CBISyllabusDetailViewController.h
//  iCanvas
//
//  Created by nlambson on 1/16/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISyllabusViewModel.h"
#import <CanvasKit1/CanvasKit1.h>

@interface CBISyllabusDetailViewController : UIViewController
@property (nonatomic) CBISyllabusViewModel *viewModel;
@property (nonatomic, strong) CKCourse *course;
@end
