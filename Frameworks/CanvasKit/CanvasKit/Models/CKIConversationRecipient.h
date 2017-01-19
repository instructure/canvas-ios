//
//  CKIConversationRecipient.h
//  CanvasKit
//
//  Created by Ben Kraus on 12/1/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
