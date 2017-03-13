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

#import "SupportTicket.h"
#import <CocoaLumberjack/DDFileLogger.h>
#import "UIDevice+CKMHardware.h"
#import "CanvasKeymaster.h"

static NSString * const JustACommentValue = @"just_a_comment";
static NSString * const NotUrgentValue = @"not_urgent";
static NSString * const WorkaroundPossibleValue = @"workaround_possible";
static NSString * const BlocksWhatINeedToDoValue = @"blocks_what_i_need_to_do";
static NSString * const ExtremeCriticalEmergencyValue = @"extreme_critical_emergency";

@implementation SupportTicket

- (NSDictionary *)dictionaryValue
{
    [self validateFields];
    self.subject = [self.subject stringByAppendingString:[NSString stringWithFormat:@" [%@]", TheKeymaster.currentClient.baseURL]];
    
    NSMutableArray *tags = [NSMutableArray arrayWithArray:@[@"iOS", @"Mobile", @"iCanvas"]];
    
    if (self.ticketType == SupportTicketTypeFeatureRequest) {
        [tags addObject:@"MobileFeatureRequest"];
    }
    
    CKIClient *client = TheKeymaster.currentClient;
    NSMutableDictionary *ticketDictionary =
    [@{
      @"error":
        [@{
            @"subject": self.subject,
            @"url": [client.baseURL absoluteString] ? [client.baseURL absoluteString] : @"https://canvas.instructure.com",
            @"email": client.currentUser.email ? client.currentUser.email : @"unknown_user@test.com",
            @"comments": [self.commentBody stringByAppendingString:[self commentAdditions]],
            @"user_percieved_severity": [self impactFieldValue],
            @"http_env": [self environmentBody],
            @"backtrace": [self logFileData]
        } mutableCopy]
    } mutableCopy];

    if (_reportedError) {
        ticketDictionary[@"error"][@"category"] = _reportedError.domain;
        ticketDictionary[@"error"][@"code"] = @(_reportedError.code);
        
        // error.message is the error report that support will likely use to make the ticket
        // so in order to prevent tons of duplicate tickets, lets use the most descriptive
        // message from the server possible.
        if (_reportedError.localizedFailureReason) {
            ticketDictionary[@"error"][@"message"] = _reportedError.localizedFailureReason;
            ticketDictionary[@"error"][@"description"] = _reportedError.localizedDescription;
        } else if (_reportedError.localizedDescription) {
            ticketDictionary[@"error"][@"message"] = _reportedError.localizedDescription;
        }
        
        NSSet *specialKeys = [NSSet setWithArray:@[NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey]];
        NSMutableSet *keys = [NSMutableSet setWithArray:_reportedError.userInfo.allKeys];
        [keys minusSet:specialKeys];
        for (NSString *key in keys) {
            ticketDictionary[@"error"][[key description]] = [_reportedError.userInfo[key] description];
        }
    }
    
    return ticketDictionary;
}

- (NSDictionary *)environmentBody {
    NSMutableDictionary *environmentBody = [NSMutableDictionary new];
    
    CKIClient *client = TheKeymaster.currentClient;
    NSString *baseURLString = [client.baseURL absoluteString] ? [client.baseURL absoluteString] : @"https://canvas.instructure.com";

    if (![baseURLString hasSuffix:@"sfu.ca"]) {
        environmentBody[@"User"] = client.currentUser.id ? client.currentUser.id : @"Unknown User";
        environmentBody[@"Email"] = client.currentUser.email ? client.currentUser.email : @"unknown_user@test.com";
    }
    
    environmentBody[@"Hostname"] = baseURLString;
    environmentBody[@"App Version"] = [self appVersionString];
    environmentBody[@"Platform"] = [[UIDevice currentDevice] ckm_platformString];
    environmentBody[@"OS Version"] = [[UIDevice currentDevice] systemVersion];

    return environmentBody;
}

