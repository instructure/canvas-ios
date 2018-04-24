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
    
    

#import "CKCanvasAPI.h"
#import "CKCanvasAPIResponse.h"
#import "CKCanvasURLConnection.h"
#import "CKDiscussionTopic.h"
#import "NSString+CKAdditions.h"
#import "TouchXML.h"
#import "NSDictionary+CKAdditions.h"
#import "CKUser.h"
#import <UIKit/UIKit.h>
#import "CKDiscussionEntry.h"
#import "CKCalendarItem.h"
#import "NSHTTPURLResponse+CKAdditions.h"
#import "CKEmbeddedMediaAttachment.h"
#import "CKSubmission.h"
#import "CKEnrollment.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSFileManager+CKAdditions.h"
#import "NSArray+CKAdditions.h"
#import "CKAPICredentials.h"
#import "CKFolder.h"
#import "CKMediaComment.h"
#import "CKPaginationInfo.h"
#import "CKGroup.h"
#import "CKContextInfo.h"
#import "CKTerm.h"
#import "CKAssignmentOverride.h"
#import "CKCanvasAPI+Private.h"
#import <CommonCrypto/CommonDigest.h>
#import "CKCourse.h"
#import "CKStudent.h"
#import "CKAssignmentGroup.h"
#import "CKAssignment.h"
#import "CKSubmissionComment.h"
#import "CKMediaServer.h"
#import "CKRubricAssessment.h"

@import AFNetworking;

// TODO: probably should turn this into a dictionary of domain=>api_key
#define PROD_CLIENT_ID @"4"
#define PROD_CLIENT_SECRET @"5m6iCvv5dKhia4u3bS2XkmCYHtSkmjk9"
#define LONG_CACHE_LIMIT_SECONDS (60 * 60 * 24 * 7)
#define SHORT_CACHE_LIMIT_SECONDS (1)

NSString * const CKUserAgentKey = @"CKUserAgentKey";


#define StringConstant(key) NSString * const key = @#key;


StringConstant(CKAPIHTTPMethodKey); // NSString
StringConstant(CKAPIHTTPBodyDataKey); // NSData
StringConstant(CKAPIHTTPHeadersKey); // NSDictionary (NSString -> NSString)
StringConstant(CKAPIHTTPPOSTParameters); // NSDictionary (NSString -> NSString)
StringConstant(CKAPIProgressNotificationObjectKey); // id
StringConstant(CKAPIOutputFileHandleKey); // NSFileHandle
StringConstant(CKAPIShouldIgnoreCacheKey); // NSNumber (bool)
StringConstant(CKAPICoursesForGradingRoleKey); // NSNumber (bool)
StringConstant(CKAPIIncludeTotalScoresKey);  // NSNumber (bool)
StringConstant(CKAPIIncludeSyllabusBodyKey);  // NSNumber (bool)
StringConstant(CKAPIIncludePermissionsKey); // NSNumber (bool)
StringConstant(CKAPINoAccessTokenRequired); // NSNumber (bool)
StringConstant(CKAPINoMasqueradeIDRequired); // NSNumber (bool)
StringConstant(CKAPIBlockRedirectsKey); // NSNumber (bool)
StringConstant(CKAPICurrentCoursesOnlyKey);  // NSNumber (bool))
StringConstant(CKAPILimitEnrollmentTypesKey); // NSString *

//External Constants
StringConstant(CKCanvasUserWasUpdatedNotification);
StringConstant(CKCanvasUserInfoKey);
StringConstant(CKCanvasAccessTokenKey);
StringConstant(CKCanvasUserIDKey);
StringConstant(CKCanvasUserNameKey);
StringConstant(CKCanvasHostnameKey);
StringConstant(CKCanvasAPIProtocolKey);
StringConstant(CKCanvasUserInfoVersionKey);

#pragma mark - Helper categories


@interface CKCanvasAPIResponseParser : AFHTTPResponseSerializer
@end

@interface CKContextInfo (URLRouting)
@property (readonly) NSString * typeComponentForURLs;
@end

@implementation CKContextInfo (URLRouting)
- (NSString *)typeComponentForURLs {
    NSString *contextTypeStr = nil;
    switch (self.contextType) {
        case CKContextTypeCourse:
            contextTypeStr = @"courses";
            break;
        case CKContextTypeGroup:
            contextTypeStr = @"groups";
            break;
        case CKContextTypeUser:
            contextTypeStr = @"users";
            break;
        case CKContextTypeNone:
            contextTypeStr = nil;
    }
    return contextTypeStr;
}

@end

#pragma mark - CKCanvasAPI

@interface CKCanvasAPI () {
    NSMutableArray *afterLoginBlocks;
}
NSString *CKDownloadsInProgressDirectory(void);

- (NSString *)cachePathForURL:(NSURL *)url;

// The next 4 calls are used by postMediaCommentAtPath... you probably should use that instead.
- (void)getMediaRecordingSessionWithBlock:(CKStringBlock)block;
- (void)getFileUploadTokenWithSessionId:(NSString *)sessionId block:(CKStringBlock)block;
- (void)uploadFileAtPath:(NSString *)path ofMediaType:(CKAttachmentMediaType)mediaType withToken:(NSString *)token sessionId:(NSString *)sessionId block:(CKSimpleBlock)block;
- (void)getMediaIdForUploadedFileToken:(NSString *)token withMediaType:(CKAttachmentMediaType)mediaType sessionId:(NSString *)sessionId block:(CKStringBlock)block;

- (int)pageNumberForLastPageInResponse:(NSHTTPURLResponse *)response;
- (NSURL *)getNextPageURLFromResponse:(NSHTTPURLResponse *)response;

- (void)setupSharedURLCache;

- (void)getDiscussionTopicsForContext:(CKContextInfo *)contextInfo
                              pageURL:(NSURL *)pageURL
                    announcementsOnly:(BOOL)announcementsOnly
                                block:(CKPagedArrayBlock)block;

@end

@implementation CKCanvasAPI

@synthesize username, password, hostname, authString, actAsId, user, clientId, clientSecret, apiProtocol, refreshCacheOnNextRequest, verified, mediaServer;
@synthesize accessToken;
@synthesize itemsPerPage;

////////////////////////////////////////////
#pragma mark - Login/OAuth2
////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (self) {
        self.verified = NO;
        
        afterLoginBlocks = [[NSMutableArray alloc] init];
        itemsPerPage = 20;
        
        [self setupSharedURLCache];
    }
    
    return self;
}

- (CKAPICredentials *)apiCredentials {
    if (self.accessToken == nil) {
        return nil;
    }
    CKAPICredentials *credentials = [CKAPICredentials new];
    credentials.userName = self.user.name;
    credentials.userIdent = self.user.ident;
    credentials.hostname = self.hostname;
    credentials.apiProtocol = self.apiProtocol;
    credentials.accessToken = self.accessToken;
    credentials.actAsId = self.actAsId;
    return credentials;
}

- (void)setApiCredentials:(CKAPICredentials *)apiCredentials {
    if (apiCredentials == nil) {
        user = nil;
        hostname = nil;
        apiProtocol = nil;
        accessToken = nil;
        actAsId = nil;
        return;
    }
    
    NSAssert([apiCredentials isValid], @"Cannot configure with invalid API credentials");
    NSDictionary *userDict = @{@"id": @(apiCredentials.userIdent),
                              @"name": apiCredentials.userName};
    
    user = [[CKUser alloc] initWithInfo:userDict];
    hostname = apiCredentials.hostname;
    apiProtocol = apiCredentials.apiProtocol;
    accessToken = apiCredentials.accessToken;
    actAsId = apiCredentials.actAsId;
}

- (void)performBlockAfterLogin:(dispatch_block_t)block {
    if (accessToken) {
        block();
    }
    else {
        block = [block copy];
        [afterLoginBlocks addObject:block];
    }
}

- (void)revokeAccessTokenWithCompletionBlock:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/login/oauth2/token", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *options = @{ CKAPIHTTPMethodKey: @"DELETE"};
    CKCanvasURLConnection *connection = [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            NSLog(@"Couldn't delete oauth token on server. Still removed locally. %@", error);
        }
    }];
    
    // We want this go to through even on logout.
    connection.ignoreAbortAllConnections = YES;

    // Whether or not the remote delete goes through successfully, we should do the local logout.
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    // Set the access token to nil. The completion block should clean up NSUserDefaults and iCloud
    self.accessToken = nil;
    if (block) {
        block(nil, YES);
    }
}

- (void)verifyMobileAppWithBlock:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"https://canvas.instructure.com/api/v1/mobile_verify.json?domain=%@", self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPINoAccessTokenRequired: @YES,
                     CKAPIShouldIgnoreCacheKey: @YES}
              block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue);
            return;
        }
        
        id response = [apiResponse JSONValue];
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = (NSDictionary *)response;
            NSInteger result = [responseDict[@"result"] integerValue];
            if (result > 0) {
                // Success      = 0
                // Other        = 1 # generic "you aren't authorized cuz i said so"
                // BadSite      = 2 # params['domain'] isn't authorized for mobile apps
                // BadUserAgent = 3 # the user agent given wasn't recognized
                CKCanvasErrorCode errorCode;
                switch (result) {
                    case 1:
                        // send an error
                        errorCode = CKCanvasErrorCodeMobileVerifyGeneralNotAuthorized;
                        break;
                    case 2:
                        // send an error
                        errorCode = CKCanvasErrorCodeMobileVerifyDomainNotAuthorized;
                        break;
                    case 3:
                        // send an error
                        errorCode = CKCanvasErrorCodeMobileVerifyUserAgentUnknown;
                        break;
                    default:
                        // send an unknown error
                        errorCode = CKCanvasErrorCodeUnknown;
                        break;
                }
                block([NSError errorWithDomain:CKCanvasErrorDomain code:errorCode userInfo:responseDict], YES);
                return;
            }
            else {
                // Check if it's YES or NO.
                // set self.verified
                self.verified = [responseDict[@"authorized"] boolValue];
                // If NO, create an error and return it
                if (self.verified == NO) {
                    block([NSError errorWithDomain:CKCanvasErrorDomain code:CKCanvasErrorCodeMobileVerifyDomainNotAuthorized userInfo:nil], isFinalValue);
                    return;
                }
                
                // set base url stuff (http or https)
                NSString *baseURLString = responseDict[@"base_url"];
                NSArray *baseURLStringComponents = [baseURLString componentsSeparatedByString:@"://"];
                if ([baseURLStringComponents count] == 2) {
                    self.apiProtocol = baseURLStringComponents[0];
                    NSArray *baseURLHostnameComponents = [baseURLStringComponents[1] componentsSeparatedByString:@"/"];
                    if ([baseURLHostnameComponents count] > 0) {
                        self.hostname = baseURLHostnameComponents[0];
                    }
                    else {
                        NSLog(@"base_url hostname did not parse correctly. Setting default to the hostname the user entered. failed base_url hostname: %@",baseURLStringComponents[1]);
                    }
                }
                else {
                    NSLog(@"base_url did not parse correctly. Setting defaults to https and hostname the user entered. failed base_url: %@",baseURLString);
                    self.apiProtocol = @"https";
                }
                
                // set client information
                self.clientId = [responseDict objectForKeyCheckingNull:@"client_id"];
                if (!self.clientId) {
                    NSLog(@"Couldn't parse the client ID. Defaulting to production canvas client id.");
                    self.clientId = PROD_CLIENT_ID;
                }
                self.clientSecret = [responseDict objectForKeyCheckingNull:@"client_secret"];
                if (!self.clientSecret) {
                    NSLog(@"Couldn't parse the API key. Defaulting to production canvas key.");
                    self.clientSecret = PROD_CLIENT_SECRET;
                }
            }
        }

        block(nil, isFinalValue);
    }];
}

