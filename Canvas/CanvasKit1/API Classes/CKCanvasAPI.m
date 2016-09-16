//
//  CKCanvasAPI.m
//  CanvasKit
//
//  Created by Zach Wily on 4/23/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"
#import "CKCanvasAPIResponse.h"
#import "CKCanvasURLConnection.h"
#import "CKDiscussionTopic.h"
#import "NSData+CKAdditions.h"
#import "NSString+CKAdditions.h"
#import "TouchXML.h"
#import "NSDictionary+CKAdditions.h"
#import "CKUser.h"
#import "CKUserAvatar.h"
#import <UIKit/UIKit.h>
#import "CKOAuthController.h"
#import "CKStreamItem.h"
#import "CKConversation.h"
#import "CKTodoItem.h"
#import "CKConversationMessage.h"
#import "CKConversationRecipient.h"
#import "CKDiscussionEntry.h"
#import "INCal.h"
#import "CKCalendarItem.h"
#import "NSHTTPURLResponse+CKAdditions.h"
#import "SDURLCache.h"
#import "CKEmbeddedMediaAttachment.h"
#import "CKSubmission.h"
#import "CKEnrollment.h"
#import "CKCollection.h"
#import "CKCollectionItem.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSFileManager+CKAdditions.h"
#import "NSArray+CKAdditions.h"
#import "CKAPICredentials.h"
#import "CKFolder.h"
#import "CKMediaComment.h"
#import "CKPaginationInfo.h"
#import "CKPage.h"
#import "CKGroup.h"
#import "CKGroupMembership.h"
#import "CKContextInfo.h"
#import "CKTab.h"
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
    BOOL usingMockCache;
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

- (CKOAuthController *)controllerForOAuthLoginWithCompletionBlock:(void (^)(NSString *accessToken, NSError *error))block {
    
    UIStoryboard *storyboard = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"CKOAuthLoginHD" bundle:[NSBundle bundleForClass:[self class]]];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"CKOAuthLogin" bundle:[NSBundle bundleForClass:[self class]]];
    }
    
    CKOAuthController *oauthController = (CKOAuthController *)[storyboard instantiateInitialViewController];
    oauthController.canvasAPI = self;
    
    block = [block copy];
    oauthController.finishedBlock = ^(NSError *error, NSString *newAccessToken, CKUser *newUser) {
        self.accessToken = newAccessToken;
        self.user = newUser;
        if (block) {
            block(self.accessToken, error);
        }
        if (accessToken) {
            while (afterLoginBlocks.count > 0) {
                dispatch_block_t postLoginBlock = afterLoginBlocks[0];
                postLoginBlock();
                [afterLoginBlocks removeObjectAtIndex:0];
            }
        }
    };
    
    return oauthController;
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

- (void)getUserProfileForId:(uint64_t)ident block:(CKUserBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/%llu/profile", self.apiProtocol, self.hostname, ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  CKUser *fetchedUser = [[CKUser alloc] initWithInfo:[apiResponse JSONValue]];
                  block(nil, isFinalValue, fetchedUser);
              }];    
}

- (void)updateUserName:(NSString *)newName block:(CKSimpleBlock)block
{
    // Make sure the name has actually changed
    if ([self.user.name isEqualToString:newName]) {
        block(nil, YES);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES);
        return;
    }
    
    NSDictionary *parameters = @{@"user[name]": newName};
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"PUT",
                     CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue);
                      return;
                  }
                  
                  NSDictionary *responseDict = [apiResponse JSONValue];
                  
                  self.user.name = responseDict[@"name"];
                  
                  block(nil, isFinalValue);
              }];
}

- (void)getUserAvatarsForLoggedInUserWithBlock:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/avatars", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *response = [apiResponse JSONValue];
                  
                  NSMutableArray *avatars = [NSMutableArray new];
                  for (NSDictionary *avatarInfo in response) {
                      [avatars addObject:[[CKUserAvatar alloc] initWithInfo:avatarInfo]];
                  }
                  
                  block(nil, isFinalValue, avatars);
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

- (void)getTodoItemsWithBlock:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/todo.json", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *newTodoItems = [apiResponse JSONValue];
                  NSMutableArray *todoItems = [NSMutableArray array];
                  
                  for (NSDictionary *todoItemInfo in newTodoItems) {
                      CKTodoItem *todoItem = [[CKTodoItem alloc] initWithInfo:todoItemInfo api:self];
                      [todoItems addObject:todoItem];
                  }
                  block(nil, isFinalValue, todoItems);
              }];
}


- (void)ignoreTodoItem:(CKTodoItem *)todoItem permanently:(BOOL)permanently withBlock:(CKSimpleBlock)block {
    NSURL *url;
    if (permanently) {
        url = todoItem.ignorePermanentlyURL;
    }
    else {
        url = todoItem.ignoreURL;
    }
    
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
#pragma mark - Activity stream
////////////////////////////////////////////

- (void)getActivityStreamItemsWithPageURL:(NSURL *)url block:(CKPagedArrayBlock)block
{
    CKContextInfo *context = [[CKContextInfo alloc] initWithContextType:CKContextTypeUser ident:self.user.ident];
    [self getActivityStreamItemsForContext:context pageURL:url block:block];
}

- (void)getActivityStreamItemsForContext:(CKContextInfo *)context pageURL:(NSURL *)url block:(CKPagedArrayBlock)block {
    
    if (url == nil) {
        NSString *contextIdent = [NSString stringWithFormat:@"%llu", context.ident];
        if (context.contextType == CKContextTypeUser) {
            // This is the only valid value when the context type is user. Even the user ID doesn't work.
            contextIdent = @"self";
        }
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%@/activity_stream.json",
                               self.apiProtocol, self.hostname, [context typeComponentForURLs], contextIdent];
        url = [NSURL URLWithString:urlString];
    }
    
    
    NSDictionary *options = @{ CKAPIShouldIgnoreCacheKey : @YES};
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  
                  CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
                  
                  if (error != nil) {
                      block(error, nil, pagination);
                      return;
                  }
                  
                  NSArray *newStreamItems = [apiResponse JSONValue];
                  NSMutableArray *streamItems = [NSMutableArray array];
                  
                  for (NSDictionary *streamItemInfo in newStreamItems) {
                      CKStreamItem *streamItem = [[CKStreamItem alloc] initWithInfo:streamItemInfo];
                      [streamItems addObject:streamItem];
                  }
                  block(nil, streamItems, pagination);
              }];
}

