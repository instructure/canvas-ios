//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import <Foundation/Foundation.h>
#import <CanvasKit1/CKEnrollment.h>
#import <CanvasKit1/CKDiscussionTopic.h>
#import <CanvasKit1/CKAttachment.h>

@class CKGroup, CKDiscussionEntry, CKAPICredentials, CKFolder, CKPaginationInfo, CKAssignmentOverride, CKUser, CKContextInfo, CKCourse, CKCanvasURLConnection, CKSubmission, CKRubricAssessment;



// The isFinalValue argument (the BOOL) will be false if this is cached data being returned,
// and real data is being loaded. This can happen when the cached data is expired. We
// still want to show it while the real data is being loaded. So the block can actually
// be called multiple times.
typedef void (^CKSimpleBlock)(NSError *error, BOOL isFinalValue);
typedef void (^CKObjectBlock)(NSError *error, BOOL isFinalValue, id object);
typedef void (^CKArrayBlock)(NSError *error, BOOL isFinalValue, NSArray *array);
typedef void (^CKFailuresDictionaryBlock)(NSDictionary *errors, BOOL isFinalValue);
typedef void (^CKDictionaryBlock)(NSError *error, BOOL isFinalValue, NSDictionary *dictionary);
typedef void (^CKUserBlock)(NSError *error, BOOL isFinalValue, CKUser *user);
typedef void (^CKURLBlock)(NSError *error, BOOL isFinalValue, NSURL *url);
typedef void (^CKStringBlock)(NSError *error, BOOL isFinalValue, NSString * aString);
typedef void (^CKUploadTargetBlock)(NSError *error, BOOL isFinalValue, NSURL *uploadURL, NSDictionary *uploadParams);
typedef void (^CKMediaBlock)(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString * mediaId);
typedef void (^CKAttachmentBlock)(NSError *error, BOOL isFinalValue, CKAttachment *attachment);
typedef void (^CKSubmissionBlock) (NSError *error, BOOL isFinalValue, CKSubmission *attempt);

// Paged results should not be cached, because we always need the pagination
// info, which is not stored in the local cache. Thus we don't bother with an
// 'isFinalValue' BOOL, since it should always be the final value.
typedef void (^CKPagedArrayBlock)(NSError *error, NSArray *theArray, CKPaginationInfo *pagination);

// This is used for aggregated calls, which can't really have a single 'isFinalValue' result
// Thsu, the block will only be called once.
typedef void (^CKFailuresAndObjectsDictionariesBlock)(NSDictionary *errors, NSDictionary *objects);

extern NSString * const CKCanvasUserWasUpdatedNotification;

extern NSString * const CKUserAgentKey;

extern NSString * const CKCanvasUserInfoKey;
extern NSString * const CKCanvasAccessTokenKey;
extern NSString * const CKCanvasUserIDKey;
extern NSString * const CKCanvasUserNameKey;
extern NSString * const CKCanvasHostnameKey;
extern NSString * const CKCanvasAPIProtocolKey;
extern NSString * const CKCanvasUserInfoVersionKey;

@interface CKCanvasAPI : NSObject

@property (nonatomic, strong) NSString *username DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString *password DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic, strong) NSString *authString;
@property (nonatomic, strong) NSString *actAsId;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *apiProtocol;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, strong) CKMediaServer *mediaServer;

// You can use this to configure user, hostname, apiProtcol, and accessToken
@property (copy) CKAPICredentials *apiCredentials;

@property (assign) int itemsPerPage;

@property (copy) NSString *accessToken;

// ow my eyes! I just don't want to refactor all the methods below to plumb this in yet...
@property (nonatomic, assign) BOOL refreshCacheOnNextRequest;




#pragma mark - Login/OAuth2
// OAuth2 Auth. Make sure you call -oauthLogin... before any calls that require authentication
- (id)init;
- (void)performBlockAfterLogin:(dispatch_block_t)block;
- (void)revokeAccessTokenWithCompletionBlock:(CKSimpleBlock)block;
- (void)verifyMobileAppWithBlock:(CKSimpleBlock)block;



#pragma mark - User Info
- (void)getUserProfileWithBlock:(CKSimpleBlock)block;
- (void)postAvatarNamed:(NSString *)name fileURL:(NSURL *)fileURL block:(CKAttachmentBlock)block;
- (void)updateLoggedInUserAvatarWithURL:(NSURL *)URL block:(CKDictionaryBlock)block;



#pragma mark - Courses
extern NSString * const CKAPIIncludeSyllabusBodyKey; // NSNumber (bool)
// These two options are mutally exclusive; use at most one of them.
extern NSString * const CKAPICoursesForGradingRoleKey; // NSNumber (bool)
extern NSString * const CKAPIIncludeTotalScoresKey; // NSNumber (bool)

- (void)getCourseWithId:(uint64_t)courseId options:(NSDictionary *)options block:(CKObjectBlock)block;



#pragma mark - Groups
- (void)getGroupsWithPageURL:(NSURL *)pageURL isCourseAffiliated:(BOOL)isCourseAffiliated block:(CKPagedArrayBlock)handler;
- (void)getGroupWithId:(uint64_t)ident block:(CKObjectBlock)handler;



