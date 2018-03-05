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
    
    

#import "CKSubmissionAttempt.h"
#import "CKCanvasAPI.h"
#import "CKSubmission.h"
#import "CKAttachment.h"
#import "CKAssignment.h"
#import "ISO8601DateFormatter.h"
#import "CKDiscussionEntry.h"
#import "NSDictionary+CKAdditions.h"
#import "NSString+CKAdditions.h"
#import "CKDiscussionTopic.h"
#import "CKMediaComment.h"
#import "CKFakeAttachment.h"

NSString *CKDiscussionAttemptFilename = @"SGDiscussionAttemptFilename-v3";

@implementation CKSubmissionAttempt

@synthesize internalIdent, submission, submittedAt, unsupportedFormat, attempt, score, grade, attachments, discussionEntries, type;
@synthesize previewURL, liveURL, gradeMatchesCurrentSubmission;

- (id)initWithInfo:(NSDictionary *)info andSubmission:(CKSubmission *)aSubmission
{
    self = [super init];
    if (self) {
        self.submission = aSubmission;
        attachments = [[NSMutableArray alloc] init];
        discussionEntries = [[NSMutableArray alloc] init];
        
        [self updateWithInfo:info];
    }
    return self;
}

+ (NSString *)internalIdentForInfo:(NSDictionary *)info andSubmission:(CKSubmission *)submission
{
    int attempt = -1;
    NSNumber *attemptNum = info[@"attempt"];
    if (attemptNum && (id)attemptNum != [NSNull null]) {
        attempt = [attemptNum intValue];
    }
    return [NSString stringWithFormat:@"%qu/%i", submission.ident, attempt];
}

