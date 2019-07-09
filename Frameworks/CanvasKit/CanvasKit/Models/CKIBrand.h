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

#import <CanvasKit/CanvasKit.h>

@interface CKIBrand : CKIModel

@property(nonatomic, copy) NSString *primaryColor;
@property(nonatomic, copy) NSString *fontColorDark;
@property(nonatomic, copy) NSString *fontColorLight;
@property(nonatomic, copy) NSString *linkColor;
@property(nonatomic, copy) NSString *primaryButtonBackgroundColor;
@property(nonatomic, copy) NSString *primaryButtonTextColor;
@property(nonatomic, copy) NSString *secondaryButtonBackgroundColor;
@property(nonatomic, copy) NSString *secondaryButtonTextColor;
@property(nonatomic, copy) NSString *navigationBadgeBackgroundColor;
@property(nonatomic, copy) NSString *navigationBadgeTextColor;
@property(nonatomic, copy) NSString *navigationBackground;
@property(nonatomic, copy) NSString *navigationButtonColor;
@property(nonatomic, copy) NSString *navigationButtonColorActive;
@property(nonatomic, copy) NSString *navigationTextColor;
@property(nonatomic, copy) NSString *navigationTextColorActive;
@property(nonatomic, copy) NSString *headerImageBackground;
@property(nonatomic, copy) NSString *headerImageURL;

@end


