//
//  CKIBrand.m
//  CanvasKit
//
//  Created by Garrett Richards on 3/9/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "CKIBrand.h"

@implementation CKIBrand
@synthesize description;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
            @"primaryColor": @"ic-brand-primary",
            @"fontColorDark": @"ic-brand-font-color-dark",
            @"fontColorLight": @"ic-brand-font-color-light",
            @"linkColor": @"ic-link-color",
            @"primaryButtonBackgroundColor": @"ic-brand-button--primary-bgd",
            @"primaryButtonTextColor": @"ic-brand-button--primary-text",
            @"secondaryButtonBackgroundColor": @"ic-brand-button--secondary-bgd",
            @"secondaryButtonTextColor": @"ic-brand-button--secondary-text",
            @"navigationBackground": @"ic-brand-global-nav-bgd",
            @"headerImageURL": @"ic-brand-header-image",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

@end