////////////////////////////////////////////
#pragma mark - Courses
////////////////////////////////////////////

- (void)getCoursesWithOptions:(NSDictionary *)options block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses?include[]=term", self.apiProtocol, self.hostname];
    BOOL forGradingRole = [options[CKAPICoursesForGradingRoleKey] boolValue];
    if (forGradingRole) {
        urlString = [urlString stringByAppendingString:@"&enrollment_type=teacher&include[]=needs_grading_count"];
    }
    if ([options[CKAPIIncludeTotalScoresKey] boolValue]) {
        urlString = [urlString stringByAppendingString:@"&include[]=total_scores"];
    }
    if (options[CKAPILimitEnrollmentTypesKey]) {
        CKEnrollmentType type = [options[CKAPILimitEnrollmentTypesKey] unsignedIntegerValue];
        urlString = [urlString stringByAppendingFormat:@"&enrollment_type=%@", [CKEnrollment simpleEnrollmentStringForType:type]];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalTeacherValue) {
                  if (error != nil) {
                      block(error, isFinalTeacherValue, nil);
                      return;
                  }
                  
                  NSArray *newCourses = [apiResponse JSONValue];
                  
                  NSMutableArray *courses = [NSMutableArray array];
                  NSDate *now = [NSDate date];
                  for (NSDictionary *courseInfo in newCourses) {
                      CKCourse *course = [[CKCourse alloc] initWithInfo:courseInfo];
                      if ([options[CKAPICurrentCoursesOnlyKey] boolValue]) {
                          NSDate *startDate = course.startDate ?: course.term.startDate;
                          NSDate *endDate = course.endDate ?: course.term.endDate;
                          BOOL shouldAdd = YES;
                          if (startDate && [now compare:startDate] == NSOrderedAscending) {
                              // course hasn't started yet
                              shouldAdd = NO;
                          }
                          if (endDate && [endDate compare:now] == NSOrderedAscending) {
                              // course has already ended
                              shouldAdd = NO;
                          }
                          if (shouldAdd) {
                              [courses addObject:course];
                          }
                      }
                      else {
                          [courses addObject:course];
                      }
                  }
                  
                  if (forGradingRole) {
                      // Run the request again for 'ta' enrollments, and combine the results.
                      NSString *newURLString = [urlString stringByReplacingOccurrencesOfString:@"enrollment_type=teacher"
                                                                                    withString:@"enrollment_type=ta"];
                      NSURL *newURL = [NSURL URLWithString:newURLString];
                      [self runForURL:newURL options:nil
                                block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalTAValue) {
                                    NSArray *newCourses = [apiResponse JSONValue];
                                    
                                    for (NSDictionary *courseInfo in newCourses) {
                                        CKCourse *course = [[CKCourse alloc] initWithInfo:courseInfo];
                                        if ([courses containsObject:course] == NO) {
                                            [courses addObject:course];
                                        }
                                    }
                                    block(nil, isFinalTeacherValue && isFinalTAValue, courses);
                                }];
                      
                  }
                  else {
                      block(nil, isFinalTeacherValue, courses);
                  }

              }];
}

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

- (void)getStudentsForCourse:(CKCourse *)course block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/students.json", self.apiProtocol, self.hostname, course.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSArray *result = [apiResponse JSONValue];
        
        for (NSDictionary *studentInfo in result) {
            uint64_t studentIdent = [studentInfo[@"id"] unsignedLongLongValue];
            BOOL foundExisting = NO;
            for (CKStudent *existingStudent in course.students) {
                if (existingStudent.ident == studentIdent) {
                    [existingStudent updateWithInfo:studentInfo];
                    foundExisting = YES;
                    break;
                }
            }
            if (!foundExisting) {
                CKStudent *student = [[CKStudent alloc] initWithInfo:studentInfo];
                [course.students addObject:student];
            }
        }
        block(nil, isFinalValue, course.students);
    }];
}

- (void)getUsersAndEnrollmentsForCourse:(CKCourse *)course byEnrollmentType:(CKEnrollmentType)type pageURL:(NSURL *)pageURLOrNil block:(CKPagedUsersAndEnrollmentsBlock)block
{
    NSString *enrollment = [CKEnrollment simpleEnrollmentStringForType:type];
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%llu/users?per_page=%d&enrollment_type=%@&include[]=enrollments&include[]=avatar_url&include[]=email",
                               self.apiProtocol, self.hostname, course.ident, self.itemsPerPage, enrollment];
        
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    
    [self runForURL:url options:options block:
     ^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
         if (error != nil) {
             block(error, nil, nil, 0);
             return;
         }
         NSArray *response = [apiResponse JSONValue];
         
         NSMutableArray *users = [NSMutableArray new];
         NSMutableArray *enrollments = [NSMutableArray new];
         for (NSDictionary *userInfo in response) {
             CKUser *aUser = [[CKUser alloc] initWithInfo:userInfo];
             [users addObject:aUser];
             
             for (NSDictionary *enrollmentInfo in userInfo[@"enrollments"]) {
                 CKEnrollment *anEnrollment = [[CKEnrollment alloc] initWithInfo:enrollmentInfo];
                 [enrollments addObject:anEnrollment];
             }
         }
         
         CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
         
         block(error, users, enrollments, pagination);
     }];
}

- (void)getGroupsWithPageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)handler {
    [self getGroupsWithPageURL:pageURL isCourseAffiliated:NO block:handler];
}

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

- (void)getGroupMembershipsInGroup:(CKGroup *)group pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)handler {
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/groups/%qu/memberships?filter_states[]=accepted&per_page=%u", self.apiProtocol, self.hostname, group.ident, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey : @YES};
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            handler(error, nil, nil);
        }
        else {
            CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
            
            NSMutableArray *memberships = [NSMutableArray new];
            for (NSDictionary *dict in [apiResponse JSONValue]) {
                CKGroupMembership *membership = [[CKGroupMembership alloc] initWithInfo:dict];
                [memberships addObject:membership];
            }
            handler(nil, memberships, pagination);
        }
    }];
    
}

- (void)getUsersInGroup:(CKGroup *)group pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)handler
{
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/groups/%qu/users?filter_states[]=accepted&include[]=avatar_url&per_page=%u", self.apiProtocol, self.hostname, group.ident, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey : @YES};
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            handler(error, nil, nil);
        }
        else {
            CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
            
            NSMutableArray *users = [NSMutableArray new];
            for (NSDictionary *dict in [apiResponse JSONValue]) {
                CKUser *ckUser = [[CKUser alloc] initWithInfo:dict];
                [users addObject:ckUser];
            }
            handler(nil, users, pagination);
        }
    }];
}

