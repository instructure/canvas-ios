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

#import "CKIClient.h"
#import "CKIModel.h"

extern NSString *const CKIRecipientTypeUser;
extern NSString *const CKIRecipientTypeContext;

@interface CKIConversationRecipient : CKIModel

/**
 The name of the recipient, either the name of the user or the name of the context
 */
@property (nonatomic, copy) NSString *name;

/**
 The url for the avatar of the recipient
 */
@property (nonatomic, strong) NSURL *avatarURL;

/**
 The type of the recipient, either CKIRecipientTypeUser or CKIRecipientTypeContext
 */
@property (nonatomic, copy) NSString *type;


/**
 Valid for users only. A map where key is the group id (NSString) and value is a list
 containing enrollment type defined as CKIEnrollmentTypeStudent, CKIEnrollmentTypeTeacher, 
 CKIEnrollmentTypeTA, or CKIEnrollmentTypeObserver.
 */
@property (nonatomic, copy) NSDictionary *commonGroups;

/**
 Valid for users only. A map where key is the course id (NSString) and value is a list
 containing enrollment types defined as CKIEnrollmentTypeStudent, CKIEnrollmentTypeTeacher, 
 CKIEnrollmentTypeTA, or CKIEnrollmentTypeObserver.
 */
@property (nonatomic, copy) NSDictionary *commonCourses;


/**
 Valid for contexts only. Defaults to 0 for users. Indicates number of messageable users.
 */
@property (nonatomic) NSInteger userCount;


/**
 Valid for groups only. This is the name of the course.
 */
@property (nonatomic, copy) NSString *containingContextName;

@end
