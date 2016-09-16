//
//  DiscussionTemplateRenderer.m
//  iCanvas
//
//  Created by BJ Homer on 11/8/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <CanvasKit1/CanvasKit1.h>

#import "DiscussionTemplateRenderer.h"
#import "NSString+IN_Additions.h"

@implementation DiscussionTemplateRenderer

- (NSString *)sourceFileNamed:(NSString *)name ofType:(NSString *)type {
    NSBundle *techDebtBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *source = [NSString stringWithContentsOfFile:[techDebtBundle pathForResource:name ofType:type] encoding:NSUTF8StringEncoding error:nil];
    
    if (source == nil) {
        NSBundle *ck1Bundle = [NSBundle bundleForClass:[CKDiscussionTopic class]];
        source = [NSString stringWithContentsOfFile:[ck1Bundle pathForResource:name ofType:type] encoding:NSUTF8StringEncoding error:nil];
    }
    
    return source;
}

- (NSString *)htmlStringForThreadedEntry:(CKDiscussionEntry *)entry {
    
    NSMutableString *renderedEntry = [[self sourceFileNamed:@"ThreadedDiscussionEntry" ofType:@"html"] mutableCopy];
    
    NSString *css = [self sourceFileNamed:@"ThreadedDiscussion" ofType:@"css"];
    [renderedEntry replaceOccurrencesOfString:@"{$CSS}" withString:css options:0 range:NSMakeRange(0, renderedEntry.length)];
    
    NSString *imagesLoadedJS = [self sourceFileNamed:@"ImagesLoaded" ofType:@"js"];
    NSString *rewriteAPILinksJS = [self sourceFileNamed:@"rewrite-api-links" ofType:@"js"];
    [renderedEntry replaceOccurrencesOfString:@"{$javascript}" withString:[imagesLoadedJS stringByAppendingString:rewriteAPILinksJS] options:0 range:NSMakeRange(0, renderedEntry.length)];
    
    NSString *userName = entry.userName;
    if (userName == nil) {
        // We don't ancipate this happening, but just to be safe...
        userName = [NSString stringWithFormat:@"User %qu", entry.userIdent];
    }
    NSString *message = entry.entryMessage;
    if (message == nil) {
        message = @"";
    }
    
    NSString *title = [NSString stringWithFormat:@"(%@) - %@", userName, [message substringToIndex:MIN(message.length, 50)]];
    [renderedEntry in_replaceOccurrencesOfString:@"{$TITLE$}" withString:title];
    
    
    [renderedEntry in_replaceOccurrencesOfString:@"{$ENTRY$}" withString:message];
    
    NSMutableString *attachmentString = [NSMutableString new];
    NSArray *attachments = [entry.attachments allValues];
    for (CKAttachment *attachment in attachments) {
        NSURL *url = attachment.directDownloadURL;
        [attachmentString appendFormat:@"<li><a href=\"%@\">%@</a></li>", url, attachment.displayName];
    }
    [renderedEntry in_replaceOccurrencesOfString:@"{$ATTACHMENTS$}" withString:attachmentString];
    
    return renderedEntry;
}

@end