////////////////////////////////////////////
#pragma mark - User Info
////////////////////////////////////////////

- (void)getUserProfileWithBlock:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/profile.json", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue);
                      return;
                  }
                  
                  NSDictionary *responseDict = [apiResponse JSONValue];
                  
                  // We should already have a user object, but let's check just in case
                  if (!self.user) {
                      self.user = [[CKUser alloc] initWithInfo:responseDict];
                  }
                  else {
                      [self.user updateWithInfo:responseDict];
                  }
                  
                  block(nil, isFinalValue);
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasUserWasUpdatedNotification
                                                                      object:self];
              }];
}

- (void)postAvatarNamed:(NSString *)name fileURL:(NSURL *)fileURL block:(CKAttachmentBlock)block
{
    NSURL *uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/users/self/files",
                                                 self.apiProtocol,
                                                 self.hostname]];
    NSString *folderPath = @"profile pictures";
    [self uploadFileNamed:name location:fileURL endpoint:uploadUrl folderPath:folderPath block:block];
}

- (void)updateLoggedInUserAvatarWithURL:(NSURL *)URL block:(CKDictionaryBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self", self.apiProtocol, self.hostname];//, user.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       URL.absoluteString, @"user[avatar][url]",
                                       nil];
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"PUT",
                             CKAPIHTTPPOSTParameters: parameters};
    
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *response = [apiResponse JSONValue];
                  
                  block(nil, isFinalValue, response);
              }];  
}

////////////////////////////////////////////
#pragma mark - Courses
////////////////////////////////////////////

- (void)getCourseWithId:(uint64_t)courseId options:(NSDictionary *)options block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu.json", self.apiProtocol, self.hostname, courseId];
    
    NSMutableArray *optionStrings = [NSMutableArray new];
    
    if ([options[CKAPIIncludeTotalScoresKey] boolValue]) {
        [optionStrings addObject:@"enrollment_type=student"];
        [optionStrings addObject:@"include[]=total_scores"];
    }
    if ([options[CKAPIIncludeSyllabusBodyKey] boolValue]) {
        [optionStrings addObject:@"include[]=syllabus_body"];
    }
    
    [optionStrings addObject:@"include[]=permissions"];
    
    if (optionStrings.count > 0) {
        // There are some options to be added to the url
        urlString = [urlString stringByAppendingString:@"?"];
        urlString = [urlString stringByAppendingString:[optionStrings componentsJoinedByString:@"&"]];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *dict = [apiResponse JSONValue];
        
        CKCourse *course = [[CKCourse alloc] initWithInfo:dict];
        
        block(nil, isFinalValue, course);
    }];
}

/////////////////////////////////////////////
#pragma mark (Course enrollment and schedule)
/////////////////////////////////////////////

- (void)getGroupsWithPageURL:(NSURL *)pageURL isCourseAffiliated:(BOOL)isCourseAffiliated block:(CKPagedArrayBlock)handler; {
    NSURL *url = pageURL;
    if (url == nil) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/groups?%@per_page=%u",
                               self.apiProtocol,
                               self.hostname,
                               isCourseAffiliated ? [NSString stringWithFormat:@"context_Type=Course&"] : @"",
                               self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{ CKAPIShouldIgnoreCacheKey : @YES };
    
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            handler(error, nil, nil);
            return;
        }
        CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
        
        NSArray *groupInfos = [apiResponse JSONValue];
        NSMutableArray *groups = [NSMutableArray new];
        for (NSDictionary *info in groupInfos) {
            CKGroup *group = [[CKGroup alloc] initWithInfo:info];
            [groups addObject:group];
        }
        
        handler(nil, groups, pagination);
    }];
}

- (void)getGroupWithId:(uint64_t)ident block:(CKObjectBlock)handler {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/groups/%qu", self.apiProtocol, self.hostname, ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            handler(error, isFinalValue, nil);
            return;
        }
        NSDictionary *result = [apiResponse JSONValue];
        CKGroup *group = [[CKGroup alloc] initWithInfo:result];
        handler(nil, isFinalValue, group);
    }];
}

- (void)getAssignmentForContext:(CKContextInfo *)context assignmentIdent:(uint64_t)assignmentIdent block:(CKAssignmentBlock)block
{
    NSAssert(context.contextType == CKContextTypeCourse, @"You can't have assignments outside of a course");
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu", self.apiProtocol, self.hostname, context.ident, assignmentIdent];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, nil);
            return;
        }
        
        NSDictionary *assignmentInfo = [apiResponse JSONValue];
        CKAssignment *assignment = [[CKAssignment alloc] initWithInfo:assignmentInfo];
        block(error, assignment);
    }];
}

- (void)getOverridesForCourseIdent:(uint64_t)courseIdent assignmentIdent:(uint64_t)assignmentIdent pageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)handler {
    NSURL *url = pageURL;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/overrides?per_page=%d",
                               self.apiProtocol, self.hostname, courseIdent, assignmentIdent, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{ CKAPIShouldIgnoreCacheKey : @YES };
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            handler(error, nil, nil);
            return;
        }
        
        CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
        NSArray *response = [apiResponse JSONValue];
        
        NSMutableArray *overrides = [NSMutableArray new];
        for (NSDictionary *info in response) {
            CKAssignmentOverride *override = [[CKAssignmentOverride alloc] initWithInfo:info];
            [overrides addObject:override];
        }
        handler(error, overrides, pagination);
    }];
}

#pragma mark Discussion/Announcement Helpers

- (void)getDiscussionTopicsForContext:(CKContextInfo *)contextInfo
                              pageURL:(NSURL *)pageURL
                    announcementsOnly:(BOOL)announcementsOnly
                                block:(CKPagedArrayBlock)block {
    [self getDiscussionTopicsForContext:contextInfo pageURL:pageURL announcementsOnly:announcementsOnly searchTerm:nil block:block];
}

- (void)getDiscussionTopicsForContext:(CKContextInfo *)contextInfo
                              pageURL:(NSURL *)pageURL
                    announcementsOnly:(BOOL)announcementsOnly
                           searchTerm:(NSString *)title
                                block:(CKPagedArrayBlock)block {
    
    NSURL *url = pageURL;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics.json?%@%@per_page=%d",
                               self.apiProtocol,
                               self.hostname,
                               contextInfo.typeComponentForURLs,
                               contextInfo.ident,
                               announcementsOnly ? @"only_announcements=1&" : @"",
                               [title length] ? [NSString stringWithFormat:@"search_term=%@&",[title realURLEncodedString]] : @"",
                               itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    block = [block copy];
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, nil, 0);
            return;
        }
        
        NSHTTPURLResponse *response = apiResponse;
        CKPaginationInfo *info = [[CKPaginationInfo alloc] initWithResponse:response];
        
        NSArray *topicDicts = [apiResponse JSONValue];
        NSMutableArray *topics = [NSMutableArray arrayWithCapacity:topicDicts.count];
        
        for (NSDictionary *dict in topicDicts) {
            CKDiscussionTopic *topic = [[CKDiscussionTopic alloc] initWithInfo:dict andAssignment:nil];
            topic.contextInfo = contextInfo;
            [topics addObject:topic];
        }
        block(nil, topics, info);
    }];
}

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       isAnnouncement:(BOOL)isAnnouncement
                                block:(CKDiscussionTopicBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics", self.apiProtocol, self.hostname, context.typeComponentForURLs, context.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self postAttachmentsToUserFiles:attachments andFormatText:message block:^(NSError *error, BOOL isFinalValue, NSString *finalText) {
        
        if (error) {
            block(error, nil);
            return;
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        parameters[@"title"] = title;
        if (topicType == CKDiscussionTopicTypeSideComment) {
            parameters[@"discussion_type"] = @"side_comment";
        }
        else if (topicType == CKDiscussionTopicTypeThreaded) {
            parameters[@"discussion_type"] = @"threaded";
        }
        
        if (finalText) {
            parameters[@"message"] = finalText;
        }
        
        if (isAnnouncement) {
            parameters[@"is_announcement"] = @"true";
        }
        
        NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                                  CKAPIHTTPPOSTParameters: parameters};
        
        [self runForURL:url
                options:options
                  block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                      if (error) {
                          block(error, nil);
                      }
                      else {
                          NSDictionary *dict = [apiResponse JSONValue];
                          CKDiscussionTopic *topic = [[CKDiscussionTopic alloc] initWithInfo:dict andAssignment:nil];
                          // set course ident since we don't have an assignment
                          topic.contextInfo = context;
                          block(nil, topic);
                      }
                  }];
    }];
}

////////////////////////////////////////////
#pragma mark - Discussions
////////////////////////////////////////////

#pragma mark Viewing

- (void)getDiscussionTopicsForContext:(CKContextInfo *)contextInfo pageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)block {
    [self getDiscussionTopicsForContext:contextInfo pageURL:pageURL announcementsOnly:NO block:block];
}

- (void)getDiscussionTopicForIdent:(uint64_t)ident inContext:(CKContextInfo *)contextInfo block:(CKObjectBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%lld",
                           self.apiProtocol, self.hostname, contextInfo.typeComponentForURLs, contextInfo.ident, ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *dict = [apiResponse JSONValue];
        CKDiscussionTopic *topic = [[CKDiscussionTopic alloc] initWithInfo:dict andAssignment:nil];
        topic.contextInfo = contextInfo;
        
        block(error, isFinalValue, topic);
    }];
}

// For use with the discussion_topics/:topic_id/view API
- (CKDiscussionEntry *)_discussionEntryWithInfo:(NSDictionary *)info
                                   participants:(NSDictionary *)participants
                                  unreadEntries:(NSSet *)unreadEntries
                                          topic:(CKDiscussionTopic *)topic
                                   entryRatings:(NSDictionary*)entryRatings
{
    CKDiscussionEntry *entry = [[CKDiscussionEntry alloc] initWithInfo:info andDiscussionTopic:topic entryRatings:entryRatings];
    NSNumber *userIdent = @(entry.userIdent);
    NSDictionary *participantInfo = participants[userIdent];

    NSString *name = participantInfo[@"display_name"];
    entry.userName = name;
    
    NSString *avatarStr = [participantInfo objectForKeyCheckingNull:@"avatar_image_url"];
    if (avatarStr) {
        NSURL *avatarURL = [NSURL URLWithString:avatarStr];
        entry.userAvatarURL = avatarURL;
    }
    
    NSNumber *entryIdent = @(entry.ident);
    if ([unreadEntries containsObject:entryIdent]) {
        entry.unread = YES;
    }

    NSDictionary *rawReplies = info[@"replies"];
    NSMutableArray *replies = [NSMutableArray new];
    for (NSDictionary *replyInfo in rawReplies) {
        CKDiscussionEntry *reply = [self _discussionEntryWithInfo:replyInfo participants:participants unreadEntries:unreadEntries topic:topic entryRatings:entryRatings];
        reply.parentEntry = entry;
        [replies addObject:reply];
    }
    entry.replies = replies;
    return entry;
}

