//
//  CBIAnnouncementViewModel.h
//  iCanvas
//
//  Created by nlambson on 1/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBIDiscussionTopicViewModel.h"

@interface CBIAnnouncementViewModel : CBIColorfulViewModel <CBIDiscussionTopicViewModel>
@property (nonatomic) NSDate *date;
@end