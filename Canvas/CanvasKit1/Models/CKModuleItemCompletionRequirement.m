//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

//
// Created by jasonl on 3/20/13.
//


#import "CKModuleItemCompletionRequirement.h"
#import "NSDictionary+CKAdditions.h"


@implementation CKModuleItemCompletionRequirement

- (id)initWithInfo:(NSDictionary *)info {
    if (!info) {
        return nil;
    }

    self = [super init];
    if (self) {

        NSDictionary *dict = [info safeCopy];

        [self setupType:dict];
        _minScore = [dict[@"min_score"] floatValue];
        _completed = [dict[@"completed"] boolValue];
    }
    return self;
}

- (void)setupType:(NSDictionary *)dict {
    NSString *typeString = dict[@"type"];
    if ([typeString isEqualToString:@"must_view"]) {
            _type = CKModuleItemCompletionRequirementTypeMustView;
    }
    else if ([typeString isEqualToString:@"must_submit"]) {
        _type = CKModuleItemCompletionRequirementTypeMustSubmit;
    }
    else if ([typeString isEqualToString:@"must_contribute"]) {
        _type = CKModuleItemCompletionRequirementTypeMustContribute;
    }
    else if ([typeString isEqualToString:@"min_score"]) {
        _type = CKModuleItemCompletionRequirementTypeMinScore;
    }
}

+ (CKModuleItemCompletionRequirement *)requirementWithInfo:(NSMutableDictionary *)info {
    return [[CKModuleItemCompletionRequirement alloc] initWithInfo:info];
}

@end