- (void)getDiscussionTreeForTopic:(CKDiscussionTopic *)topic block:(CKArrayBlock)block {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/view",
                           self.apiProtocol, self.hostname, topic.contextInfo.typeComponentForURLs, topic.contextInfo.ident, topic.ident];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue, 0);
                      return;
                  }
                  
                  NSDictionary *result = [apiResponse JSONValue];
                  
                  NSArray *rawParticipants = result[@"participants"];
                  NSMutableDictionary *participants = [NSMutableDictionary new];
                  for (NSDictionary *dict in rawParticipants) {
                      NSNumber *userIdent = dict[@"id"];
                      participants[userIdent] = dict;
                  }
                  
                  NSArray *rawUnreadEntries = result[@"unread_entries"];
                  NSSet *unreadEntries = [NSSet setWithArray:rawUnreadEntries];
                  
                  NSDictionary *entryRatings = result[@"entry_ratings"];
                  
                  NSArray *rawEntries = result[@"view"];
                  NSMutableArray *entries = [NSMutableArray new];
                  for (NSDictionary *dict in rawEntries) {
                      CKDiscussionEntry *entry = [self _discussionEntryWithInfo:dict
                                                                   participants:participants
                                                                  unreadEntries:unreadEntries
                                                                          topic:topic
                                                                   entryRatings:entryRatings];
                      [entries addObject:entry];
                  }
                  block(nil, isFinalValue, entries);
              }];
    
}

- (void)markDiscussionEntryRead:(CKDiscussionEntry *)entry block:(CKSimpleBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries/%qu/read", self.apiProtocol, self.hostname, entry.discussionTopic.contextInfo.typeComponentForURLs, entry.discussionTopic.contextInfo.ident, entry.discussionTopic.ident, entry.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"PUT"};
    
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue);
                  }
                  else {
                      block(nil, isFinalValue);
                  }
              }];
};

- (void)rateEntry:(CKDiscussionEntry*)entry like:(BOOL)like block:(CKSimpleBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries/%qu/rating", self.apiProtocol, self.hostname, entry.discussionTopic.contextInfo.typeComponentForURLs, entry.discussionTopic.contextInfo.ident, entry.discussionTopic.ident, entry.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *parameters = @{@"rating" : like ? @"1" : @"0"};
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                              CKAPIHTTPPOSTParameters: parameters};
    
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue);
                  }
                  else {
                      block(nil, isFinalValue);
                  }
              }];
}

////////////////////////////////////////////
#pragma mark (Posting)
////////////////////////////////////////////

- (void)postDiscussionTopicForContext:(CKContextInfo *)context withTitle:(NSString *)title message:(NSString *)message attachments:(NSArray *)attachments topicType:(CKDiscussionTopicType)topicType block:(CKDiscussionTopicBlock)block
{
    [self postDiscussionTopicForContext:context withTitle:title message:message attachments:attachments topicType:topicType isAnnouncement:NO block:block];
}

- (void)postEntry:(NSString *)entryText withAttachments:(NSArray *)attachments toDiscussionTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries",
                           self.apiProtocol, self.hostname, topic.contextInfo.typeComponentForURLs, topic.contextInfo.ident, topic.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self postAttachmentsToUserFiles:attachments andFormatText:entryText block:^(NSError *uploadError, BOOL isFinalValue, NSString *finalText) {
        if (uploadError) {
            NSLog(@"Uploading failed due to attachment upload error:  %@", [uploadError localizedDescription]);
            block(uploadError, nil);
            return;
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        parameters[@"message"] = finalText;
        
        NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                                 CKAPIHTTPPOSTParameters: parameters};
        
        [self runForURL:url
                options:options
                  block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                      if (error) {
                          block(error, nil);
                      }
                      else {
                          NSDictionary *dict = [apiResponse JSONValue];
                          CKDiscussionEntry *postedEntry = [[CKDiscussionEntry alloc] initWithInfo:dict andDiscussionTopic:topic entryRatings:nil];
                          block(nil, postedEntry);
                      }
                  }];
    }];
}

- (void)postReply:(NSString *)replyText withAttachments:(NSArray *)attachments toDiscussionEntry:(CKDiscussionEntry *)entry inTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block {
    
    NSString * urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries/%qu/replies",
                            self.apiProtocol, self.hostname, topic.contextInfo.typeComponentForURLs, topic.contextInfo.ident, topic.ident, entry.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self postAttachmentsToUserFiles:attachments andFormatText:replyText block:^(NSError *uploadError, BOOL isFinalValue, NSString *finalText) {
        if (uploadError) {
            NSLog(@"Uploading failed due to attachment upload error:  %@", [uploadError localizedDescription]);
            block(uploadError, nil);
            return;
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        parameters[@"message"] = finalText;
        
        NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                                 CKAPIHTTPPOSTParameters: parameters};
        
        [self runForURL:url
                options:options
                  block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                      if (error) {
                          block(error, nil);
                      }
                      else {
                          NSDictionary *dict = [apiResponse JSONValue];
                          CKDiscussionEntry *postedEntry = [[CKDiscussionEntry alloc] initWithInfo:dict andDiscussionTopic:topic entryRatings:nil];
                          block(nil, postedEntry);
                      }
                  }];
    }];
}

- (void)postAttachmentsToUserFiles:(NSArray *)attachments
                     andFormatText:(NSString *)text
                             block:(CKObjectBlock)block {
    
    NSURL *fileUploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/users/self/files",
                                                 self.apiProtocol,
                                                 self.hostname]];
    
    // Keep track of at least one error if any for the uploads
    __block NSError * uploadError;
    
    dispatch_group_t attachmentUploadGroup = dispatch_group_create();
    
    for (CKEmbeddedMediaAttachment *attachment in attachments) {
        
        if (attachment.stringForEmbedding) {
            // The file was already uploaded, don't upload it again
            continue;
        }
        
        dispatch_group_enter(attachmentUploadGroup);
        
        if (attachment.type == CKAttachmentMediaTypeAudio || attachment.type == CKAttachmentMediaTypeVideo) {
            // Use Kaltura
            [self postMediaCommentAtPath:[attachment.url path]
                             ofMediaType:attachment.type
                                   block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId)
             {
                 if (error) {
                     NSLog(@"Error uploading attachment at url: %@", attachment.url);
                     uploadError = error;
                     dispatch_group_leave(attachmentUploadGroup);
                     return;
                 }
                 
                 if (mediaId) {
                     
                     NSString *mediaTypeString;
                     
                     if (mediaType == CKAttachmentMediaTypeAudio) {
                         mediaTypeString = @"audio_comment";
                     }
                     else if (mediaType == CKAttachmentMediaTypeVideo) {
                         mediaTypeString = @"video_comment";
                     }
                     
                     NSString * embeddedMediaTag = [NSString stringWithFormat:@"<p><a id='media_comment_%@' "
                                                    "class='instructure_inline_media_comment %@'"
                                                    "href='/media_objects/%@'>this is a media comment</a></p>"
                                                    , mediaId, mediaTypeString, mediaId];
                     
                     attachment.mediaId = mediaId;
                     attachment.stringForEmbedding = embeddedMediaTag;
                 }
                 
                 dispatch_group_leave(attachmentUploadGroup);
             }];
        } else {
            // Use File Upload API
            [self uploadFileNamed:nil location:attachment.url endpoint:fileUploadUrl folderPath:@"unfiled" block:^(NSError *error, BOOL isFinalValue, CKAttachment *finalAttachment) {
                
                if (error) {
                    NSLog(@"Error uploading attachment at url: %@", attachment.url);
                    uploadError = error;
                    dispatch_group_leave(attachmentUploadGroup);
                    return;
                }
                
                NSString *embeddedMediaTag;
                if (attachment.type == CKAttachmentMediaTypeImage) {
                    embeddedMediaTag = [NSString stringWithFormat:@"<img src='%@'>", finalAttachment.directDownloadURL];
                } else {
                    embeddedMediaTag = [NSString stringWithFormat:@"<p><a "
                                        "class='instructure_inline_media_comment' "
                                        "href='%@'>Attachment</a></p>", attachment.url];
                }
                
                attachment.stringForEmbedding = embeddedMediaTag;
                
                dispatch_group_leave(attachmentUploadGroup);
            }];
        }
    }
    
    block = [block copy];
    
    // When the group of uploads is done, upload the text
    dispatch_group_notify(attachmentUploadGroup, dispatch_get_main_queue(), ^{
        
        if (uploadError) {
            NSLog(@"Uploading failed due to attachment upload error:  %@", [uploadError localizedDescription]);
            
            block(uploadError, YES, nil);
            
            return;
        }
        
        NSString *finalText = [text copy];
        
        if (attachments) {
            // Replace all attachment placeholders in the text with their tags for embedding
            for (CKEmbeddedMediaAttachment *attachment in attachments) {
                // Make sure the attachment was successfully uploaded
                if (attachment.stringForEmbedding) {
                    finalText = [finalText stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"##IMAGE%llu##", attachment.attachmentId]
                                                                     withString:attachment.stringForEmbedding];
                }
            }
        }
        
        block(nil, NO, finalText);
        
    });
}

////////////////////////////////////////////
#pragma mark (Deleting)
////////////////////////////////////////////

- (void)deleteDiscussionEntry:(CKDiscussionEntry *)entry block:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries/%qu", self.apiProtocol, self.hostname, entry.discussionTopic.contextInfo.typeComponentForURLs, entry.discussionTopic.contextInfo.ident, entry.discussionTopic.ident, entry.ident];

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"DELETE"};
    
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue);
                      return;
                  }
                  
                  block(nil, isFinalValue);
              }];
}

////////////////////////////////////////////
#pragma mark (Editing)
////////////////////////////////////////////

- (void)editDiscussionEntry:(CKDiscussionEntry *)entry newText:(NSString *)entryText withAttachments:(NSArray *)attachments block:(CKDiscussionEntryBlock)block
{
    if ([entry.entryMessage isEqualToString:entryText]) {
        block(nil, entry);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu/entries/%qu",
                           self.apiProtocol, self.hostname, entry.discussionTopic.contextInfo.typeComponentForURLs, entry.discussionTopic.contextInfo.ident, entry.discussionTopic.ident, entry.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self postAttachmentsToUserFiles:attachments andFormatText:entryText block:^(NSError *error, BOOL isFinalValue, NSString *finalText) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        parameters[@"message"] = finalText;
        
        NSDictionary *options = @{CKAPIHTTPMethodKey: @"PUT",
                                 CKAPIHTTPPOSTParameters: parameters};
        
        [self runForURL:url
                options:options
                  block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                      if (error) {
                          block(error, nil);
                      }
                      else {
                          NSDictionary *dict = [apiResponse JSONValue];
                          CKDiscussionEntry *newEntry = [[CKDiscussionEntry alloc] initWithInfo:dict andDiscussionTopic:entry.discussionTopic entryRatings:nil];
                          block(nil, newEntry);
                      }
                  }];
    }];
}

////////////////////////////////////////////
#pragma mark - Announcements
////////////////////////////////////////////

#pragma mark (Posting)
- (void)postAnnouncementForContext:(CKContextInfo *)context withTitle:(NSString *)title message:(NSString *)message attachments:(NSArray *)attachments block:(CKDiscussionTopicBlock)block
{
    [self postDiscussionTopicForContext:context withTitle:title message:message attachments:attachments topicType:CKDiscussionTopicTypeSideComment isAnnouncement:YES block:block];
}

