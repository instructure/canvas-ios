//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
            @"navigationButtonColorActive": @"ic-brand-global-nav-ic-icon-svg-fill--active",
            @"navigationTextColor": @"ic-brand-global-nav-menu-item__text-color",
            @"navigationTextColorActive": @"ic-brand-global-nav-menu-item__text-color--active",
            @"navigationBadgeBackgroundColor": @"ic-brand-global-nav-menu-item__badge-bgd",
            @"navigationBadgeTextColor": @"ic-brand-global-nav-menu-item__badge-text",
            @"headerImageBackground": @"ic-brand-global-nav-logo-bgd",
            @"headerImageURL": @"ic-brand-header-image",
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

@end
