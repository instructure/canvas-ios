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
            @"navigationButtonColor": @"ic-brand-global-nav-ic-icon-svg-fill",
            @"navigationTextColor": @"ic-brand-global-nav-menu-item__text-color",
            @"headerImageURL": @"ic-brand-header-image",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

@end