- (void)getUserProfilesWithIdents:(NSArray *)idents block:(CKFailuresAndObjectsDictionariesBlock)block {
    dispatch_group_t group = dispatch_group_create();

    NSMutableDictionary *errors = [NSMutableDictionary new];
    NSMutableDictionary *users = [NSMutableDictionary new];
    
    for (NSNumber *identNum in idents) {
        uint64_t ident = [identNum unsignedLongLongValue];
        dispatch_group_enter(group);
        [self getUserProfileForId:ident block:^(NSError *error, BOOL isFinalValue, CKUser *aUser) {
            if (users[identNum] != nil) {
                // We're going to always prefer cached results for this call, when possible.
                return;
            }
            if (error) {
                errors[identNum] = error;
                if (isFinalValue) {
                    dispatch_group_leave(group);
                }
            }
            else {
                users[identNum] = aUser;
                dispatch_group_leave(group);
            }
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        block(errors, users);
    });
}

- (void)getAssignmentGroupsForCourse:(CKCourse *)course block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignment_groups.json?include[]=assignments", self.apiProtocol, self.hostname, course.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }

    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }

        NSArray *result = [apiResponse JSONValue];

        NSMutableArray *groups = [@[] mutableCopy];;
        [result enumerateObjectsUsingBlock:^(NSDictionary *assignmentGroupInfo, NSUInteger idx, BOOL *stop) {
            CKAssignmentGroup *group = nil;
            group = [[CKAssignmentGroup alloc] initWithInfo:assignmentGroupInfo andCourse:course];
            [groups addObject:group];
        }];
        block(error, isFinalValue, groups);
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

- (void)getAssignmentsForCourse:(CKCourse *)course pageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURL;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments?per_page=%d", self.apiProtocol, self.hostname, course.ident, itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    
    block = [block copy];
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey : @YES};
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            NSLog(@"Error getting assignments: %@", error);
            block(error, nil, 0);
            return;
        }
        
        NSHTTPURLResponse *response = apiResponse;
        CKPaginationInfo *info = [[CKPaginationInfo alloc] initWithResponse:response];
        
        NSArray *results = [apiResponse JSONValue];
        NSMutableArray *assignments = [[NSMutableArray alloc] initWithCapacity:results.count];
        for (NSDictionary *assignmentInfo in results) {
            CKAssignment *assignment = [[CKAssignment alloc] initWithInfo:assignmentInfo];
            assignment.course = course;
            [assignments addObject:assignment];
        }
        
        block(error, assignments, info);
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

- (void)getCalendarItemsForCourse:(CKCourse *)course block:(CKArrayBlock)block
{
    NSURL *url = course.calendarFeedURL;
    if (!url) {
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *parsedDict = [apiResponse ICSValue];
        NSArray *parsedEvents = parsedDict[INCalParsedFeedEventsKey];
        
        for (NSDictionary *eventInfo in parsedEvents) {
            
            // We create the object, because the ID for the object needs to be parsed out of the info
            CKCalendarItem *calendarItem = [[CKCalendarItem alloc] initWithInfo:eventInfo];
            
            BOOL foundExistingCalendarEvent = NO;
            for (CKCalendarItem *existingCalendarEvent in course.calendarEvents) {
                if (calendarItem.typeId == existingCalendarEvent.typeId) {
                    [existingCalendarEvent updateWithInfo:eventInfo];
                    foundExistingCalendarEvent = YES;
                    break;
                }
            }
            
            if (foundExistingCalendarEvent == NO) {
                [course.calendarEvents addObject:calendarItem];
            }

        }
        block(nil, isFinalValue, course.calendarEvents);
    }];
}

- (void)getCalendarItemsForContext:(CKContextInfo *)context pageURL:(NSURL*)pageURL block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURL;
    if (!url) {
        NSString *contextType;
        switch (context.contextType) {
            case CKContextTypeCourse:
                contextType = @"course";
                break;
            case CKContextTypeGroup:
                contextType = @"group";
                break;
            case CKContextTypeUser:
                contextType = @"user";
                break;
            case CKContextTypeNone:
                contextType = @"";
                break;
        }
        NSString *contextCode = [NSString stringWithFormat:@"%@_%qu", contextType, context.ident];
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/calendar_events?type=event&context_codes[]=%@&start_date=1900-01-01&end_date=2099-12-31&per_page=%d", self.apiProtocol, self.hostname, contextCode, itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    block = [block copy];
    NSDictionary *options = @{ CKAPIShouldIgnoreCacheKey : @YES };
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            NSLog(@"Error getting calendar items for course %qu: %@", context.ident, error);
            block(error, nil, 0);
            return;
        }
        
        NSHTTPURLResponse *response = apiResponse;
        CKPaginationInfo *info = [[CKPaginationInfo alloc] initWithResponse:response];

        NSArray *results = [apiResponse JSONValue];
        
        NSMutableArray *calendarItems = [[NSMutableArray alloc] initWithCapacity:results.count];
        for (NSDictionary *eventInfo in results) {
            CKCalendarItem *calendarItem = [[CKCalendarItem alloc] initWithInfo:eventInfo];
            [calendarItems addObject:calendarItem];
        }
        
        block(error, calendarItems, info);
    }];
    
}

- (void)getCalendarItemWithId:(uint64_t)ident block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/calendar_events/%qu", self.apiProtocol, self.hostname, ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            block(error, isFinalValue, nil);
        }
        
        NSDictionary *result = [apiResponse JSONValue];
        CKCalendarItem *item = [[CKCalendarItem alloc] initWithInfo:result];
        block(nil, isFinalValue, item);
    }];
}

- (void)getEnrollmentsForCourse:(CKCourse *)course block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%llu/enrollments", self.apiProtocol, self.hostname, course.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        // TODO: better error handling
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSArray *result = [apiResponse JSONValue];
        
        NSMutableArray *enrollments = [NSMutableArray new];
        
        for (NSDictionary *enrollmentInfo in result) {
            CKEnrollment *tempEnrollment = [[CKEnrollment alloc] initWithInfo:enrollmentInfo];
            [enrollments addObject:tempEnrollment];
        }
        block(nil, isFinalValue, enrollments);
    }];

}

