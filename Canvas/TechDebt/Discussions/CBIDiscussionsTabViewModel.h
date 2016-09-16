//
//  CBIDiscussionsTabViewModel.h
//  iCanvas
//
//  Created by derrick on 12/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@protocol DiscussionCreationStrategy;

@interface CBIDiscussionsTabViewModel : CBIColorfulViewModel
@property (nonatomic) id<DiscussionCreationStrategy> discussionCreationStrategy;
@property (nonatomic) Class discussionViewModelClass;
@property (nonatomic, readonly) RACSignal *refreshModelSignal;
@property (nonatomic) UIImage *createButtonImage;
@property (nonatomic) RACSignal *canCreateSignal;
@end
