//
// Created by Brandon Pluim on 3/3/15.
// Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CKIAccountDomain.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"
#import "NSValueTransformer+CKIPredefinedTransformerAdditions.h"

@implementation CKIAccountDomain

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
            @"name": @"name"
            ,@"domain": @"domain"
            ,@"distance": @"distance"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)distanceJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:CKINumberStringTransformerName];
}

- (NSString *)path
{
    return CKIRootContext.path;
}

+ (CKIAccountDomain *)canvasNetSchool {
    CKIAccountDomain *canvasNetSchool = [CKIAccountDomain new];
    canvasNetSchool.name = @"Canvas Network";
    canvasNetSchool.domain = @"learn.canvas.net";
    canvasNetSchool.distance = @(0);
    return canvasNetSchool;
}

+ (CKIAccountDomain *)cantFindSchool {
    CKIAccountDomain *canvasNetSchool = [CKIAccountDomain new];
    canvasNetSchool.name = @"Can't find your school?";
    return canvasNetSchool;
}

+ (NSArray *)developmentSchools {
    NSArray *devDomains = @[@"mobiledev", @"mobileqa", @"mobileqat"];
    
    __block NSMutableArray *devSchools = [NSMutableArray array];
    [devDomains enumerateObjectsUsingBlock:^(NSString *domain, NSUInteger idx, BOOL *stop) {
        CKIAccountDomain *canvasNetSchool = [CKIAccountDomain new];
        canvasNetSchool.name = domain;
        canvasNetSchool.domain = domain;
        canvasNetSchool.distance = @(0);
        [devSchools addObject:canvasNetSchool];
    }];
    
    return devSchools;
}


@end