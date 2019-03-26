//
// Copyright (C) 2019-present Instructure, Inc.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CKManagedAppConfiguration;

@protocol CKManagedAppConfigurationDelegate <NSObject>
- (void)managedAppConfigurationDidChange:(CKManagedAppConfiguration *)configuration;
@end

@interface CKManagedAppConfiguration : NSObject

@property (nonatomic, weak, nullable) NSObject<CKManagedAppConfigurationDelegate> *delegate;
@property (nonatomic) BOOL demoEnabled;
@property (nonatomic, strong, nullable) NSString *username;
@property (nonatomic, strong, nullable) NSString *password;
@property (nonatomic, strong, nullable) NSString *domain;

- (void)beginObserving;

@end

NS_ASSUME_NONNULL_END
