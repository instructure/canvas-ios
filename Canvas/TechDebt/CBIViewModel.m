//
//  CBIViewModel.m
//  iCanvas
//
//  Created by nlambson on 11/21/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIViewModel.h"
#import "CBILog.h"

@implementation CBIViewModel

+ (instancetype)viewModelForModel:(CKIModel *)model
{
    CBIViewModel *viewModel = [self new];
    viewModel.model = model;
    return viewModel;
}

+ (id (^)(CKIConversation *))modelMappingBlock
{
    return ^(CKIModel *model) {
        return [self viewModelForModel:model];
    };
}

- (void)viewControllerViewDidLoad:(UIViewController *)viewController
{
    DDLogVerbose(@"%@ - viewControllerViewDidLoad", NSStringFromClass([self class]));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{%@ modelClass=%@, modelID=%@}", NSStringFromClass(self.class), NSStringFromClass(self.model.class), self.model.id];
}

@end
