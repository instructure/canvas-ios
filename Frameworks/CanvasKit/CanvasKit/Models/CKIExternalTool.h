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
