//
// CBIPeopleViewModel.h
// Created by Jason Larsen on 3/28/14.
//

#import <Foundation/Foundation.h>
#import "CBIColorfulViewModel.h"


@interface CBIPeopleViewModel : CBIColorfulViewModel
@property (nonatomic, strong) CKIUser *model;
@end