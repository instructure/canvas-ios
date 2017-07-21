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
@property(nonatomic, copy) NSString *navigationBackground;
@property(nonatomic, copy) NSString *navigationButtonColor;
@property(nonatomic, copy) NSString *navigationTextColor;
@property(nonatomic, copy) NSString *headerImageURL;

@end


