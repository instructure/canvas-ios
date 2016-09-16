//
//  INCalParser.m
//  CanvasKit
//
//  Created by Mark Suman on 10/12/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "INCalParser.h"

NSString * const INCalParsedFeedContentHeaderKey = @"content-header";
NSString * const INCalParsedFeedEventsKey = @"events";

@interface INCalParser() {
@private
    NSString *source;
    NSArray *lines;
    NSMutableDictionary *parsedFeed;
    NSUInteger skipToIndex;
}

- (void)parseSource;

// line parsers
- (void)parseBeginVcalendarAtIndex:(int)idx;
- (void)parseBeginVeventAtIndex:(int)idx;

@end

@implementation INCalParser

- (id)objectWithString:(NSString *)repr
{
    parsedFeed = nil;
    source = [repr copy];
    skipToIndex = 0;
    
    [self parseSource];
    
    return parsedFeed;
}

- (void)parseSource
{    
    lines = [source componentsSeparatedByString:@"\n"];
    
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        // The deeper parsing methods manually walk the array, so we can skip those rows
        if (idx >= skipToIndex) {   
            // Look at the beginning of the string. Call the appropriate parsing method for the line type
            if ([line hasPrefix:@"BEGIN:VCALENDAR"]) {
                // This takes care of the header fields
                [self parseBeginVcalendarAtIndex:idx];
            }
            else if ([line hasPrefix:@"BEGIN:VEVENT"]) {
                // This takes care of the properties of the event
                [self parseBeginVeventAtIndex:idx];
            }
        }
    }];
}

- (void)parseBeginVcalendarAtIndex:(int)idx
{
    parsedFeed = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    
    int tempIndex = idx + 1;
    if (tempIndex >= [lines count]) {
        NSLog(@"Already at the end of the file. Skipping content header parsing.");
        return;
    }
    NSString *lineString = lines[tempIndex];
    
    // Manually walk down each line until we hit the first event
    // Everything we see is a content header field
    while ([lineString hasPrefix:@"BEGIN:VEVENT"] == NO && [lineString hasPrefix:@"END:VCALENDAR"] == NO) {
        // Look for lines that are broken into multiple lines and combine them together
        while (tempIndex + 1 < [lines count] && [lines[tempIndex + 1] hasPrefix:@" "]) {
            tempIndex++;
            lineString = [lineString stringByAppendingString:[lines[tempIndex] substringFromIndex:1]];
        }
        
        NSMutableArray *lineComps = [[lineString componentsSeparatedByString:@":"] mutableCopy];
        if ([lineComps count] > 1) {
            NSString *k = lineComps[0];
            [lineComps removeObjectAtIndex:0];
            // Join them back together in case the value has a colon
            NSString *v = [lineComps componentsJoinedByString:@":"];
            headerDict[k] = v;
        }
        else {
            NSLog(@"Failed to parse line: %@", lineString);
        }
        
        // Set the next line before the condition is evaluated again
        tempIndex++;
        if (tempIndex >= [lines count]) {
            NSLog(@"Hit the end of the file sooner than expected. Exiting content header parsing.");
            break;
        }
        lineString = lines[tempIndex];
    }
    
    if ([headerDict count] > 0) {
        parsedFeed[INCalParsedFeedContentHeaderKey] = headerDict;
    }
    
    skipToIndex = tempIndex;
}

- (void)parseBeginVeventAtIndex:(int)idx
{
    // Create the events array if it doesn't exist yet
    if (parsedFeed[INCalParsedFeedEventsKey] == nil) {
        parsedFeed[INCalParsedFeedEventsKey] = [NSMutableArray array];
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    
    int tempIndex = idx + 1;
    if (tempIndex >= [lines count]) {
        NSLog(@"Already at the end of the file. Skipping this event parsing.");
        return;
    }
    NSString *lineString = lines[tempIndex];
    
    // Manually walk down each line until we hit the first event
    // Everything we see is a content header field
    while ([lineString hasPrefix:@"END:VEVENT"] == NO && [lineString hasPrefix:@"END:VCALENDAR"] == NO) {
        // Look for lines that are broken into multiple lines and combine them together
        while (tempIndex + 1 < [lines count] && [lines[tempIndex + 1] hasPrefix:@" "]) {
            tempIndex++;
            lineString = [lineString stringByAppendingString:[lines[tempIndex] substringFromIndex:1]];
        }
        
        NSMutableArray *lineComps = [[lineString componentsSeparatedByString:@":"] mutableCopy];
        if ([lineComps count] > 1) {
            NSString *k = lineComps[0];
            [lineComps removeObjectAtIndex:0];
            // Join them back together in case the value has a colon
            NSString *v = [lineComps componentsJoinedByString:@":"];
            v = [self removeICSEscapingFromString:v];
            event[k] = v;
        }
        else {
            NSLog(@"Failed to parse line: %@", lineString);
        }
        
        // Set the next line before the condition is evaluated again
        tempIndex++;
        if (tempIndex >= [lines count]) {
            NSLog(@"Hit the end of the file sooner than expected. Exiting parsing for this event.");
            break;
        }
        lineString = lines[tempIndex];
    }
    
    if ([event count] > 0) {
        [parsedFeed[INCalParsedFeedEventsKey] addObject:event];
    }
    
    skipToIndex = tempIndex;
}

- (NSString *)removeICSEscapingFromString:(NSString *)string {
    NSMutableString *mString = [string mutableCopy];
    [mString replaceOccurrencesOfString:@"\\," withString:@"," options:0 range:NSMakeRange(0, mString.length)];
    [mString replaceOccurrencesOfString:@"\\;" withString:@";" options:0 range:NSMakeRange(0, mString.length)];
    [mString replaceOccurrencesOfString:@"\\N" withString:@"\n" options:0 range:NSMakeRange(0, mString.length)];
    [mString replaceOccurrencesOfString:@"\\n" withString:@"\n" options:0 range:NSMakeRange(0, mString.length)];
    [mString replaceOccurrencesOfString:@"\\\\," withString:@"\\" options:0 range:NSMakeRange(0, mString.length)];
    return mString;
}


@end
