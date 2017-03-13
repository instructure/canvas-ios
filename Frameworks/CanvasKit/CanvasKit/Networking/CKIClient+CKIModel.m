//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
