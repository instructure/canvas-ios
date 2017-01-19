//
//  CKIGroupCategory.h
//  CanvasKit
//
//  Created by Brandon Pluim on 12/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h" 

@interface CKIGroupCategory : CKIModel

/**
 The name of the category.
 */
@property (nonatomic, copy) NSString *name;

/**
 Certain types of group categories have special role designations. Currently,
 these include: 'communities', 'student_organized', and 'imported'. Regular
 course/account group categories have a role of null.
 */
@property (nonatomic, copy) NSString *role;

/**
 If the group category allows users to join a group themselves, thought they may
 only be a member of one group per group category at a time. Values include
 'restricted', 'enabled', and null 'enabled' allows students to assign themselves
 to a group 'restricted' restricts them to only joining a group in their section
 null disallows students from joining groups
 */
@property (nonatomic, copy) NSString *selfSignup;

/**
 Gives instructors the ability to automatically have group leaders assigned.
 Values include 'random', 'first', and null; 'random' picks a student from the
 group at random as the leader, 'first' sets the first student to be assigned to
 the group as the leader
 */
@property (nonatomic, copy) NSString *autoLeader;

/**
 The course or account that the category group belongs to. The pattern here is
 that whatever the context_type is, there will be an _id field named after that
 type. So if instead context_type was 'Course', the course_id field would be
 replaced by an course_id field.
 */
@property (nonatomic, copy) NSString *contextType;

/**
 Account ID of the category
 */
@property (nonatomic, copy) NSNumber *accountID;

/**
 If self-signup is enabled, group_limit can be set to cap the number of users in
 each group. If null, there is no limit.
 */
@property (nonatomic, copy) NSNumber *groupLimit;

/**
 If the group category has not yet finished a randomly student assignment
 request, a progress object will be attached, which will contain information
 related to the progress of the assignment request. Refer to the Progress API for
 more information
 */
@property (nonatomic, copy) NSString *progress;

@end