- (void)getTabsForContext:(CKContextInfo *)context block:(CKArrayBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%llu/tabs?include[]=external", self.apiProtocol, self.hostname, [context typeComponentForURLs], context.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            if (error.code == 401) {
                NSString *errorMessage = ([apiResponse.JSONValue valueForKeyPath:@"errors.message"] ?: NSLocalizedString(@"Not Authorized", @"error message for a 401 response."));
                error = [NSError errorWithDomain:@"com.instructure.CanvasKit" code:error.code userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            }
            block(error, isFinalValue, nil);
            return;
        }
        
        NSArray *result = [apiResponse JSONValue];
        
        NSMutableArray *tabs = [NSMutableArray new];
        
        for (NSDictionary *tabInfo in result) {
            CKTab *tab = [[CKTab alloc] initWithInfo:tabInfo];
            [tabs addObject:tab];
        }
        block(nil, isFinalValue, tabs);
    }];
}

////////////////////////////////////////////
#pragma mark - Favorites
////////////////////////////////////////////

- (void)getFavoriteCoursesWithOptions:(NSDictionary *)options block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/favorites/courses", self.apiProtocol, self.hostname];
    
    if (options[CKAPICoursesForGradingRoleKey]) {
        urlString = [urlString stringByAppendingString:@"?include[]=needs_grading_count"];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSArray *newCourses = [apiResponse JSONValue];
        
        NSMutableArray *courses = [NSMutableArray array];
        for (NSDictionary *courseInfo in newCourses) {
            CKCourse *course = [[CKCourse alloc] initWithInfo:courseInfo];
            [courses addObject:course];
        }
        
        block(nil, isFinalValue, courses);
    }];
}


- (void)getFavoriteCoursesWithBlock:(CKArrayBlock)block
{
    [self getFavoriteCoursesWithOptions:nil block:block];
}

- (void)updateFavorite:(CKCourse *)course HTTPMethod:(NSString *)method withBlock:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/favorites/courses/%lld", self.apiProtocol, self.hostname, course.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    
    [self runForURL:url
            options:@{ CKAPIHTTPMethodKey : method }
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  block(error, isFinalValue);
              }];
}

- (void)markCourseAsFavorite:(CKCourse *)course withBlock:(CKSimpleBlock)block
{
    [self updateFavorite:course HTTPMethod:@"POST" withBlock:block];
}

- (void)unmarkCourseAsFavorite:(CKCourse *)course withBlock:(CKSimpleBlock)block
{
    [self updateFavorite:course HTTPMethod:@"DELETE" withBlock:block];
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

- (void)deleteDiscussionTopic:(CKDiscussionTopic *)topic forContext:(CKContextInfo *)context block:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/discussion_topics/%qu", self.apiProtocol, self.hostname, context.typeComponentForURLs, context.ident, topic.ident];
    
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

- (void)getAnnouncementsForContext:(CKContextInfo *)contextInfo pageURL:(NSURL *)pageURL block:(CKPagedArrayBlock)block {
    [self getDiscussionTopicsForContext:contextInfo pageURL:pageURL announcementsOnly:YES block:block];
}

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

- (void)getSubmissionsForAssignment:(CKAssignment *)assignment includeHistory:(BOOL)includeHistory block:(CKArrayBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions.json?include[]=submission_history&include[]=rubric_assessment&include[]=submission_comments", self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue, nil);
            return;
        }
        
        NSArray *submissionDicts = [apiResponse JSONValue];
        NSMutableArray *submissions = [NSMutableArray arrayWithCapacity:[submissionDicts count]];
        
        for (NSDictionary *submissionInfo in submissionDicts) {
            CKSubmission *submission = [[CKSubmission alloc] initWithInfo:submissionInfo andAssignment:assignment];
            [submissions addObject:submission];
        }
        
        block(nil, isFinalValue, submissions);
    }];
}



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

- (void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment
       progressBlock:(void (^)(float))progressBlock
     completionBlock:(CKSubmissionBlock)completionBlock {

    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu/files",
                           self.apiProtocol, self.hostname, assignment.courseIdent, assignment.ident, self.user.ident];
    NSURL *endpoint = [NSURL URLWithString:urlString];
    
    
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
#pragma mark (Grading)
////////////////////////////////////////////

- (void)postGrade:(NSString *)grade forSubmission:(CKSubmission *)submission block:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json",
                           self.apiProtocol,
                           self.hostname,
                           submission.assignment.courseIdent,
                           submission.assignment.ident,
                           submission.student.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // If this is a percentage grade, we need to add a percent sign to the end so the server understands
    if (submission.assignment.scoringType == CKAssignmentScoringTypePercentage) {
        grade = [grade stringByAppendingString:@"%"];
    }
    
    NSDictionary *parameters = @{@"submission[posted_grade]": grade};
    
    block = [block copy];
    [self runForURL:url options:@{CKAPIHTTPMethodKey: @"PUT",
                                 CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            block(error, isFinalValue);
            return;
        }
        
        NSDictionary *submissionInfo = [apiResponse JSONValue];
        [submission updateGradeWithInfo:submissionInfo];
        
        // Update the last submission attempt so we don't have to go back to the server for more
        [submission.lastAttempt updateWithInfo:submissionInfo];
        
        block(nil, isFinalValue);
    }];
}


- (void)postRubricAssessment:(CKRubricAssessment *)assessment forSubmission:(CKSubmission *)submission block:(CKSimpleBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/assignments/%qu/submissions/%qu.json",
                           self.apiProtocol,
                           self.hostname,
                           submission.assignment.courseIdent,
                           submission.assignment.ident,
                           submission.student.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters addEntriesFromDictionary:[assessment parametersDictionary]];
    
    block = [block copy];
    [self runForURL:url options:@{CKAPIHTTPMethodKey: @"PUT",
                                 CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            NSLog(@"error: %@", error);
            block(error, isFinalValue);
            return;
        }
        
        NSDictionary *submissionInfo = [apiResponse JSONValue];
        [submission updateWithInfo:submissionInfo];
        
        [assessment resetOriginalRatings];
        submission.rubricAssessment = assessment;
        
        block(nil, isFinalValue);
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

////////////////////////////////////////////
#pragma mark - Conversations
////////////////////////////////////////////
#pragma mark (Viewing)
////////////////////////////////////////////

NSString * const CKAPIConversationScopeAll = nil;
NSString * const CKAPIConversationScopeUnread = @"unread";
NSString * const CKAPIConversationScopeStarred = @"starred";
NSString * const CKAPIConversationScopeArchived = @"archived";

- (void)getConversationsInScope:(NSString *)scope withPageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block {
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations?per_page=%d&interleave_submissions=1",
                               self.apiProtocol,
                               self.hostname,
                               self.itemsPerPage];
        if (scope) {
            urlString = [urlString stringByAppendingFormat:@"&scope=%@", scope];
        }
        
        url = [NSURL URLWithString:urlString];
    }
    
    block = [block copy];
    [self runForURL:url options:@{CKAPIShouldIgnoreCacheKey: @YES}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      NSLog(@"Error: %@", error);
                      block(error, nil, nil);
                  }
                  else {
                      NSHTTPURLResponse *response = (NSHTTPURLResponse *)apiResponse;
                      CKPaginationInfo *paginationInfo = [[CKPaginationInfo alloc] initWithResponse:response];
                      
                      NSArray *conversationObjects = [apiResponse JSONValue];
                      
                      NSMutableArray *conversations = [NSMutableArray array];
                      for (NSDictionary *info in conversationObjects) {
                          CKConversation *conversation = [[CKConversation alloc] initWithInfo:info];
                          [conversations addObject:conversation];
                      }
                      block(nil, conversations, paginationInfo);
                  }
              }];
}

