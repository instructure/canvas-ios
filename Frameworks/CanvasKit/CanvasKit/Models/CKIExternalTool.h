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

#import "CKIModel.h"

@interface CKIExternalTool : CKIModel

/**
 The consumer key used by the tool
 */
@property (nonatomic, copy) NSString *consumerKey;

/**
 The date created
 */
@property (nonatomic, strong) NSDate *createdAt;

/**
 A description of the tool
 */
@property (nonatomic, copy) NSString *description;

/**
 The domain to match links against
 */
@property (nonatomic, copy) NSURL *domain;

/**
  The name of the tool
 */
@property (nonatomic) NSString *name;

/**
  Date of last update
 */
@property (nonatomic, strong) NSDate *updatedAt;

/**
 The url to match links against
 */
@property (nonatomic, strong) NSURL *url;

/**
 What information to send to the external tool, "anonymous", "name_only", "public"
 */
@property (nonatomic) NSString *privacyLevel;

/**
 Custom fields that will be sent to the tool consumer
 */
@property (nonatomic) NSDictionary *customFields;

/**
  The state of the workflow
 */
@property (nonatomic) NSString *workflowState;

/**
 A url for vendor help
 */
@property (nonatomic, strong) NSURL *vendorHelpLink;

/**
 The url of the icon to show for this tool
 */
@property (nonatomic, strong) NSURL *iconURL;

@end
