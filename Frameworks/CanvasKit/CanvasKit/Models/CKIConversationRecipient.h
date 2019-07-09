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