- (void)getDetailedConversationForConversation:(CKConversation *)conversation withBlock:(CKObjectBlock)block {
    [self getDetailedConversationWithIdent:conversation.ident block:block];
}

- (void)getDetailedConversationWithIdent:(uint64_t)ident block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/%qu?interleave_submissions=1",
                           self.apiProtocol,
                           self.hostname,
                           ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url options:0//[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CKAPIShouldIgnoreCacheKey]
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      NSLog(@"Error: %@", error);
                      block(error, isFinalValue, nil);
                  }
                  else {
                      NSDictionary *response = [apiResponse JSONValue];
                      
                      CKConversation *conversation = [[CKConversation alloc] initWithInfo:response];
                      block(nil, isFinalValue, conversation);
                  }
              }];
}

////////////////////////////////////////////
#pragma mark (Starting/Replying)
////////////////////////////////////////////

- (void)postMessage:(NSString *)message 
      attachmentIds:(NSArray *)attachmentIds
            mediaId:(NSString *)mediaId 
          mediaType:(CKAttachmentMediaType)mediaType
     toConversation:(CKConversation *)conversation 
          withBlock:(CKObjectBlock)block
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/%qu/add_message",
                           self.apiProtocol,
                           self.hostname,
                           conversation.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:message
                                                           forKey:@"body"];
    
    if (attachmentIds && attachmentIds.count > 0) {
        parameters[@"attachment_ids"] = attachmentIds;
    }
    
    if (mediaId) {
        parameters[@"media_comment_id"] = mediaId;
        
        NSString *mediaTypeString = nil;
        if (mediaType == CKAttachmentMediaTypeAudio) {
            mediaTypeString = @"audio";
        }
        else {
            mediaTypeString = @"video";
        }
        
        parameters[@"media_comment_type"] = mediaTypeString;
    }
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"POST",
                     CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      NSLog(@"Error: %@", error);
                      block(error, isFinalValue, nil);
                  }
                  else {
                      CKConversation *updatedConversation = [[CKConversation alloc] initWithInfo:[apiResponse JSONValue]];
                      block(nil, isFinalValue, updatedConversation);
                  }
              }];
}

// Several cases to consider:
// Case 1: just text
// Case 2: text? + media comment
// Case 3: text? + media comments
// Case 4: text? + media comments + attachments
// Case 5: text? + attachments
- (void)postMessage:(NSString *)message withAttachments:(NSArray *)attachments toConversation:(CKConversation *)conversation withBlock:(CKObjectBlock)block {
    
    // Case 2: only one media comment and no other attachments
    if (attachments.count == 1) {
        CKEmbeddedMediaAttachment *attachment = [attachments lastObject];
        if (attachment.type == CKAttachmentMediaTypeAudio ||
            attachment.type == CKAttachmentMediaTypeVideo) {
            // Upload the media comment, and then upload the message and include the media comment
            [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                [self postMessage:message attachmentIds:nil mediaId:mediaId mediaType:mediaType toConversation:conversation withBlock:block];
            }];
            
            // My work here is finished.
            return;
        }
    }
    
    [self postConversationAttachments:attachments block:^(NSError *uploadError, BOOL isFinalValue, NSArray *attachmentUploadIds) {
        if (uploadError) {
            NSLog(@"Uploading failed due to attachment upload error:  %@", [uploadError localizedDescription]);
            
            block(uploadError, YES, nil);

            return;
        }
        
        // Check for Case 3
        BOOL uploadMessageWithFirstMediaComment = attachmentUploadIds.count > 0 ? NO : YES;
        
        // Upload the message text
        // Case 1, 5
        if (attachments.count == 0 || !uploadMessageWithFirstMediaComment) {
            [self postMessage:message attachmentIds:attachmentUploadIds mediaId:nil mediaType:CKAttachmentMediaTypeUnknown toConversation:conversation withBlock:block];
        }
        
        // Now upload all of the media comments
        // Case 3, 4
        for (CKEmbeddedMediaAttachment *attachment in attachments) {
            if (attachment.type == CKAttachmentMediaTypeAudio ||
                attachment.type == CKAttachmentMediaTypeVideo) {
                
                // Case 3
                if (uploadMessageWithFirstMediaComment) {
                    [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                        [self postMessage:message attachmentIds:nil mediaId:mediaId mediaType:mediaType toConversation:conversation withBlock:block];
                    }];
                    uploadMessageWithFirstMediaComment = NO;
                    continue;
                }
                
                [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                    [self postMessage:NSLocalizedString(@"This is a media message.", nil) attachmentIds:nil mediaId:mediaId mediaType:mediaType toConversation:conversation withBlock:block];
                }];
            }
        }
    }];
}

- (void)postConversationAttachments:(NSArray *)attachments block:(CKArrayBlock)uploadFinishedBlock
{
    NSURL *fileUploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/users/self/files",
                                                 self.apiProtocol,
                                                 self.hostname]];
    
    NSString *folderPath = @"my files/conversation attachments";
    
    [self postAttachments:attachments toURL:fileUploadUrl folder:folderPath andExecuteBlock:uploadFinishedBlock];
}