////////////////////////////////////////////
#pragma mark - File Upload API
////////////////////////////////////////////


- (void)uploadFiles:(NSArray *)fileURLs toFolder:(CKFolder *)folder progressBlock:(void (^)(float))progressBlock completionBlock:(CKArrayBlock)block {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/api/v1/folders/%llu/files", self.apiProtocol, self.hostname, folder.ident];
    NSURL *endpoint = [NSURL URLWithString:urlStr];
    
    [self _uploadFiles:fileURLs toEndpoint:endpoint progressBlock:progressBlock completionBlock:block];
}

- (void)_uploadFiles:(NSArray *)fileURLs toEndpoint:(NSURL *)endpoint progressBlock:(void (^)(float))progressBlock completionBlock:(CKArrayBlock)completionBlock {
    
    NSParameterAssert(completionBlock != nil);
    
    __block NSError *finalError = nil;
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableDictionary *progressDicts = [NSMutableDictionary new];
    NSMutableArray *observerObjs = [NSMutableArray new];
    
    NSMutableArray *attachments = [NSMutableArray new];
    for (NSURL *url in fileURLs) {
        dispatch_group_enter(group);
        [self uploadFileNamed:nil
                     location:url
                     endpoint:endpoint
                   folderPath:nil
                        block:
         ^(NSError *error, BOOL isFinalValue, CKAttachment *attachment) {
             dispatch_group_leave(group);
             if (finalError) { return; }
             
             if (error) {
                 finalError = error;
             }
             if (attachment) {
                 [attachments addObject:attachment];
             }
         }];
        
        if (progressBlock) {
            // Register for progress notifications
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:CKCanvasURLConnectionProgressNotification
                                                                            object:url
                                                                             queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:
                           ^(NSNotification *note) {
                               NSDictionary *userInfo = [note userInfo];
                               if (finalError) {
                                   // If we've found an error, cancel all other uploads
                                   // as soon as we hear back from them. No point in uploading
                                   // something we're just going to discard
                                   NSURLConnection *connection = userInfo[CKCanvasURLConnectionConnectionKey];
                                   [connection cancel];
                               }
                               progressDicts[url] = userInfo;
                               CGFloat progress = overallProgressForDictionaries([progressDicts allValues]);
                               progressBlock(progress);
                           }];
            [observerObjs addObject:observer];
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (id obs in observerObjs) {
            [[NSNotificationCenter defaultCenter] removeObserver:obs];
        }
        if (finalError) {
            completionBlock(finalError, YES, nil);
        }
        else {
            completionBlock(nil, YES, attachments);
        }
    });

}



// Will send progress notifications with the fileLocation as the object
- (void)uploadFileNamed:(NSString *)name location:(NSURL *)fileLocation endpoint:(NSURL *)endpoint folderPath:(NSString *)folder block:(CKAttachmentBlock)block {
    if (!name) {
        name = [fileLocation lastPathComponent];
    }
    
    NSNumber *fileSize;
    NSError *error;
    if (![fileLocation getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
        NSLog(@"File size was reported 0.");
        block(error, YES, nil);
        return;
    }
    
    NSData *fileData = [NSData dataWithContentsOfURL:fileLocation
                                             options:NSDataReadingMappedIfSafe
                                               error:NULL];
    if (!fileData) {
        NSDictionary *errorInfoDict = @{NSLocalizedDescriptionKey: NSLocalizedString(@"File upload failed.", 
                                                                                           @"File upload failed.")};
        error = [NSError errorWithDomain:CKCanvasErrorDomain code:CKCanvasErrorCodeFileUploadFailure userInfo:errorInfoDict];
        
        NSLog(@"File returned no data.");
        block(error, YES, nil);
        return;
    }
    
    
    [self getUploadTargetForEndpoint:endpoint forFileNamed:name size:fileSize contentType:nil folderPath:folder overwrite:NO block:^(NSError *error1, BOOL isFinalValue1, NSURL *uploadURL, NSDictionary *uploadParams) {
        if (error1) {
            NSLog(@"Error getting upload target: %@", error1);
            block(error1, isFinalValue1, nil);
            return;
        }
        
        [self uploadFileData:fileData withParams:uploadParams toURL:uploadURL progressObject:fileLocation
                       block:^(NSError *error2, BOOL isFinalValue2, NSURL *relocatedURL) {
            if (error2) {
                NSLog(@"Error uploading file: %@", error2);
                block(error2, isFinalValue2, nil);
                return;
            }

            [self confirmFileUploadedToURL:relocatedURL block:^(NSError *error3, BOOL isFinalValue3, CKAttachment *attachedFile) {
                if (error3) {
                    NSLog(@"Error finalizing file upload: %@", error3);
                    block(error3, isFinalValue3, nil);
                }
                
                block(nil, isFinalValue3, attachedFile);
                return;
            }];
        }];
    }];
    
}

/**
 * File Upload Part 1
 * See File Uploads in the API docs for more info.
 */
- (void)getUploadTargetForEndpoint:(NSURL *)endpoint forFileNamed:(NSString *)filename size:(NSNumber *)size contentType:(NSString *)contentType folderPath:(NSString *)folderPath overwrite:(BOOL)overwrite block:(CKUploadTargetBlock)block {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"name"] = filename;
    parameters[@"size"] = [size stringValue];
    if (contentType) {
        parameters[@"content_type"] = contentType;
    }
    if (folderPath) {
        parameters[@"folder"] = folderPath;
    }
    if (!overwrite) {
        parameters[@"on_duplicate"] = @"rename";
    }
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                             CKAPIHTTPPOSTParameters: parameters};
    
    [self runForURL:endpoint
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue , nil, nil);
                  }
                  else {
                      NSDictionary *responseDict = [apiResponse JSONValue];
                      NSURL *uploadURL = [NSURL URLWithString:responseDict[@"upload_url"]];
                      NSDictionary *uploadParams = responseDict[@"upload_params"];
                      block(nil, isFinalValue, uploadURL, uploadParams);
                  }
              }];
}

/**
 * File Upload Part 2
 * See File Uploads in the API docs for more info.
 */

- (void)uploadFileData:(NSData *)data 
            withParams:(NSDictionary *)params
                 toURL:(NSURL *)url
        progressObject:(id)progressObject
                 block:(CKURLBlock)block
{
    NSString *boundary = @"---------------------------3klfenalksjflkjoi9auf89eshajsnl3kjnwal";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"Content-Type"] = contentType;
    
    NSMutableData *body = [NSMutableData data];
    
    if (params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        for (id key in params) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, params[key]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"POST", CKAPIHTTPMethodKey,
                                    body, CKAPIHTTPBodyDataKey,
                                    @YES, CKAPIShouldIgnoreCacheKey,
                                    headers, CKAPIHTTPHeadersKey,
                                    @YES, CKAPINoAccessTokenRequired,
                                    @YES, CKAPIBlockRedirectsKey,
                                    @YES, CKAPINoMasqueradeIDRequired,
                                    nil];
    if (progressObject) {
        options[CKAPIProgressNotificationObjectKey] = progressObject;
    }
    
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  
                  if (error != nil) {
                      NSLog(@"Error uploading file: %@", error);
                      block(error, isFinalValue, nil);
                      return;
                  }
                  // Verify API acknowleged the upload, or report an error.
                  NSString *location = [apiResponse allHeaderFields][@"Location"];
                  NSURL *fileURL = [NSURL URLWithString:location];
                  if (!fileURL) {
                      NSDictionary *errorInfoDict = @{NSLocalizedDescriptionKey: NSLocalizedString(@"File upload failed.", 
                                                                                                         @"File upload failed.")};
                      error = [NSError errorWithDomain:CKCanvasErrorDomain code:CKCanvasErrorCodeFileUploadFailure userInfo:errorInfoDict];
                      
                      NSLog(@"WARNING: The File Upload API failed to return the final location of the uploaded file.");
                  }
                  block(error, isFinalValue, fileURL);
              }];
}

/**
 * File Upload Part 3
 * See File Uploads in the API docs for more info.
 */
- (void)confirmFileUploadedToURL:(NSURL *)fileURL block:(CKAttachmentBlock)block {
    
    NSDictionary *headers = @{@"Content-Length": @"0"};
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                             CKAPIHTTPHeadersKey: headers};
    
    [self runForURL:fileURL
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue , nil);
                  }
                  else {
                      NSDictionary *responseDict = [apiResponse JSONValue];
                      CKAttachment *attachment = [[CKAttachment alloc] initWithInfo:responseDict];
                      block(nil, isFinalValue, attachment);
                  }
              }];
}

////////////////////////////////////////////
#pragma mark - Submissions
////////////////////////////////////////////
#pragma mark (Viewing)
////////////////////////////////////////////

- (void)getSubmissionForAssignment:(CKAssignment *)assignment studentID:(uint64_t)studentId includeHistory:(BOOL)includeHistory block:(CKObjectBlock)block
{
    [self getSubmissionForCourseID:assignment.courseIdent assignmentID:assignment.ident studentID:studentId block:^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
        // Set the assignment on the submission, as lots of speedgrader stuff depends on that.
        submission.assignment = assignment;
        block(error, isFinalValue, submission);
    }];
}

- (void)getSubmissionForCourseID:(uint64_t)courseIdent assignmentID:(uint64_t)assignmentIdent studentID:(uint64_t)studentIdent block:(CKObjectBlock)block {

    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json?include[]=submission_history&include[]=rubric_assessment&include[]=submission_comments", self.apiProtocol, self.hostname, courseIdent, assignmentIdent, studentIdent];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *submissionInfo = [apiResponse JSONValue];
        CKSubmission *submission = [[CKSubmission alloc] initWithInfo:submissionInfo andAssignment:nil];
        
        block(nil, isFinalValue, submission);
    }];
}

- (void)getUpdatedSubmission:(CKSubmission *)submission block:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json", self.apiProtocol, self.hostname, submission.assignment.courseIdent, submission.assignment.ident, submission.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue);
            return;
        }
        
        NSDictionary *submissionInfo = [apiResponse JSONValue];
        
        if (!submissionInfo) {
            NSLog(@"Submission info was null when getting the comments.");
        }
        
        [submission updateWithInfo:submissionInfo];
        
        block(nil, isFinalValue);
    }];

}

- (void)getCommentsForSubmission:(CKSubmission *)submission block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json?include=submission_comments", self.apiProtocol, self.hostname, submission.assignment.courseIdent, submission.assignment.ident, submission.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *submissionInfo = [apiResponse JSONValue];
        
        if (!submissionInfo) {
            NSLog(@"Submission info was null when getting the comments.");
        }
        
        NSMutableArray *tempComments = [NSMutableArray array];
        for (NSDictionary *commentInfo in submissionInfo[@"submission_comments"]) {
            CKSubmissionComment *newComment = [[CKSubmissionComment alloc] initWithInfo:commentInfo andSubmission:submission];
            [tempComments addObject:newComment];
        }
        
        block(nil, isFinalValue, tempComments);
    }];
}


