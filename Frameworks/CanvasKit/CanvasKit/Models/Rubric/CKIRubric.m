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

//
// CKIRubric.m
// Created by Jason Larsen on 5/20/14.
//

#import "CKIRubric.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@interface CKIRubric ()
@end

@implementation CKIRubric

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSDictionary *keyPaths = @{
            @"title": @"title",
            @"pointsPossible": @"points_possible",
            @"allowsFreeFormCriterionComments": @"free_form_criterion_comments"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

@end