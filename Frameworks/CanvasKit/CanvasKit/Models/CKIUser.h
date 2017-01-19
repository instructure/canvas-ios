//
//  CKIUser.h
//  CanvasKit
//
//  Created by Jason Larsen on 9/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIModel.h"

/**
 A Canvas user.
 
 Depending on the permissions of the current user, only certain
 fields may be visible for privacy reasons. Regardless, it should
 always have a name, id, and avatarURL.
 */
@interface CKIUser : CKIModel

/**
 The name of the user.
 */
@property (nonatomic, copy) NSString *name;

/**
 The name of the user that is should be used for sorting groups of
 users, such as in the gradebook.
 */
@property (nonatomic, copy) NSString *sortableName;

/**
 A short name the user has selected, for use in conversations or
 other less formal places through the site.
 */
@property (nonatomic, copy) NSString *shortName;

/**
 The SIS ID associated with the user. This field is only included
 if the user came from a SIS import.
 */
@property (nonatomic, copy) NSString *sisUserID;

/**
 The unique login id for the user. This is what the user uses
 to log in canvas.
 */
@property (nonatomic, copy) NSString *loginID;

/**
 If avatars are enabled, this field will be included and contain
 a url retrieve the user's avatar.
 */
@property (nonatomic, strong) NSURL *avatarURL;

/**
 The user's primary email address.
 
 @note Optional: This field can be requested with certain API calls.
 */
@property (nonatomic, copy) NSString *email;

/**
 The user's locale.
 
 @note Optional: This field can be requested with certain API calls.
 */
@property (nonatomic, copy) NSString *locale;

/**
 The last time the user logged in to Canvas.
 
 @note Optional: This field can be requested with certain API calls.
 */
@property (nonatomic, strong) NSDate *lastLogin;

/**
 The IANA time zone name of the user's preferred timezone.
 
 @note Optional: This field can be requested with certain API calls.
 */
@property (nonatomic, copy) NSString *timeZone;

/**
 The URL for the user's calendar.
 **/
@property (nonatomic, strong) NSURL *calendar;

/**
 Array of the user's enrollments when fetched for a particular course.
 @warning: this only works when fetching list of users for a course.
*/
@property (nonatomic, copy) NSArray *enrollments;

@end