- (CKCanvasURLConnection *)getURLForAttachment:(CKAttachment *)attachment block:(CKURLBlock)block
{
    NSURL *url = [attachment directDownloadURL];
    if (attachment.mediaId) {
        url = [self thumbnailDirectDownloadURLForMediaComment:(CKMediaComment *)attachment];
    }
    NSURL *diskURL = [attachment cacheURL];
    
    NSURL *fallbackURL = nil;
    if (attachment.mediaId) {
        
        if ([attachment isKindOfClass:[CKMediaComment class]]) {
            CKMediaComment *mediaComment = (CKMediaComment *)attachment;
            if (mediaComment.mediaType == CKAttachmentMediaTypeVideo) {
                fallbackURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video-thumbnail-placeholder" withExtension:@"png"];
            }
        }
        
        diskURL = [attachment thumbnailCacheURL];
    }

    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *fileError = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:diskURL.path error:&fileError];
    
    // we check if fileSize == 0 for "dummy" attachments used in SpeedGrader
    if (!fileError && (attachment.fileSize == 0 || fileAttributes.fileSize == attachment.fileSize)) {
        block(nil, YES, diskURL);
        return nil;
    }
    
    // Get the Downloads In Progress directory path. Append a timestamp onto the end of the filename to create a unique tmpPath.
    NSString *uniqueFilename = [[[diskURL path] lastPathComponent] stringByAppendingFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
    NSString *tmpPath = [(NSString *)CKDownloadsInProgressDirectory() stringByAppendingPathComponent:uniqueFilename];
    NSString *attachmentDir = [[diskURL path] stringByDeletingLastPathComponent];
    NSError *err;
    if (![fileManager createDirectoryAtPath:attachmentDir withIntermediateDirectories:YES attributes:nil error:&err]) {
        NSLog(@"Could not create attachment dir: %@ error: %@", attachmentDir, err);
        // TODO: how to handle? direct URL download?
    }
    
    [fileManager createFileAtPath:tmpPath contents:[NSData data] attributes:nil];
    __block NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:tmpPath];
    if (fh == nil) {
        NSLog(@"Could not open file for writing: %@", tmpPath);
        // TODO: how to handle this? fall back to direct URL download?
    }
    
    block = [block copy];

    NSString *urlString = [url absoluteString];
    urlString = [urlString stringByAppendingFormat:@"%@user_id=%@",
                 [urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&",
                 @(self.user.ident)];
    
    return [self runForURL:[NSURL URLWithString:urlString]
                   options:@{CKAPIProgressNotificationObjectKey: attachment,
                            CKAPIOutputFileHandleKey: fh}
                     block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                         BOOL responseIsEmpty = ([fh offsetInFile] == 0);
                         [fh closeFile];
                         fh = nil;
                         if (error != nil) {
                             if (error.code == NSURLErrorCancelled) {
                                 NSError *fileError = nil;
                                 [fileManager removeItemAtPath:tmpPath error:&fileError];
                                 if (fileError) {
                                     NSLog(@"Unable to remove file. Error: %@", error);
                                 }
                             }
                             block(error, isFinalValue, nil);
                             return;
                         }
                         
                         if (fallbackURL && responseIsEmpty) {
                             // Just use the fallback URL
                             block(nil, isFinalValue, fallbackURL);
                         }
                         else {
                             [fileManager moveItemAtPath:tmpPath toPath:[diskURL path] error:nil];
            
                             block(nil, isFinalValue, diskURL);
                         }
                     }];
    
}

- (NSURL *)thumbnailDirectDownloadURLForMediaComment:(CKMediaComment *)comment {
    if ([comment.mediaId length] > 0 && [self.mediaServer isEnabled]) {
        NSString *urlString = nil;
        if (comment.mediaType == CKAttachmentMediaTypeAudio) {
            urlString = [NSString stringWithFormat:@"%@/p/%llu/thumbnail/entry_id/%@/width/320/height/75/bgcolor/000000/type/1/vid_sec/5",
                         self.mediaServer.resourceDomain, self.mediaServer.partnerId, comment.mediaId];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@/p/%llu/thumbnail/entry_id/%@/width/320/height/240/bgcolor/000000/type/1/vid_sec/5",
                         self.mediaServer.resourceDomain, self.mediaServer.partnerId, comment.mediaId];
        }
        
        return [NSURL URLWithString:urlString];
    }
    else {
        return nil;
    }
}


- (CKCanvasURLConnection *)downloadAttachment:(CKAttachment *)attachment progressBlock:(void (^)(float progress))progressBlock completionBlock:(CKURLBlock)completionBlock {
    
    id observer = nil;
    if (progressBlock) {
        // Register for progress notifications
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:CKCanvasURLConnectionProgressNotification
                                                                        object:attachment
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:
                       ^(NSNotification *note) {
                           NSDictionary *userInfo = [note userInfo];
                           
                           NSArray *progressDicts = @[userInfo];
                           CGFloat progress = overallProgressForDictionaries(progressDicts);
                           progressBlock(progress);
                       }];
    }
    
    return [self getURLForAttachment:attachment block:^(NSError *error, BOOL isFinalValue, NSURL *url) {
        if (isFinalValue) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        completionBlock(error, isFinalValue, url);
    }];
}

////////////////////////////////////////////
#pragma mark (Comments)
////////////////////////////////////////////

- (void)postMediaCommentURL:(NSURL *)mediaURL
             forCourseIdent:(uint64_t)courseIdent
            assignmentIdent:(uint64_t)assignmentIdent
               studentIdent:(uint64_t)studentIdent
              progressBlock:(void(^)(float progress))progressBlock
            completionBlock:(CKSubmissionBlock)completionBlock
{
    
    CKAttachmentMediaType ckMediaType = CKAttachmentMediaTypeUnknown;
    
    NSString *mediaType;
    NSError *error;
    if (![mediaURL getResourceValue:&mediaType forKey:NSURLTypeIdentifierKey error:&error]) {
        completionBlock(error, YES, nil);
    }
    CFStringRef cfMediaType = (__bridge CFStringRef)mediaType;
    if (UTTypeConformsTo(cfMediaType, kUTTypeMovie)) {
        ckMediaType = CKAttachmentMediaTypeVideo;
    }
    else if (UTTypeConformsTo(cfMediaType, kUTTypeAudio)) {
        ckMediaType = CKAttachmentMediaTypeAudio;
    }
    else {
        NSAssert(NO, @"Invalid media type %@", mediaType);
    }
    
    id observerObj;
    
    NSString *path = mediaURL.path;
    if (progressBlock) {
        // Register for progress notifications
        observerObj = [[NSNotificationCenter defaultCenter] addObserverForName:CKCanvasURLConnectionProgressNotification
                                                                        object:path
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:
                       ^(NSNotification *note) {
                           NSDictionary *userInfo = [note userInfo];
                           
                           NSArray *progressDicts = @[userInfo];
                           CGFloat progress = overallProgressForDictionaries(progressDicts);
                           progressBlock(progress);
                       }];
    }
    
    [self postMediaCommentAtPath:path ofMediaType:ckMediaType block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
        [[NSNotificationCenter defaultCenter] removeObserver:observerObj];
        if (error) {
            completionBlock(error, YES, nil);
        }
        else {
            if (progressBlock) {
                progressBlock(1.1);
            }
            [self postComment:NSLocalizedString(@"Media Comment",nil) mediaId:mediaId mediaType:ckMediaType forCourseIdent:courseIdent assignmentIdent:assignmentIdent studentIdent:studentIdent block:
             ^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                 completionBlock(error, isFinalValue, submission);
             }];
        }
    }];
}



- (void)postComment:(NSString *)comment mediaId:(NSString *)mediaId mediaType:(CKAttachmentMediaType)mediaType forSubmission:(CKSubmission *)submission block:(CKSubmissionBlock)block
{
    [self postComment:comment mediaId:mediaId mediaType:mediaType forCourseIdent:submission.assignment.courseIdent assignmentIdent:submission.assignment.ident studentIdent:submission.studentIdent block:
     ^(NSError *error, BOOL isFinalValue, CKSubmission *wrappedAttempt) {
         // Existing callers rely on the comments being updated
        [submission updateCommentsWithSubmission:wrappedAttempt];
         block(error, isFinalValue, wrappedAttempt);
     }];
}

- (void)postComment:(NSString *)comment mediaId:(NSString *)mediaId mediaType:(CKAttachmentMediaType)mediaType forCourseIdent:(uint64_t)courseIdent assignmentIdent:(uint64_t)assignmentIdent studentIdent:(uint64_t)studentIdent block:(CKSubmissionBlock)block
{

    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json",
                           self.apiProtocol,
                           self.hostname,
                           courseIdent,
                           assignmentIdent,
                           studentIdent];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       comment, @"comment[text_comment]",
                                       nil];
    if (mediaId) {
        parameters[@"comment[media_comment_id]"] = mediaId;
        
        NSString *mediaTypeString = nil;
        if (mediaType == CKAttachmentMediaTypeAudio) {
            mediaTypeString = @"audio";
        }
        else {
            mediaTypeString = @"video";
        }
        
        parameters[@"comment[media_comment_type]"] = mediaTypeString;
    }
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"PUT", CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *submissionInfo = [apiResponse JSONValue];
                  CKSubmission *submission = [[CKSubmission alloc] initWithInfo:submissionInfo andAssignment:nil];
                  
                  block(nil, isFinalValue, submission);
              }];
}

////////////////////////////////////////////
#pragma mark (Uploading)
////////////////////////////////////////////

static CGFloat overallProgressForDictionaries(NSArray *progressDicts) {
    uint64_t totalExpected = 0;
    uint64_t totalCurrent = 0;
    
    for (NSDictionary *dict in progressDicts) {
        uint64_t current = [dict[CKCanvasURLConnectionProgressCurrentBytesKey] longLongValue];
        uint64_t expected = [dict[CKCanvasURLConnectionProgressExpectedBytesKey] longLongValue];
        totalExpected += expected;
        totalCurrent += current;
    }
    
    return (CGFloat)( (double)totalCurrent / (double)totalExpected );
}

- (void)determineURLForUploadSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(void (^)(NSError *error, BOOL isFinalValue, NSURL *url))completed {
    NSURL *selfURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu/files",
                                       self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident, self.user.ident]];
    
    if (assignment.groupCategoryID == nil) {
        completed(nil, YES, selfURL);
        return;
    }
    
    NSURL *groupsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/users/self/groups", self.apiProtocol, self.hostname]];
    
    
    [self runForURL:groupsURL options:@{} block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            completed(error, YES, nil);
            return;
        }
        
        NSArray *json = [apiResponse JSONValue];
        if (![json isKindOfClass:[NSArray class]]) {
            completed(nil, YES, selfURL);
            return;
        }
        for (NSDictionary *groupJSON in json) {
            NSNumber *groupID = groupJSON[@"id"];
            NSNumber *groupCategoryID = groupJSON[@"group_category_id"];
            if ([groupCategoryID isEqual:assignment.groupCategoryID]) {
                NSString *groupUploadURLString = [NSString stringWithFormat:@"%@://%@/api/v1/groups/%@/files", self.apiProtocol, self.hostname, groupID];
                completed(nil, YES, [NSURL URLWithString:groupUploadURLString]);
                return;
            }
        }
        
        completed(nil, YES, selfURL);
    }];
}

