//
//  CBIDiscussionTopicViewModel.h
//  iCanvas
//
//  Created by derrick on 12/18/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBILockableViewModel.h"

@protocol CBIDiscussionTopicViewModel <NSObject>
@property (nonatomic) CKIDiscussionTopic *model;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger position;
@end

@interface CBIDiscussionTopicViewModel : CBILockableViewModel <CBIDiscussionTopicViewModel>
@end
