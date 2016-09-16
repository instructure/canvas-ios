//
//  CBINotificationViewModel.h
//  iCanvas
//
//  Created by Jason Larsen on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBIColorfulViewModel.h"
#import "CBIMessageCell.h"

@interface CBINotificationViewModel : CBIColorfulViewModel
@property (nonatomic, strong) CKIActivityStreamItem *model;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDate *updatedAt;
@end