- (void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment
       progressBlock:(void (^)(float))progressBlock
     completionBlock:(CKSubmissionBlock)completionBlock {

    [self determineURLForUploadSubmissionForAssignment:assignment completionBlock:^(NSError *error, BOOL isFinalValue, NSURL *endpoint) {
        
        [self _uploadFiles:files toEndpoint:endpoint progressBlock:progressBlock completionBlock:^(NSError *error, BOOL isFinalValue, NSArray *attachments) {
            if (error) {
                completionBlock(error, isFinalValue, nil);
            }
            else {
                [self postAttachments:attachments asSubmissionForAssignment:(CKAssignment *)assignment block:
                 ^(NSError *postingError, BOOL isFinalValue, CKSubmission *submission) {
                     completionBlock(postingError, isFinalValue, submission);
                 }];
            }
        }];
    }];
}

- (void)postMediaURL:(NSURL *)mediaURL asSubmissionForAssignment:(CKAssignment *)assignment progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)completionBlock {
    
    CKAttachmentMediaType ckMediaType = CKAttachmentMediaTypeUnknown;
    
    NSString *mediaType;
    NSError *error;
    if (![mediaURL getResourceValue:&mediaType forKey:NSURLTypeIdentifierKey error:&error]) {
        completionBlock(error, YES, nil);
    }
    CFStringRef cfMediaType = (__bridge CFStringRef)mediaType;
    if (UTTypeConformsTo(cfMediaType, kUTTypeMovie)) {
        ckMediaType = CKAttachmentMediaTypeVideo;
    }
    else if (UTTypeConformsTo(cfMediaType, kUTTypeAudio)) {
        ckMediaType = CKAttachmentMediaTypeAudio;
    }
    else {
        NSAssert(NO, @"Invalid media type %@", mediaType);
    }
    
    id observerObj;

    NSString *path = mediaURL.path;
    if (progressBlock) {
        // Register for progress notifications
        observerObj = [[NSNotificationCenter defaultCenter] addObserverForName:CKCanvasURLConnectionProgressNotification
                                                                        object:path
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:
                       ^(NSNotification *note) {
                           NSDictionary *userInfo = [note userInfo];
                           
                           NSArray *progressDicts = @[userInfo];
                           CGFloat progress = overallProgressForDictionaries(progressDicts);
                           progressBlock(progress);
                       }];
    }

    [self postMediaCommentAtPath:path ofMediaType:ckMediaType block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
        [[NSNotificationCenter defaultCenter] removeObserver:observerObj];
        if (error) {
            completionBlock(error, YES, nil);
        }
        else {
            [self postMediaId:mediaId mediaType:mediaType asSubmissionForAssignment:assignment block:
             ^(NSError *error, BOOL isFinalValue, CKSubmission *submission) {
                 completionBlock(error, isFinalValue, submission);
             }];
        }
    }]; 
}


- (void)postHTML:(NSString *)text asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions",
                           self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *postParams = @{@"submission[submission_type]": @"online_text_entry",
                                @"submission[body]": text};
    
    [self runForURL:url
            options:@{CKAPIHTTPPOSTParameters: postParams,
                     CKAPIHTTPMethodKey: @"POST"}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *response = [apiResponse JSONValue];
                  CKSubmission *attempt = [[CKSubmission alloc] initWithInfo:response andAssignment:assignment];
                  block(nil, isFinalValue, attempt);
              }];
}

- (void)postURL:(NSURL *)contentURL asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions",
                           self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *postParams = @{@"submission[submission_type]": @"online_url",
                                @"submission[url]": contentURL.absoluteString};
    
    [self runForURL:url
            options:@{CKAPIHTTPPOSTParameters: postParams,
                     CKAPIHTTPMethodKey: @"POST"}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *response = [apiResponse JSONValue];
                  CKSubmission *attempt = [[CKSubmission alloc] initWithInfo:response andAssignment:assignment];
                  block(nil, isFinalValue, attempt);
              }];
}

- (void)postAttachments:(NSArray *)attachments asSubmissionForAssignment:(CKAssignment *)assignment block:(CKSubmissionBlock)block {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions",
                           self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSArray *attachmentIDs = [attachments valueForKey:@"ident"];
    NSDictionary *postParams = @{@"submission[file_ids]": attachmentIDs,
                                @"submission[submission_type]": @"online_upload"};
    
    [self runForURL:url
            options:@{CKAPIHTTPPOSTParameters: postParams,
                     CKAPIHTTPMethodKey: @"POST"}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *response = [apiResponse JSONValue];
                  CKSubmission *attempt = [[CKSubmission alloc] initWithInfo:response andAssignment:assignment];
                  block(nil, isFinalValue, attempt);
              }];
}

- (void)postMediaId:(NSString *)mediaID mediaType:(CKAttachmentMediaType)mediaType asSubmissionForAssignment:(CKAssignment *)assignment block:(CKSubmissionBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions",
                           self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *mediaCommentTypeString;
    switch (mediaType) {
        case CKAttachmentMediaTypeVideo:
            mediaCommentTypeString = @"video";
            break;
            
        case CKAttachmentMediaTypeAudio:
            mediaCommentTypeString = @"audio";
            break;
            
        default:
            NSAssert(NO, @"Invalid media type");
            break;
    }
    NSDictionary *postParams = @{@"submission[media_comment_id]": mediaID,
                                @"submission[media_comment_type]": mediaCommentTypeString,
                                @"submission[submission_type]": @"media_recording"};
    
    [self runForURL:url
            options:@{CKAPIHTTPPOSTParameters: postParams,
                     CKAPIHTTPMethodKey: @"POST"}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *response = [apiResponse JSONValue];
                  CKSubmission *attempt = [[CKSubmission alloc] initWithInfo:response andAssignment:assignment];
                  block(nil, isFinalValue, attempt);
              }];
}

////////////////////////////////////////////
#pragma mark - Media Comments
////////////////////////////////////////////

- (void)getMediaServerConfigurationWithBlock:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/services/kaltura.json", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES);
        return;
    }
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
          block(error, isFinalValue);
          return;
        }
        
        NSDictionary *responseDict = [apiResponse JSONValue];
        
        if (isFinalValue) {
            self.mediaServer = [[CKMediaServer alloc] initWithInfo:responseDict];
        }

        block(nil, isFinalValue);
    }];
    
}

- (void)postMediaCommentAtPath:(NSString *)path ofMediaType:(CKAttachmentMediaType)mediaType block:(CKMediaBlock)block
{
    // If the media server is disabled or nil, return an error
    if (!self.mediaServer || ![self.mediaServer isEnabled]) {
        block([NSError errorWithDomain:CKCanvasErrorDomain code:CKCanvasErrorCodeMediaServerDisabled userInfo:nil], YES, mediaType, nil);
        return;
    }
    
    // Note - this code assumes that none of the calls being made will be cached. Please make that stay true.
    block = [block copy];
    [self getMediaRecordingSessionWithBlock:^(NSError *error1, BOOL requestsDone1, NSString *sessionId) {
        if (error1) {
            NSLog(@"error getting media recording session: %@", error1);
            block(error1, requestsDone1, mediaType, nil);
            return;
        }
        
        [self getFileUploadTokenWithSessionId:sessionId block:^(NSError *error2, BOOL requestsDone2, NSString *token) {
            if (error2) {
                NSLog(@"error getting upload token: %@", error2);
                block(error2, requestsDone2, mediaType, nil);
                return;
            }
            
            [self uploadFileAtPath:path ofMediaType:mediaType withToken:token sessionId:sessionId block:^(NSError *error3, BOOL requestsDone3) {
                if (error3) {
                    NSLog(@"error uploading file: %@", error3);
                    block(error3, requestsDone3, mediaType, nil);
                    return;
                }
                
                [self getMediaIdForUploadedFileToken:token withMediaType:mediaType sessionId:sessionId block:^(NSError *error4, BOOL requestsDone4, NSString *mediaId) {
                    if (error4) {
                        NSLog(@"error getting media id: %@", error4);
                        block(error4, requestsDone4, mediaType, mediaId);
                        return;
                    }
                    
                    block(error4, requestsDone4, mediaType, mediaId);
                }];
            }];
        }];
    }];
}

//////////////////////////////////////
#pragma mark - Files
//////////////////////////////////////

- (void)listFoldersInFolder:(CKFolder *)folder pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block {
    NSURL *url = pageURLOrNil;
    if (!url) {
        url = folder.foldersURL;
        
        NSString *baseURLStr = [url absoluteString];
        NSString *fullURLStr = [baseURLStr stringByAppendingFormat:@"?per_page=%d", self.itemsPerPage];

        url = [NSURL URLWithString:fullURLStr];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    [self runForURL:url options:options block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, nil, 0);
             return;
         }
         NSArray *response = [apiResponse JSONValue];
         
         NSMutableArray *folders = [NSMutableArray new];
         for (NSDictionary *info in response) {
             CKFolder *folder = [[CKFolder alloc] initWithInfo:info];
             [folders addObject:folder];
         }
         
         CKPaginationInfo *paginationInfo = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
         
         block(error, folders, paginationInfo);
     }];

}

- (void)listFilesInFolder:(CKFolder *)folder pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block {
    NSURL *url = pageURLOrNil;
    if (!url) {
        url = folder.filesURL;
        
        NSString *baseURLStr = [url absoluteString];
        NSString *fullURLStr = [baseURLStr stringByAppendingFormat:@"?per_page=%d", self.itemsPerPage];
        
        url = [NSURL URLWithString:fullURLStr];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    [self runForURL:url options:options block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, nil, 0);
             return;
         }
         NSArray *response = [apiResponse JSONValue];
         
         NSMutableArray *files = [NSMutableArray new];
         for (NSDictionary *info in response) {
             CKAttachment *file = [[CKAttachment alloc] initWithInfo:info];
             [files addObject:file];
         }
         
         CKPaginationInfo *paginationInfo = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
         
         block(error, files, paginationInfo);
     }];

}

- (void)getFileWithId:(uint64_t)fileIdent block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/files/%qu", self.apiProtocol, self.hostname, fileIdent];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        NSDictionary *info = [apiResponse JSONValue];
        CKAttachment *file = [[CKAttachment alloc] initWithInfo:info];
        
        block(error, isFinalValue, file);
    }];
}

- (void)getRootFolderForContext:(CKContextInfo *)contextInfo block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/folders/root", self.apiProtocol, self.hostname, contextInfo.typeComponentForURLs, contextInfo.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    [self runForURL:url options:options block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, isFinalValue, nil);
             return;
         }
         NSDictionary *info = [apiResponse JSONValue];
         CKFolder *folder = [[CKFolder alloc] initWithInfo:info];
         
         block(error, isFinalValue, folder);
     }];
}

- (void)getFolderWithId:(uint64_t)ident block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/folders/%llu", self.apiProtocol, self.hostname, ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self runForURL:url options:0 block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, isFinalValue, nil);
             return;
         }
         NSDictionary *response = [apiResponse JSONValue];
         
         CKFolder *folder = [[CKFolder alloc] initWithInfo:response];
       
         block(error, isFinalValue, folder);
     }];

}

- (NSString *)_apiRouteForFolderContext:(CKFolder *)folder {
    NSString *contextString = nil;
    switch (folder.contextType) {
        case CKContextTypeCourse:
            contextString = @"courses";
            break;
        case CKContextTypeUser:
            contextString = @"users";
            break;
        case CKContextTypeGroup:
            contextString = @"groups";
            break;
        case CKContextTypeNone:
            break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"/api/v1/%@/%@", contextString, folder.contextIdent];
    return urlString;
}

