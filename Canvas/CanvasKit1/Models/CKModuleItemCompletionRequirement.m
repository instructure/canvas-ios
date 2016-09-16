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