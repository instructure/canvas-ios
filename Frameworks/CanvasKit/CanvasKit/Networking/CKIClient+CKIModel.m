//
//  CKIClient+CKIModel.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIModel.h"
#import "CKIModel.h"

@implementation CKIClient (CKIModel)

- (RACSignal *)refreshModel:(CKIModel *)model parameters:(NSDictionary *)parameters
{
    RACSignal *mergeSignal = [[self fetchResponseAtPath:model.path parameters:parameters modelClass:[model class] context:model.context] replay];
    
    [mergeSignal subscribeNext:^(CKIModel *updatedObject) {
        [model mergeValuesForKeysFromModel:updatedObject];
    }];
    
    return [mergeSignal map:^(CKIModel *updatedObject) {
        return model;
    }];
}

@end