- (void)createFolderInFolder:(CKFolder *)parentFolder withName:(NSString *)name block:(CKObjectBlock)block {

    NSString *apiRoute = [self _apiRouteForFolderContext:parentFolder];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@/folders", self.apiProtocol, self.hostname, apiRoute];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *parameters = @{
      @"parent_folder_id" : [@(parentFolder.ident) stringValue],
      @"name" : name
    };
    NSDictionary *options = @{ CKAPIShouldIgnoreCacheKey : @(YES),
                               CKAPIHTTPPOSTParameters : parameters,
                               CKAPIHTTPMethodKey : @"POST"};
    
    [self runForURL:url options:options block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, isFinalValue, nil);
         }
         else {
             NSDictionary *response = [apiResponse JSONValue];
             CKFolder *folder = [[CKFolder alloc] initWithInfo:response];
             block(error, isFinalValue, folder);
         }
     }];
}

- (void)deleteFolderItems:(NSArray *)foldersAndAttachments withBlock:(CKFailuresDictionaryBlock)failedDownloadsHandler {
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableDictionary *errors = [NSMutableDictionary new];
    
    for (id item in foldersAndAttachments) {
        NSString *urlString = nil;
        if ([item isKindOfClass:[CKFolder class]]) {
            urlString = [NSString stringWithFormat:@"%@://%@/api/v1/folders/%llu?force=true", self.apiProtocol, self.hostname, [item ident]];
        }
        else if ([item isKindOfClass:[CKAttachment class]]) {
            urlString = [NSString stringWithFormat:@"%@://%@/api/v1/files/%llu", self.apiProtocol, self.hostname, [item ident]];
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSDictionary *options = @{ CKAPIHTTPMethodKey : @"DELETE" };
        
        dispatch_group_enter(group);
        [self runForURL:url options:options block:
         ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
             if (error) {
                 errors[item] = error;
             }
             dispatch_group_leave(group);
         }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        failedDownloadsHandler(errors, YES);
    });
    
}

//////////////////////////////////////
#pragma mark - Mock Response/Cache
//////////////////////////////////////

- (void)setupSharedURLCache {
    NSUInteger memoryCapacity = 2 * 1024 * 1024; // 2 MB
    NSUInteger diskCapacity = 80 * 1024 * 1024; // 80 MB
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:@"Cache.db"];
        [NSURLCache setSharedURLCache:cache];
        
    });
}

- (void)ensureURLCacheHasMemoryCapacity {
    // For some reason, the NSURLCache occasionally likes to drop its memoryCapacity to 0, even
    // when it actually has things stored. This is super lame.  Fixed in iOS 6.
    [[NSURLCache sharedURLCache] setMemoryCapacity:2 * 1024 * 1024];
}

////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////
#pragma mark (Kaltura Media)
////////////////////////////////////////////

- (void)getMediaRecordingSessionWithBlock:(CKStringBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/services/kaltura_session",
                           self.apiProtocol,
                           self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    // TODO: change this into an autheticated call when #4068 is done.
    [self runForURL:url
            options:@{CKAPIShouldIgnoreCacheKey: @YES, 
                     CKAPIHTTPMethodKey: @"POST"}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            NSLog(@"error: %@", error);
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *result = [apiResponse JSONValue];
        NSString *ks = [result objectForKeyCheckingNull:@"ks"];
        
        block(nil, isFinalValue, ks);
    }];
}


- (void)getFileUploadTokenWithSessionId:(NSString *)sessionId block:(CKStringBlock)block
{
    // POST http://www.kaltura.com/api_v3/index.php?service=uploadtoken&action=add
    // ks=NGMwNzVmZmM2NzUwOWEyZmRiYmYzNDU5OGVmOTAxYTdiY2E5ZjU4MnwxNTY2NTI7MTU2NjUyOzEyNzk2NTY3NTQ7MDsxMjc5NTcwMzU0LjQ3NDk7MjMxODkwXzEwOw%3D%3D
    // response: <?xml version="1.0" encoding="utf-8"?><xml><result><objectType>KalturaUploadToken</objectType><id>0_5e929ce09b1155753a3921e78d65e992</id><partnerId>156652</partnerId><userId>231890_10</userId><status>0</status><fileName></fileName><fileSize></fileSize><uploadedFileSize></uploadedFileSize><createdAt>1279570943</createdAt><updatedAt>1279570943</updatedAt></result><executionTime>0.034272909164429</executionTime></xml>
    NSURL *url = [self.mediaServer apiURLAdd];

    NSDictionary *parameters = @{@"ks": sessionId};
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"POST",
                     CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            NSLog(@"Error getting file upload token: %@", error);
            block(error, isFinalValue, nil);
            return;
        }
        
        CXMLDocument *doc = [apiResponse XMLValue];
        if (!doc) {
            NSLog(@"Error parsing XML: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue, nil);
            return;
        }
        
        CXMLElement *el = [doc rootElement];
        NSError *xmlError = nil;
        CXMLNode *tokenIdNode = [el nodeForXPath:@"/xml/result/id" error:&xmlError];
        if (!tokenIdNode || xmlError) {
            NSLog(@"Could not find session id in xml: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue, nil);
            return;
        }
        
        block(nil, isFinalValue, [tokenIdNode stringValue]);
    }];
}


- (void)uploadFileAtPath:(NSString *)path ofMediaType:(CKAttachmentMediaType)mediaType withToken:(NSString *)token sessionId:(NSString *)sessionId block:(CKSimpleBlock)block
{
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    NSInteger maxFileSize = 524288000; // 500 MB
    
    [pathURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&fileSizeError];
    if (fileSizeValue.integerValue > maxFileSize) {
        
        NSByteCountFormatter *formatter = [NSByteCountFormatter new];
        NSString *template = NSLocalizedString(@"The file you are trying to uploading is %@, but the maximum size is %@.", @"Error description when a user tries to upload a file that's too big");
        NSString *errorDescription = [NSString localizedStringWithFormat:template, [formatter stringFromByteCount:fileSizeValue.longLongValue], [formatter stringFromByteCount:maxFileSize]];
        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: errorDescription};
        NSError *error = [NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:userInfo];
        block(error, nil);
        return;
    }
    
    // POST http://www.kaltura.com/api_v3/index.php?service=uploadtoken&action=upload
    // (multipart body:)
    // ks=blah
    // uploadTokenId=from above # Content-Disposition: form-data; name="uploadTokenId" 
    // fileData=<file data>  # Content-Disposition: form-data; name="fileData"; filename="2010-07-19 13:20:06 -0600.mov"
    // response: <?xml version="1.0" encoding="utf-8"?><xml><result><objectType>KalturaUploadToken</objectType><id>0_5e929ce09b1155753a3921e78d65e992</id><partnerId>156652</partnerId><userId>231890_10</userId><status>2</status><fileName>2010-07-19 13:20:06 -0600.mov</fileName><fileSize></fileSize><uploadedFileSize>213603</uploadedFileSize><createdAt>1279570943</createdAt><updatedAt>1279571114</updatedAt></result><executionTime>0.051121950149536</executionTime></xml>
    NSURL *url = [self.mediaServer apiURLUpload];
    
    block = [block copy];
    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"POST",
                              CKAPIShouldIgnoreCacheKey: @YES,
                              CKAPIProgressNotificationObjectKey: path};
    
    NSMutableURLRequest *request = [self mutableRequestForURL:url options:options];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [CKCanvasAPIResponseParser new];
    NSString *stringURL = request.URL.absoluteString;
    [manager POST:stringURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[sessionId dataUsingEncoding:NSUTF8StringEncoding] name:@"ks"];
        [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"uploadTokenId"];
        
        if (mediaType == CKAttachmentMediaTypeAudio) {
            [formData appendPartWithFileURL:pathURL name:@"fileData" fileName:@"audiocomment.wav" mimeType:@"audio/x-aiff" error:nil];
        }
        else {
            
            [formData appendPartWithFileURL:pathURL name:@"fileData" fileName:@"videocomment.mp4" mimeType:@"video/mp4" error:nil];
        }
        
    } progress:^(NSProgress *progress) {
        
        NSDictionary *info = @{CKCanvasURLConnectionProgressPercentageKey: @(progress.fractionCompleted),
                               CKCanvasURLConnectionProgressCurrentBytesKey: @(progress.completedUnitCount),
                               CKCanvasURLConnectionProgressExpectedBytesKey: @(progress.totalUnitCount)};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CKCanvasURLConnectionProgressNotification
                                                            object:path
                                                          userInfo:info];
        
    } success:^(NSURLSessionDataTask *task, CKCanvasAPIResponse *apiResponse) {
        
        BOOL isFinalValue = YES;
        
        // Verify that the returned token id is the same. If it is, we assume the upload succeeded.
        CXMLDocument *doc = [apiResponse XMLValue];
        if (!doc) {
            NSLog(@"Error parsing XML: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue);
            return;
        }
        
        CXMLElement *el = [doc rootElement];
        NSError *xmlError = nil;
        CXMLNode *tokenIdNode = [el nodeForXPath:@"/xml/result/id" error:&xmlError];
        if (!tokenIdNode || xmlError) {
            NSLog(@"Could not find token id in xml: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue);
            return;
        }
        
        if (![[tokenIdNode stringValue] isEqualToString:token]) {
            NSLog(@"token id from response: %@ does not match supplied token: %@", [tokenIdNode stringValue], token);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue);
            return;
        }
        
        block(nil, isFinalValue);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error != nil) {
            NSLog(@"Error uploading media comment: %@", error);
            block(error, YES);
            return;
        }
    }];
}


