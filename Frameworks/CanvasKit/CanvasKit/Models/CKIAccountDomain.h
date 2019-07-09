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

#import "CKIModel.h"

typedef NS_ENUM(NSUInteger, CKIAccountDomainType) {
    CKIAccountDomainTypeNormal,
    CKIAccountDomainTypeCantFindSchool,
    CKIAccountDomainTypeHowDoIFindMySchool,
};

@interface CKIAccountDomain : CKIModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *authenticationProvider;
@property (nonatomic, readwrite) CKIAccountDomainType type;

+ (CKIAccountDomain *)canvasNetSchool;
+ (CKIAccountDomain *)cantFindSchool;
+ (CKIAccountDomain *)howDoIFindMySchool;

- (instancetype)initWithDomain:(NSString *)domain;

@end
