//
// Copyright (C) 2017-present Instructure, Inc.
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
+ (NSArray *)developmentSchools;

- (instancetype)initWithDomain:(NSString *)domain;

@end