- (NSString *)commentAdditions {
    NSMutableString *commentAdditions = [[NSMutableString alloc] initWithString:@"\n\n\n"];
    CKIClient *client = TheKeymaster.currentClient;
    NSString *baseURLString = [client.baseURL absoluteString];
    
    // We cannot save user data from Simon Fraser University in Canada.
    // Make sure that we are not adding user data to crash reports
    [commentAdditions appendString:@"-----------------------------------"];
    if (![baseURLString hasSuffix:@"sfu.ca"]) {
        [commentAdditions appendString:[NSString stringWithFormat:@"\nUser: %@", client.currentUser.id]];
        [commentAdditions appendString:[NSString stringWithFormat:@"\nEmail: %@", client.currentUser.email]];
    }
    
    
    [commentAdditions appendString:[NSString stringWithFormat:@"\nHostname: %@", baseURLString]];
    [commentAdditions appendString:[NSString stringWithFormat:@"\nApp Version: %@", [self appVersionString]]];
    [commentAdditions appendString:[NSString stringWithFormat:@"\nPlatform: %@", [[UIDevice currentDevice] ckm_platformString]]];
    [commentAdditions appendString:[NSString stringWithFormat:@"\nOS Version: %@", [[UIDevice currentDevice] systemVersion]]];
    [commentAdditions appendString:@"\n-----------------------------------"];
    
    return commentAdditions;
    
}

- (NSString *)appVersionString
{
    return [NSString stringWithFormat:@"%@ (%@)",
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)validateFields
{
    if (! self.requesterName) {
        self.requesterName = @"Unknown";
    }
    if (!self.requesterEmail) {
        self.requesterEmail = @"Unknown";
    }
    if (!self.subject) {
        self.subject = @"N/A";
    }
    if (!self.commentBody) {
        self.commentBody = @"N/A";
    }
}

- (NSString *)impactString
{
    switch (self.impactValue) {
        case SupportTicketImpactLevelNone:
            return NSLocalizedStringFromTableInBundle(@"Choose One", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        case SupportTicketImpactLevelComment:
            return NSLocalizedStringFromTableInBundle(@"Casual question or suggestion", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        case SupportTicketImpactLevelNotUrgent:
            return NSLocalizedStringFromTableInBundle(@"I need help but it's not urgent", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        case SupportTicketImpactLevelWorkaroundPossible:
            return NSLocalizedStringFromTableInBundle(@"Something is broken but I can work around it", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        case SupportTicketImpactLevelBlocking:
            return NSLocalizedStringFromTableInBundle(@"I can't get things done until I hear back from you", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        case SupportTicketImpactLevelEmergency:
            return NSLocalizedStringFromTableInBundle(@"Extremely critical emergency", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
            break;
        default:
            break;
    }
}

- (NSString *)impactFieldValue
{
    switch (self.impactValue) {
        case SupportTicketImpactLevelNone:
            return @"";
            break;
        case SupportTicketImpactLevelComment:
            return @"just_a_comment";
            break;
        case SupportTicketImpactLevelNotUrgent:
            return @"not_urgent";
            break;
        case SupportTicketImpactLevelWorkaroundPossible:
            return @"workaround_possible";
            break;
        case SupportTicketImpactLevelBlocking:
            return @"blocks_what_i_need_to_do";
            break;
        case SupportTicketImpactLevelEmergency:
            return @"extreme_critical_emergency";
            break;
        default:
            break;
    }
}

#pragma mark - Logs Collection

- (NSString *)logFileData {
    NSString *filePath = TheKeymaster.logFilePath;
    NSMutableString *fileData = [[NSMutableString alloc] init];
    if (filePath) {
        NSString *logData = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding];
        NSArray *stringsByLine = [logData componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet newlineCharacterSet]];
        
        [fileData appendString:[NSString stringWithFormat:@"\nLog\n\n:"]];
        NSInteger totalLinesToAdd = 150;
        if (stringsByLine.count < totalLinesToAdd) {
            [fileData appendString:[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding]];
        } else {
            for (NSInteger i = stringsByLine.count - totalLinesToAdd; i < stringsByLine.count; i++) {
                [fileData appendString:stringsByLine[i]];
                [fileData appendString:@"\n"];
            }
        }
    }
    
    return fileData;
}


@end