- (void)updateWithInfo:(NSDictionary *)info
{
    self.attempt = [info[@"attempt"] intValue];
    self.assignmentIdent = [[info objectForKeyCheckingNull:@"assignment_id"] unsignedLongLongValue];
    self.submitterIdent = [[info objectForKeyCheckingNull:@"user_id"] unsignedLongLongValue];
    self.internalIdent = [CKSubmissionAttempt internalIdentForInfo:info andSubmission:self.submission];
    
    [self updateGradeInfoWithInfo:info];
    
    self.type = CKSubmissionUnknownType;
    NSString *typeString = [info objectForKeyCheckingNull:@"submission_type"];
    self.type = submissionTypeForString(typeString);
    
    // set the liveURL. Will remain nil if it doesn't have one.
    // This is a problem if website submissions can have multiple attachments that need different urls.
    NSString *urlString = [info objectForKeyCheckingNull:@"url"];
    if (urlString && self.type == CKSubmissionTypeOnlineURL) {
        self.liveURL = [NSURL URLWithString:urlString];
    }
    
    urlString = [info objectForKeyCheckingNull:@"preview_url"];
    if (urlString && self.type == CKSubmissionTypeOnlineURL) {
        self.previewURL = [NSURL URLWithString:urlString];
    }
    
    NSString *submittedString = info[@"submitted_at"];
    if (submittedString && (id)submittedString != [NSNull null]) {
        ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
        self.submittedAt = [dateFormatter dateFromString:submittedString];
    }
    
    // Now build the attachments
    [attachments removeAllObjects];

    NSString *body = [info objectForKeyCheckingNull:@"body"];
    NSString *mediaId = nil;

    if (self.type == CKSubmissionTypeOnlineTextEntry && body != nil) {
        // Special case the instance where the body is a simple media comment - we want that to show up as a media submission
        if ([body countOccurrencesOfString:@"instructure_inline_media_comment"] == 1 && 
                [body countOccurrencesOfString:@"this is a media comment"] == 1 &&
                [body length] < 180) {
            NSScanner *scanner = [NSScanner scannerWithString:body];
            [scanner scanUpToString:@"id=\"media_comment_" intoString:nil];
            if ([scanner scanString:@"id=\"media_comment_" intoString:nil]) {
                [scanner scanUpToString:@"\"" intoString:&mediaId];
            }
        }
        else {

            NSString *filename = NSLocalizedString(@"Text Submission", @"Generic name for a submission entered online.");
            CKAttachment *attachment = [[CKFakeAttachment alloc] initWithDisplayName:filename atIndex:(int)[attachments count] andSubmissionAttempt:self];
            [attachments addObject:attachment];
            
            NSURL *cacheURL = [attachment cacheURL];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheURL path]]) {
                // TODO: catch errors creating files here
                NSString *fullBody = [NSString stringWithFormat:@"<html><head><meta charset='utf-8' /></head><body style='margin: 40px; border: 1px solid gray; padding: 50px; font-size: 2em;'>%@</body></html>", body];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:[[cacheURL path] stringByDeletingLastPathComponent] 
                                          withIntermediateDirectories:YES 
                                                           attributes:nil 
                                                                error:nil];
                [[NSFileManager defaultManager] createFileAtPath:[cacheURL path]
                                                        contents:[fullBody dataUsingEncoding:NSUTF8StringEncoding] 
                                                      attributes:nil];
            }
        }
    }
    
    NSMutableDictionary *mediaCommentInfo = nil;
    if (mediaId) {
        mediaCommentInfo = [NSMutableDictionary dictionary];
        mediaCommentInfo[@"media_id"] = mediaId;
        mediaCommentInfo[@"content-type"] = CKAttachmentMediaTypeUnknownString;
    }
    else {
        mediaCommentInfo = [info objectForKeyCheckingNull:@"media_comment"];
    }

    if (mediaCommentInfo && self.type == CKSubmissionTypeMediaRecording) {
        CKMediaComment *mediaComment = [[CKMediaComment alloc] initWithInfo:mediaCommentInfo];
        
        [attachments addObject:mediaComment];
    }
    
    NSArray *attachmentsInfo = info[@"attachments"];
    if (attachmentsInfo) {
        for (NSDictionary *attachmentInfo in attachmentsInfo) {
            CKAttachment *attachment = [[CKAttachment alloc] initWithInfo:attachmentInfo];
            [attachments addObject:attachment];
        }
    }
    
    if (self.type == CKSubmissionTypeDiscussionTopic) {
        CKAttachment *attachment = [[CKFakeAttachment alloc] initWithDisplayName:[NSString stringWithFormat:@"%@-%i",CKDiscussionAttemptFilename,self.attempt]
                                                                         atIndex:(int)[attachments count]
                                                            andSubmissionAttempt:self];
        [attachments addObject:attachment];
        
        // Clear the discussion entries array then populate it with updated information
        NSMutableArray *newDiscussionEntries = [NSMutableArray array];
        
        NSURL *cacheURL = [attachment cacheURL];
        BOOL shouldCacheEntries = YES;
        NSDictionary *cachedFileAttributes = nil;
        // Check if the cached page already exists. if not, create it.
        if ([[NSFileManager defaultManager] fileExistsAtPath:[cacheURL path]]) {
            shouldCacheEntries = NO;
            cachedFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheURL path] error:nil];
        }
        
        for (NSDictionary *discussionEntryInfo in info[@"discussion_entries"]) {
            CKDiscussionEntry *entry = [[CKDiscussionEntry alloc] initWithInfo:discussionEntryInfo andDiscussionTopic:self.submission.assignment.discussionTopic entryRatings:nil];
            [newDiscussionEntries addObject:entry];
            
            if (cachedFileAttributes && [entry.updatedAt compare:[cachedFileAttributes fileModificationDate]] == NSOrderedDescending) {
                // If cached page exists, check the if the creation date of the cached file is older than any of the updatedAt dates of the entries.
                // If so, invalidate the cache
                shouldCacheEntries = YES;
            }
        }
        
        discussionEntries = newDiscussionEntries;
        
        if (shouldCacheEntries) {
            NSString *relativePathToResourcesDir = [attachment relativePathToResourcesDir];
            NSString *htmlReplacedString =[NSString stringWithFormat:@""
            @"<!DOCTYPE html>"
            @"<html lang=\"en\">"
            @"<head>"
            @"<meta charset=\"utf-8\" />"
            @"<title>Discussion Topic</title>"
            @"<!-- BASE_URL gets swapped out later on in code -->"
            @"<link rel=\"stylesheet\" href=\"%@/discussion_submissions.css\" type=\"text/css\" />"
            @"<script type=\"text/javascript\" src=\"%@/jquery-1.4.2.min.js\"></script>"
            @"<script type=\"text/javascript\" src=\"%@/jquery.json-2.2.min.js\"></script>"
            @"<script type=\"text/javascript\" src=\"%@/discussion_submissions.js\"></script>"
            @"</head>"
            @"<body>"
            @"<div id=\"entries\">"
            @"</div>"
            @"</body>"
            @"</html>", relativePathToResourcesDir, relativePathToResourcesDir, relativePathToResourcesDir, relativePathToResourcesDir];
            
            NSMutableString *htmlStringWithJavascript = [NSMutableString stringWithString:htmlReplacedString];
            
            [htmlStringWithJavascript appendString:@"<script type=\"text/javascript\">"];
            for (CKDiscussionEntry *entry in self.discussionEntries) {
                [htmlStringWithJavascript appendString:[NSString stringWithFormat:@"addEntry(%@);", [entry JSONString]]];
            }
            [htmlStringWithJavascript appendString:@"</script>"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:[[cacheURL path] stringByDeletingLastPathComponent] 
                                      withIntermediateDirectories:YES 
                                                       attributes:nil 
                                                            error:nil];
            [[NSFileManager defaultManager] createFileAtPath:[cacheURL path]
                                                    contents:[htmlStringWithJavascript dataUsingEncoding:NSUTF8StringEncoding] 
                                                  attributes:nil];
        }
    }
}

- (void)updateGradeInfoWithInfo:(NSDictionary *)info
{
    self.gradeMatchesCurrentSubmission = [info[@"grade_matches_current_submission"] boolValue];
    
    self.grade = [info objectForKeyCheckingNull:@"grade"];
    // Make sure grade is a string
    if (self.grade && ![self.grade isKindOfClass:[NSString class]]) {
        self.grade = [NSString stringWithFormat:@"%@", self.grade];
    }
    if (self.grade && self.submission.assignment.scoringType == CKAssignmentScoringTypePercentage) {
        self.grade = [self.grade stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"%"]];
    }
    
    NSNumber *theScore = [info objectForKeyCheckingNull:@"score"];
    if (theScore) {
        self.score = [theScore floatValue];
    }
    else {
        self.score = -1;
    }
}

- (NSComparisonResult)compare:(CKSubmissionAttempt *)other
{
    return [self.submittedAt compare:other.submittedAt];
}

- (NSUInteger)hash {
    return [internalIdent hash];
}


@end