- (void)postAttachments:(NSArray *)attachments toURL:(NSURL *)fileUploadUrl folder:(NSString *)folderPath andExecuteBlock:(CKArrayBlock)uploadFinishedBlock
{
    // Keep track of at least one error if any for the uploads
    __block NSError * uploadError;
    
    dispatch_group_t attachmentUploadGroup = dispatch_group_create();
    
    NSMutableArray *attachmentUploadIds = [NSMutableArray new];
    for (CKEmbeddedMediaAttachment *attachment in attachments) {
        [attachmentUploadIds addObject:[NSNull null]];
    }
    
    [attachments enumerateObjectsUsingBlock:^(CKEmbeddedMediaAttachment *attachment, NSUInteger idx, BOOL *stop) {
        
        if (attachment.stringForEmbedding) {
            // The file was already uploaded, don't upload it again
            return; //return from this block iteration
        }
        
        if (attachment.type == CKAttachmentMediaTypeImage) {
            
            dispatch_group_enter(attachmentUploadGroup);
            NSString *defaultName = [NSString stringWithFormat:@"%@.png", NSLocalizedString(@"photo", @"Name for a photo file, i.e. photo.png")];
            [self uploadFileNamed:defaultName location:attachment.url endpoint:fileUploadUrl folderPath:folderPath block:^(NSError *error, BOOL isFinalValue, CKAttachment *uploadedAttachment) {
                
                if (uploadError) {
                    dispatch_group_leave(attachmentUploadGroup);
                    return;
                }
                
                if (error) {
                    uploadError = error;
                }
                if (uploadedAttachment) {
                    attachmentUploadIds[idx] = @(uploadedAttachment.ident);
                }
                
                dispatch_group_leave(attachmentUploadGroup);
            }];
        }
    }];
    
    // When the group of uploads is done, upload the text
    dispatch_group_notify(attachmentUploadGroup, dispatch_get_main_queue(), ^{
        
        uploadFinishedBlock(uploadError, YES, attachmentUploadIds);
        
    });

}

- (void)startNewConversationWithRecipients:(NSArray *)recipients message:(NSString *)message attachments:(NSArray *)attachments groupConversation:(BOOL)grouped block:(CKArrayBlock)block
{
    // Case 2: only one media comment and no other attachments
    if (attachments.count == 1) {
        CKEmbeddedMediaAttachment *attachment = [attachments lastObject];
        if (attachment.type == CKAttachmentMediaTypeAudio ||
            attachment.type == CKAttachmentMediaTypeVideo) {
            // Upload the media comment, and then upload the message and include the media comment
            [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                [self postNewConversationWithRecipients:recipients message:message attachmentIds:nil mediaId:mediaId mediaType:mediaType groupConversation:grouped block:block];
            }];
            
            // My work here is finished.
            return;
        }
    }
    
    [self postConversationAttachments:attachments block:^(NSError *uploadError, BOOL isFinalValue, NSArray *attachmentUploadIds) {
        if (uploadError) {
            NSLog(@"Uploading failed due to attachment upload error:  %@", [uploadError localizedDescription]);
            
            block(uploadError, YES, nil);
            
            return;
        }
        
        // Check for Case 3
        BOOL uploadMessageWithFirstMediaComment = attachmentUploadIds.count > 0 ? NO : YES;
        
        // Upload the message text
        // Case 1, 5
        if (attachments.count == 0 || !uploadMessageWithFirstMediaComment) {
            [self postNewConversationWithRecipients:recipients message:message attachmentIds:attachmentUploadIds mediaId:nil mediaType:CKAttachmentMediaTypeUnknown groupConversation:grouped block:block];
        }
        
        // Now upload all of the media comments
        // Case 3, 4
        for (CKEmbeddedMediaAttachment *attachment in attachments) {
            if (attachment.type == CKAttachmentMediaTypeAudio ||
                attachment.type == CKAttachmentMediaTypeVideo) {
                
                // Case 3
                if (uploadMessageWithFirstMediaComment) {
                    [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                        [self postNewConversationWithRecipients:recipients message:message attachmentIds:nil mediaId:mediaId mediaType:mediaType groupConversation:grouped block:block];
                    }];
                    uploadMessageWithFirstMediaComment = NO;
                    continue;
                }
                
                [self postMediaCommentAtPath:attachment.url.path ofMediaType:attachment.type block:^(NSError *error, BOOL isFinalValue, CKAttachmentMediaType mediaType, NSString *mediaId) {
                    [self postNewConversationWithRecipients:recipients message:NSLocalizedString(@"This is a media message.", nil) attachmentIds:nil mediaId:mediaId mediaType:mediaType groupConversation:grouped block:block];
                }];
            }
        }
    }];
}

- (void)postNewConversationWithRecipients:(NSArray *)recipients message:(NSString *)message attachmentIds:(NSArray *)attachmentIds mediaId:(NSString *)mediaId 
                                mediaType:(CKAttachmentMediaType)mediaType groupConversation:(BOOL)grouped block:(CKArrayBlock)block
{    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations",
                           self.apiProtocol,
                           self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSArray *recipientIDs;
    
    recipientIDs = recipients;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       message, @"body",
                                       recipientIDs, @"recipients",
                                       nil];
    if (grouped) {
        parameters[@"group_conversation"] = @"true";
    }
    
    if (attachmentIds && attachmentIds.count > 0) {
        parameters[@"attachment_ids"] = attachmentIds;
    }
    
    if (mediaId) {
        parameters[@"media_comment_id"] = mediaId;
        
        NSString *mediaTypeString = nil;
        if (mediaType == CKAttachmentMediaTypeAudio) {
            mediaTypeString = @"audio";
        }
        else {
            mediaTypeString = @"video";
        }
        
        parameters[@"media_comment_type"] = mediaTypeString;
    }
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"POST",
                     CKAPIHTTPPOSTParameters: parameters}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                  }
                  else {
                      NSArray *dicts = [apiResponse JSONValue];
                      NSMutableArray *conversations = [NSMutableArray array];
                      for (NSDictionary *dict in dicts) {
                          CKConversation *conv = [[CKConversation alloc] initWithInfo:dict];
                          [conversations addObject:conv];
                      }
                      block(nil, isFinalValue, conversations);
                  }
              }];

}