#pragma mark - Assignments
typedef void (^CKAssignmentBlock)(NSError *error, CKAssignment *assignment);
- (void)getAssignmentForContext:(CKContextInfo *)context assignmentIdent:(uint64_t)assignmentIdent block:(CKAssignmentBlock)block; // Assignments only exist in courses
- (void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postMediaURL:(NSURL *)mediaURL asSubmissionForAssignment:(CKAssignment *)assignment progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postHTML:(NSString *)html asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block;
- (void)postURL:(NSURL *)contentURL asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block;



#pragma mark - AssignmentOverrides
- (void)getOverridesForCourseIdent:(uint64_t)courseIdent assignmentIdent:(uint64_t)assignmentIdent pageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)handler;



#pragma mark - Discussions
- (void)getDiscussionTopicForIdent:(uint64_t)ident inContext:(CKContextInfo *)contextInfo block:(CKObjectBlock)block;
- (void)getDiscussionTopicsForContext:(CKContextInfo *)courseOrGroup pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block;
- (void)getDiscussionTopicsForContext:(CKContextInfo *)contextInfo pageURL:(NSURL *)pageURL announcementsOnly:(BOOL)announcementsOnly searchTerm:(NSString *)title block:(CKPagedArrayBlock)block;
- (void)getDiscussionTreeForTopic:(CKDiscussionTopic *)topic block:(CKArrayBlock)block;
- (void)markDiscussionEntryRead:(CKDiscussionEntry *)entry block:(CKSimpleBlock)block;
- (void)rateEntry:(CKDiscussionEntry*)entry like:(BOOL)like block:(CKSimpleBlock)block;

#pragma mark (Posting)
typedef void (^CKDiscussionEntryBlock)(NSError *error, CKDiscussionEntry *entry);
typedef void (^CKDiscussionTopicBlock)(NSError *error, CKDiscussionTopic *topic);
- (void)postDiscussionTopicForContext:(CKContextInfo *)context withTitle:(NSString *)title message:(NSString *)message attachments:(NSArray *)attachments topicType:(CKDiscussionTopicType)topicType block:(CKDiscussionTopicBlock)block;
- (void)postEntry:(NSString *)entryText withAttachments:(NSArray *)attachments toDiscussionTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block;
- (void)postReply:(NSString *)replyText withAttachments:(NSArray *)attachments toDiscussionEntry:(CKDiscussionEntry *)entry inTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block;

#pragma mark (Deleting)
- (void)deleteDiscussionEntry:(CKDiscussionEntry *)entry block:(CKSimpleBlock)block;

#pragma mark (Editing)
- (void)editDiscussionEntry:(CKDiscussionEntry *)entry newText:(NSString *)entryText withAttachments:(NSArray *)attachments block:(CKDiscussionEntryBlock)block;



#pragma mark - Announcements
#pragma mark (Posting)
- (void)postAnnouncementForContext:(CKContextInfo *)context withTitle:(NSString *)title message:(NSString *)message attachments:(NSArray *)attachments block:(CKDiscussionTopicBlock)block;



#pragma mark - Submissions
#pragma mark (Viewing)
- (void)getSubmissionForAssignment:(CKAssignment *)assignment studentID:(uint64_t)studentId includeHistory:(BOOL)includeHistory block:(CKObjectBlock)block;
//- (void)getUpdatedSubmission:(CKSubmission *)submission block:(CKSimpleBlock)block;
- (void)getCommentsForSubmission:(CKSubmission *)submission block:(CKArrayBlock)block;
- (CKCanvasURLConnection *)getURLForAttachment:(CKAttachment *)attachment block:(CKURLBlock)block;
- (CKCanvasURLConnection *)downloadAttachment:(CKAttachment *)attachment progressBlock:(void (^)(float progress))progressBlock completionBlock:(CKURLBlock)completionBlock;

#pragma mark (Commenting)
// The progress block on this API receives 0.0..1.0 for determinate progress, or anything outside that range for indeterminate progress. (i.e. if it's not in that range, show a spinner)
- (void)postMediaCommentURL:(NSURL *)mediaURL forCourseIdent:(uint64_t)courseIdent assignmentIdent:(uint64_t)assignmentIdent studentIdent:(uint64_t)studentIdent progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)completionBlock;
- (void)postComment:(NSString *)comment mediaId:(NSString *)mediaId mediaType:(CKAttachmentMediaType)mediaType forSubmission:(CKSubmission *)submission block:(CKSubmissionBlock)block;



#pragma mark - Media Comments
- (void)getMediaServerConfigurationWithBlock:(CKSimpleBlock)block;
// Nest the call to post a media comment into this method when uploading audio or video to kaltura
- (void)postMediaCommentAtPath:(NSString *)path ofMediaType:(CKAttachmentMediaType)mediaType block:(CKMediaBlock)block;


#pragma mark - Files
- (void)listFoldersInFolder:(CKFolder *)folder pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block;
- (void)listFilesInFolder:(CKFolder *)folder pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block;
- (void)getFileWithId:(uint64_t)fileIdent block:(CKObjectBlock)block;
- (void)getRootFolderForContext:(CKContextInfo *)context block:(CKObjectBlock)block;
- (void)getFolderWithId:(uint64_t)ident block:(CKObjectBlock)block;

- (void)createFolderInFolder:(CKFolder *)parentFolder withName:(NSString *)name block:(CKObjectBlock)block;
- (void)uploadFiles:(NSArray *)fileURLs toFolder:(CKFolder *)folder progressBlock:(void (^)(float progress))progressBlock completionBlock:(CKArrayBlock)block;
- (void)deleteFolderItems:(NSArray *)foldersAndAttachments withBlock:(CKFailuresDictionaryBlock)failedDownloadsHandler;


@end
