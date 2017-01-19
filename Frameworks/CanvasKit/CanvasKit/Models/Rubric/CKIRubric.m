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