- (void)addRecipients:(NSArray *)recipients toConversation:(CKConversation *)conversation block:(CKObjectBlock)conversationDeltaBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/%qu/add_recipients", self.apiProtocol, self.hostname, conversation.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *postParams = @{@"recipients" : [recipients valueForKey:@"identString"]};
    
    NSDictionary *options = @{ CKAPIHTTPMethodKey : @"POST",
                               CKAPIHTTPPOSTParameters : postParams };
    
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            conversationDeltaBlock(error, isFinalValue, nil);
            return;
        }
        
        NSDictionary *response = [apiResponse JSONValue];
        CKConversation *conversation = [[CKConversation alloc] initWithInfo:response];
        conversationDeltaBlock(nil, isFinalValue, conversation);
    }];
    
    
}

- (void)findConversationRecipientsWithSearchString:(NSString *)search
                                             inContext:(NSString *)contextID
                                             block:(CKSearchResultsBlock)block {
    if (search == nil) {
        search = @"";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/find_recipients?per_page=-1&search=%@",
                           self.apiProtocol,
                           self.hostname,
                           [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (contextID) {
        urlString = [urlString stringByAppendingFormat:@"&context=%@&synthetic_contexts=1", contextID];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIShouldIgnoreCacheKey: @YES}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      NSLog(@"error: %@", error);
                      block(error, nil, search);
                      return;
                  }
                  
                  NSArray *response = [apiResponse JSONValue];
                  NSMutableArray *result = [NSMutableArray array];
                  for (NSDictionary *dict in response) {
                      CKConversationRecipient *recipient = [[CKConversationRecipient alloc] initWithInfo:dict];
                      [result addObject:recipient];
                  }
                  
                  block(nil, result, search);
              }];
}

////////////////////////////////////////////
#pragma mark (Workflow)
////////////////////////////////////////////

- (void)markConversation:(CKConversation *)conversation asRead:(BOOL)read withBlock:(CKSimpleBlock)block {
    NSString *stateParam = @"read";
    if (!read) {
        stateParam = @"unread";
    }
    [self _setWorkflowState:stateParam forConversation:conversation withBlock:block];
}

- (void)archiveConversation:(CKConversation *)conversation withBlock:(CKSimpleBlock)block {
    [self _setWorkflowState:@"archived" forConversation:conversation withBlock:block];
}

- (void)_setWorkflowState:(NSString *)state forConversation:(CKConversation *)conversation withBlock:(CKSimpleBlock)block {

    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/%qu",
                           self.apiProtocol,
                           self.hostname,
                           conversation.ident];
    
    NSURL *url = [NSURL URLWithString:urlString];
    

    
    NSDictionary *options = @{CKAPIHTTPMethodKey: @"PUT",
                             CKAPIHTTPPOSTParameters: @{@"conversation[workflow_state]": state}};
    
    block = [block copy];
    [self runForURL:url
            options:options
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  block(error, isFinalValue);
              }];
    
}

//////////////////////////////////////
#pragma mark - Collections
//////////////////////////////////////

- (void)getCollectionsForUser:(CKUser *)someUser block:(CKArrayBlock)block
{
    if (!someUser || someUser.ident == 0) {
        NSLog(@"Invalid user. Cannot retrieve profile.");
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/%llu/collections.json", self.apiProtocol, self.hostname, someUser.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *collectionsList = [apiResponse JSONValue];
                  
                  NSMutableArray *collections = [NSMutableArray array];
                  for (NSDictionary *collectionInfo in collectionsList) {
                      CKCollection *collection = [[CKCollection alloc] initWithInfo:collectionInfo];
#ifdef DEBUG
                      collection.rawInfo = collectionInfo;
#endif
                      [collections addObject:collection];
                  }
                  
                  block(nil, isFinalValue, collections);
              }];
}

- (void)getCollectionItemsForCollection:(CKCollection *)aCollection block:(CKArrayBlock)block
{
    if (!aCollection || aCollection.ident == 0) {
        NSLog(@"Invalid collection. Cannot retrieve collection items.");
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/collections/%llu/items", self.apiProtocol, self.hostname, aCollection.ident];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSLog(@"Could not convert %@ to URL", urlString);
        block([NSError errorWithDomain:CKCanvasErrorDomain code:0 userInfo:nil], YES, nil);
        return;
    }
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *result = [apiResponse JSONValue];
                  
                  NSMutableArray *collectionItems = [NSMutableArray array];
                  for (NSDictionary *collectionItemInfo in result) {
                      CKCollectionItem *collectionItem = [[CKCollectionItem alloc] initWithInfo:collectionItemInfo];
#ifdef DEBUG
                      collectionItem.rawInfo = collectionItemInfo;
#endif
                      [collectionItems addObject:collectionItem];
                  }
                  
                  block(nil, isFinalValue, collectionItems);
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
#pragma mark - Pages
//////////////////////////////////////
- (void)listPagesInContext:(CKContextInfo *)context pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block {
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/pages?per_page=%d", self.apiProtocol, self.hostname, context.typeComponentForURLs, context.ident, itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    NSDictionary *options = @{CKAPIShouldIgnoreCacheKey: @YES};
    [self runForURL:url options:options block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            block(error, nil, nil);
            return;
        }
        
        CKPaginationInfo *pagination = [[CKPaginationInfo alloc] initWithResponse:apiResponse];
        
        NSArray *responseJSON = [apiResponse JSONValue];
        NSMutableArray *pages = [NSMutableArray new];
        for (NSDictionary *json in responseJSON) {
            CKPage *page = [[CKPage alloc] initWithInfo:json];
            [pages addObject:page];
        }
        block(nil, pages, pagination);
    }];
}

- (void)getFrontPageForContext:(CKContextInfo *)context block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/front_page", self.apiProtocol, self.hostname, context.typeComponentForURLs, context.ident];
    [self getPageURL:urlString onCompletion:block];
}

- (void)getPageInContext:(CKContextInfo *)context withIdentifier:(NSString *)identifier block:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/%@/%qu/pages/%@", self.apiProtocol, self.hostname, context.typeComponentForURLs, context.ident, [identifier realURLEncodedString]];
    [self getPageURL:urlString onCompletion:block];
}

- (void) getPageURL:(NSString *)urlString onCompletion:(CKObjectBlock)block
{
    NSURL *url = [NSURL URLWithString:urlString];
    [self runForURL:url options:nil block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error) {
            block(error, NO, nil);
            return;
        }
        CKPage *page = [[CKPage alloc] initWithInfo:[apiResponse JSONValue]];
        
        block(error, isFinalValue, page);
    }];
}

//////////////////////////////////////
#pragma mark - Mock Response/Cache
//////////////////////////////////////