- (void)getMediaIdForUploadedFileToken:(NSString *)token withMediaType:(CKAttachmentMediaType)mediaType sessionId:(NSString *)sessionId block:(CKStringBlock)block
{
    // POST http://www.kaltura.com/api_v3/index.php?service=media&action=addFromUploadedFile
    // ks=NGMwNzVmZmM2NzUwOWEyZmRiYmYzNDU5OGVmOTAxYTdiY2E5ZjU4MnwxNTY2NTI7MTU2NjUyOzEyNzk2NTY3NTQ7MDsxMjc5NTcwMzU0LjQ3NDk7MjMxODkwXzEwOw%3D%3D
    // uploadTokenId=0_5e929ce09b1155753a3921e78d65e992
    // mediaEntry%3Aname=zach+test+3
    // mediaEntry%3AmediaType=5
    // response: <?xml version="1.0" encoding="utf-8"?><xml><result><objectType>KalturaMediaEntry</objectType><id>0_e3ropkdb</id><name>zach test 3</name><description></description><partnerId>156652</partnerId><userId>231890_10</userId><tags></tags><adminTags></adminTags><categories></categories><status>1</status><moderationStatus>6</moderationStatus><moderationCount>0</moderationCount><type>1</type><createdAt>1279571324</createdAt><rank>0</rank><totalRank>0</totalRank><votes>0</votes><groupId></groupId><partnerData></partnerData><downloadUrl>http://cdnbakmi.kaltura.com/p/156652/sp/15665200/raw/entry_id/0_e3ropkdb/version/0</downloadUrl><searchText>  zach test 3 </searchText><licenseType>-1</licenseType><version>0</version><thumbnailUrl>http://cdnbakmi.kaltura.com/p/156652/sp/15665200/thumbnail/entry_id/0_e3ropkdb/version/0</thumbnailUrl><accessControlId>63362</accessControlId><startDate></startDate><endDate></endDate><plays>0</plays><views>0</views><width></width><height></height><duration>0</duration><msDuration>0</msDuration><durationType></durationType><mediaType>5</mediaType><conversionQuality></conversionQuality><sourceType>1</sourceType><searchProviderType></searchProviderType><searchProviderId></searchProviderId><creditUserName></creditUserName><creditUrl></creditUrl><mediaDate></mediaDate><dataUrl>http://cdnbakmi.kaltura.com/p/156652/sp/15665200/flvclipper/entry_id/0_e3ropkdb/version/0</dataUrl><flavorParamsIds></flavorParamsIds></result><executionTime>6.2773299217224</executionTime></xml>
    NSURL *url = [self.mediaServer apiURLAddFromUploadedFile];
    
    NSString *mediaTypeString = (mediaType == CKAttachmentMediaTypeVideo ? @"1" : @"5");
    
    NSDictionary *parameters = @{@"ks": sessionId,
                                @"uploadTokenId": token,
                                @"mediaEntry:name": @"Media Comment",
                                @"mediaEntry:mediaType": mediaTypeString};
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"POST",
                     CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            NSLog(@"Error getting media id for uploaded file: %@", error);
            block(error, isFinalValue, nil);
            return;
        }
        
        CXMLDocument *doc = [apiResponse XMLValue];
        if (!doc) {
            NSLog(@"Error parsing XML: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue, nil);
            return;
        }
        
        CXMLElement *el = [doc rootElement];
        NSError *xmlError = nil;
        CXMLNode *mediaIdNode = [el nodeForXPath:@"/xml/result/id" error:&xmlError];
        if (!mediaIdNode || xmlError) {
            NSLog(@"Could not find media id in xml: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue, nil);
            return;
        }
        
        NSString *mediaId = [mediaIdNode stringValue];
        if (!mediaId || (id)mediaId == [NSNull null] || [mediaId length] == 0) {
            NSLog(@"Did not get back a media id in xml: %@", [[NSString alloc] initWithData:apiResponse.data encoding:NSUTF8StringEncoding]);
            block([NSError errorWithDomain:CKCanvasErrorDomain code:1 userInfo:nil], isFinalValue, nil);
            return;
        }
        
        block(nil, isFinalValue, [mediaIdNode stringValue]);
    }];
}

////////////////////////////////////////////
#pragma mark (URL Requests)
////////////////////////////////////////////

- (NSString *)cachePathForURL:(NSURL *)url
{
    NSMutableString *key = [self.authString mutableCopy];
    if (!key) {
        key = [self.accessToken mutableCopy];
    }
    if (self.actAsId) {
        [key appendFormat:@"|%@", self.actAsId];
    }
    
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths[0];
    NSString *path = [NSString stringWithFormat:@"%@/urlcache/%@/%@/%@", cachePath, self.hostname, [key md5Hash], [[url absoluteString] md5Hash]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[path stringByDeletingLastPathComponent]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    return path;
}

- (NSMutableURLRequest *)mutableRequestForURL:(NSURL *)url options:(NSDictionary *)options {
    NSString *method = options[CKAPIHTTPMethodKey];
    NSData *body = options[CKAPIHTTPBodyDataKey];
    
    // POST parameters overwrite the body
    NSDictionary *parameters = options[CKAPIHTTPPOSTParameters];
    if (parameters) {
        NSMutableString *bodyString = [NSMutableString string];
        for (NSString *key in parameters) {
            if ([bodyString length] > 0) {
                [bodyString appendString:@"&"];
            }
            id value = parameters[key];
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *theArray = value;
                NSString *arrayKey = [NSString stringWithFormat:@"%@[]", key];
                NSMutableArray *kvPairs = [NSMutableArray array];
                for (id arrayValue in theArray) {
                    NSString *pair = [NSString stringWithFormat:@"%@=%@", [arrayKey formEncodedString], [[arrayValue description] formEncodedString]];
                    [kvPairs addObject:pair];
                }
                [bodyString appendString:[kvPairs componentsJoinedByString:@"&"]];
            }
            else {
                [bodyString appendFormat:@"%@=%@",
                 [key formEncodedString], [value formEncodedString]];
            }
        }
        
        body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *headers = options[CKAPIHTTPHeadersKey];
    
    if (self.actAsId.length > 0 && ![options[CKAPINoMasqueradeIDRequired] boolValue]) {
        NSString *separator = @"?";
        if ([url query]) {
            separator = @"&";
        }
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@as_user_id=%@", [url absoluteURL], separator, self.actAsId]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[CKCanvasURLConnection CKUserAgentString] forHTTPHeaderField:@"User-Agent"];
    
    if (self.accessToken && ![options[CKAPINoAccessTokenRequired] boolValue]) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
        
        if (url.query == nil || [url.query rangeOfString:@"mobileAuthCacheKey"].location == NSNotFound) {
            // Add a hash of the access token to the URL, so that the caching mechanism stores them separately.
            unsigned char hash[CC_SHA1_DIGEST_LENGTH];
            NSData *urlData = [self.accessToken dataUsingEncoding:NSUTF8StringEncoding];
            CC_SHA1([urlData bytes], (uint32_t)urlData.length, hash);
            BOOL hasQuery = url.query != nil;
            
            NSMutableString *hashString = [NSMutableString new];
            for (int i=0; i<4; ++i) {
                [hashString appendFormat:@"%x", hash[i]];
            }
            
            NSString *urlWithAuthNonce = [url.absoluteString stringByAppendingFormat:@"%@mobileAuthCacheKey=%@", (hasQuery ? @"&" : @"?"), hashString];
            request.URL = [NSURL URLWithString:urlWithAuthNonce];
        }
    }
    
    if (method) {
        [request setHTTPMethod:method];
    }
    if (body) {
        [request setHTTPBody:body];
    }
    if (parameters) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    return request;
}

- (CKCanvasURLConnection *)runForURL:(NSURL *)url options:(NSDictionary *)options block:(CKHTTPURLConnectionDoneCB)block {
    
    NSNumber *noAccessRequiredNumber = options[CKAPINoAccessTokenRequired];
    if (self.accessToken == nil && (noAccessRequiredNumber == nil || [noAccessRequiredNumber boolValue] == NO)) {
        [self performBlockAfterLogin:^{
            NSMutableDictionary *newOptions = [NSMutableDictionary dictionaryWithDictionary:options];
            newOptions[CKAPIShouldIgnoreCacheKey] = @YES;
            [self runForURL:url options:newOptions block:block];
        }];
        return nil;
    }
    
    NSMutableURLRequest *request = [self mutableRequestForURL:url options:options];
    
    NSString *method = options[CKAPIHTTPMethodKey];
    if (!method) {
        method = @"GET";
    }
    id progressObject = options[CKAPIProgressNotificationObjectKey];
    NSFileHandle *fileHandle = options[CKAPIOutputFileHandleKey];
    BOOL ignoreCache = [options[CKAPIShouldIgnoreCacheKey] boolValue];
    
    BOOL shouldCacheResponse = NO;
    if ([method isEqualToString:@"GET"]) {
        shouldCacheResponse = YES;
    }
    else {
        ignoreCache = YES;
    }
    
    self.refreshCacheOnNextRequest = NO;
    
    if (!ignoreCache) {
        [self ensureURLCacheHasMemoryCapacity];
        [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        if (cachedResponse) {
            NSHTTPURLResponse *cachedHttpResponse = (NSHTTPURLResponse *)[cachedResponse response];
            CKCanvasAPIResponse *response = [[CKCanvasAPIResponse alloc] initWithResponse:cachedHttpResponse
                                                                                     data:cachedResponse.data];
            NSDate *cacheDate = [cachedHttpResponse ck_date];
            if (cacheDate == nil) {
                cacheDate = [NSDate distantPast];
            }
            if (fabs([cacheDate timeIntervalSinceNow]) > LONG_CACHE_LIMIT_SECONDS) {
                NSLog(@"removing outdated cache for request: %@", [request URL]);
                [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
            }
            else {
                if (self.refreshCacheOnNextRequest || fabs([cacheDate timeIntervalSinceNow]) > SHORT_CACHE_LIMIT_SECONDS) {
                    
                    block(nil, response, NO);
                    // Fall through to also run the network call.
                }
                else {
                    block(nil, response, YES);
                    return nil;
                }
            }
        }
    }
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    CKCanvasURLConnection *connection = [[CKCanvasURLConnection alloc] initWithRequest:request
                                                                         progressObject:progressObject
                                                                             filehandle:fileHandle
                                                                            shouldCache:shouldCacheResponse
                                                                               callback:block];
    if ([options[CKAPIBlockRedirectsKey] boolValue] == YES) {
        connection.shouldFollowRedirects = NO;
    }
    
    if (!connection) {
        // TODO: better error handling
        NSLog(@"Could not create connection");
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], nil, YES);
    }
    
    return connection;
}

- (int)pageNumberForLastPageInResponse:(NSHTTPURLResponse *)response {
    NSDictionary *values = [response ck_linkHeaderValues];
    NSString *lastValue = values[@"last"];
    NSURL *urlForLastPage = [NSURL URLWithString:lastValue];
    
    NSString *query = [urlForLastPage query];
    int lastPage = [[query queryParameters][@"page"] intValue];
    return lastPage;
}

- (NSURL *)getNextPageURLFromResponse:(NSHTTPURLResponse *)response
{
    NSDictionary *values = [response ck_linkHeaderValues];
    NSString *nextValue = values[@"next"];
    if (nextValue) {
        NSString *newURLString = [NSString stringWithFormat:@"%@://%@%@", self.apiProtocol, self.hostname, nextValue];
        NSURL *newURL = [NSURL URLWithString:newURLString];
        return newURL;
    }
    return nil;
}

// This exists inside of our app's tmp directory. It returns nil if there was a problem getting the directory.
NSString *CKDownloadsInProgressDirectory(void)
{   
    // Get the NSTemporaryDirectory. This will give us the tmp dir inside of our sandbox.
    NSString *tmpDir = NSTemporaryDirectory();
    
    // Build the path to DownloadsInProgress
    NSString *downloadsDirPath = [tmpDir stringByAppendingPathComponent:@"CKDownloadsInProgress"];
    
    // Check for the existence of the DownloadsInProgress folder inside the tmp directory. If it's not there, create it.
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:downloadsDirPath]) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:downloadsDirPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success) {
            NSLog(@"Failed to create the DownloadsInProgress directory: %@",error);
            downloadsDirPath = nil;
        }
    }
    
    return downloadsDirPath;
}



- (void)runForPaginatedURL:(NSURL *)url withMapping:(CKInfoToObjectMappingBlock)mapping completion:(CKPagedArrayBlock)completion
{
    completion = [completion copy];
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            completion(error, nil, nil);
            return;
        }
        
        CKPaginationInfo *paginationInfo = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
        NSArray *results = [apiResponse JSONValue];
        
        NSMutableArray *array = [NSMutableArray new];
        [results enumerateObjectsUsingBlock:^(id info, NSUInteger idx, BOOL *stop) {
            [array addObject:mapping(info)];
        }];
        
        completion(error, array, paginationInfo);
    }];
}

@end

@implementation CKCanvasAPIResponseParser

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return nil;
    }
    
    return [[CKCanvasAPIResponse alloc] initWithResponse:(NSHTTPURLResponse *)response data:data];
}

@end