+ (NSString *)mockCacheDirectory {
    NSString *dir = [[NSUserDefaults standardUserDefaults] valueForKey:@"CKMockResponseData"];
    if (!dir) {
        dir = [[[NSProcessInfo processInfo] environment] objectForKey:@"CKMockResponseData"];
    }
    return dir;
}

- (NSString *)mockCacheDirectory {
    return [[self class] mockCacheDirectory];
}

- (BOOL)useMockCache {
    return usingMockCache;
}

- (void)setUseMockCache:(BOOL)shouldUse {
    if (shouldUse) {        
        NSString *mockCacheDirectory = [self mockCacheDirectory];
        if (mockCacheDirectory) {
            usingMockCache = YES;
        }
    }
    else {
        usingMockCache = NO;
    }
}

+ (void)clearMockedResponsesBeforeTimestampString:(const char *)dateCString {
    static NSDateFormatter *timestampDateFormatter = nil;
    if (!timestampDateFormatter) {
        timestampDateFormatter = [[NSDateFormatter alloc] init];
        timestampDateFormatter.dateFormat = @"EEE MMM d HH:mm:ss y";
    }
    
    NSString *dateString = @(dateCString);
    NSDate *date = [timestampDateFormatter dateFromString:dateString];
    [self clearMockedResponsesBeforeDate:date];
}

+ (void)clearMockedResponsesBeforeDate:(NSDate *)date {
    NSString *mockCacheDirectory = [self mockCacheDirectory];
    mockCacheDirectory = [mockCacheDirectory stringByStandardizingPath];
    if (mockCacheDirectory == nil) {
        return;
    }
    
    NSURL *directoryURL = [NSURL fileURLWithPath:mockCacheDirectory];
    NSArray *requestedKeys = @[NSURLContentModificationDateKey];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:requestedKeys
                                         options:0 errorHandler:NULL];
    BOOL hasOldResponses = NO;
    for (NSURL *url in enumerator) {
        __autoreleasing NSDate *responseDate = nil;
        [url getResourceValue:&responseDate forKey:NSURLContentModificationDateKey error:NULL];
        if ([responseDate timeIntervalSinceDate:date] < 0) {
            // It's older than the passed-in date. Just nuke everything.
            hasOldResponses = YES;
        }
    }
    
    if (hasOldResponses) {
        NSLog(@"Deleting out-of-date cache");
        [[NSFileManager defaultManager] removeItemAtURL:directoryURL error:NULL];
    }
}


- (void)setupSharedURLCache {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString * cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSUInteger memoryCapacity = 2 * 1024 * 1024; // 2 MB
    NSUInteger diskCapacity = 80 * 1024 * 1024; // 80 MB

    // Check for a mock cache directory on the command line.
    NSString *cacheDirectory = [cachesDirectory stringByAppendingPathComponent:@"CKCachedResponses"];
    NSString *mockCacheDirectory = [self mockCacheDirectory];
    if (mockCacheDirectory) {
        usingMockCache = YES;
        
        cacheDirectory = [mockCacheDirectory stringByStandardizingPath];
    }
        

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        
        NSURLCache *cache = nil;
        if (!usingMockCache) {
            cache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:@"Cache.db"];
        }
        else {
            NSError *error;
            if (![fileManager createDirectoryAtPath:cacheDirectory
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:&error]) {
                NSLog(@"Error creating CKCachedResponses directory: %@", error);
            }
            else {
                SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:memoryCapacity
                                                                       diskCapacity:diskCapacity
                                                                           diskPath:cacheDirectory];
                urlCache.minCacheInterval = 0;
                cache = urlCache;
                NSLog(@"****** Using mock response directory: %@ ******", cacheDirectory);
            }
            
        }
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
    // POST http://www.kaltura.com/api_v3/index.php?service=uploadtoken&action=upload
    // (multipart body:)
    // ks=blah
    // uploadTokenId=from above # Content-Disposition: form-data; name="uploadTokenId" 
    // fileData=<file data>  # Content-Disposition: form-data; name="fileData"; filename="2010-07-19 13:20:06 -0600.mov"
    // response: <?xml version="1.0" encoding="utf-8"?><xml><result><objectType>KalturaUploadToken</objectType><id>0_5e929ce09b1155753a3921e78d65e992</id><partnerId>156652</partnerId><userId>231890_10</userId><status>2</status><fileName>2010-07-19 13:20:06 -0600.mov</fileName><fileSize></fileSize><uploadedFileSize>213603</uploadedFileSize><createdAt>1279570943</createdAt><updatedAt>1279571114</updatedAt></result><executionTime>0.051121950149536</executionTime></xml>
    NSURL *url = [self.mediaServer apiURLUpload];
    
    NSString *boundary = @"---------------------------3klfenalksjflkjoi9auf89eshajsnl3kjnwal";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ks\"\r\n\r\n%@", sessionId] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadTokenId\"\r\n\r\n%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    if (mediaType == CKAttachmentMediaTypeAudio) {
        [body appendData:[@"Content-Disposition: form-data; name=\"fileData\"; filename=\"audiocomment.wav\"\r\nContent-Type: audio/x-aiff\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [body appendData:[@"Content-Disposition: form-data; name=\"fileData\"; filename=\"videocomment.mp4\"\r\nContent-Type: video/mp4\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[NSData dataWithContentsOfFile:path]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    block = [block copy];
    [self runForURL:url
            options:@{CKAPIHTTPMethodKey: @"POST",
                     CKAPIHTTPBodyDataKey: body,
                     CKAPIShouldIgnoreCacheKey: @YES,
                     CKAPIHTTPHeadersKey: @{@"Content-Type": contentType},
                     CKAPIProgressNotificationObjectKey: path}
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        if (error != nil) {
            NSLog(@"Error uploading media comment: %@", error);
            block(error, isFinalValue);
            return;
        }
        
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
                    NSString *pair = [NSString stringWithFormat:@"%@=%@", [arrayKey realURLEncodedString], [[arrayValue description] realURLEncodedString]];
                    [kvPairs addObject:pair];
                }
                [bodyString appendString:[kvPairs componentsJoinedByString:@"&"]];
            }
            else {
                [bodyString appendFormat:@"%@=%@",
                 [key realURLEncodedString], [value realURLEncodedString]];
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
            CC_SHA1([urlData bytes], urlData.length, hash);
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
    
    if (usingMockCache) {
        ignoreCache = NO;
        shouldCacheResponse = YES;
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
            if (usingMockCache) {
                block(nil, response, YES);
                return nil;
            }
            
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
