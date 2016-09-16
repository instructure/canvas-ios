//
//  CKCalendarItem.m
//  CanvasKit
//
//  Created by Mark Suman on 10/13/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKCalendarItem.h"
#import "CKAssignment.h"
#import "CKCourse.h"
#import "ISO8601DateFormatter.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKCalendarItem


- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
    }
    
    return self;
}

- (void)updateWithInfo:(NSDictionary *)json
{
    NSNumber *typeIdNumber = [json objectForKeyCheckingNull:@"id"];
    _typeId = [typeIdNumber unsignedLongLongValue];
    
    _title = [json objectForKeyCheckingNull:@"title"];
    _itemDescription = [json objectForKeyCheckingNull:@"description"];
    
    _allDay = [[json objectForKeyCheckingNull:@"all_day"] boolValue];
    ISO8601DateFormatter *formatter = [ISO8601DateFormatter new];
    _startDate = [formatter dateFromString:[json objectForKeyCheckingNull:@"start_at"]];
    _endDate = [formatter dateFromString:[json objectForKeyCheckingNull:@"end_at"]];
    _updatedAt = [formatter dateFromString:[json objectForKeyCheckingNull:@"updated_at"]];
    
    _url = [NSURL URLWithString:[json objectForKeyCheckingNull:@"url"]];
    
    NSDictionary * assignmentDictionary = [json objectForKeyCheckingNull:@"assignment"];
    if (assignmentDictionary) {
        _assignment = [[CKAssignment alloc] initWithInfo:[json objectForKeyCheckingNull:@"assignment"]];
    }

    _contextCode = [json objectForKeyCheckingNull:@"context_code"];
    
    [self setCourseIdFromContextCode:_contextCode];
}

- (void)setCourseIdFromContextCode:(NSString *)contextCode {
    if ([_contextCode rangeOfString:@"course"].location != NSNotFound) {
        
        NSArray *listItems = [_contextCode componentsSeparatedByString:@"_"];
        NSString * courseId = listItems[1];
        
        _courseId = [courseId intValue];
    }
}


- (void)populateActionPath
{
    if (self.actionPath || !self.course) {
        return;
    }
    
    if (self.assignment.ident > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(self.assignment.ident)];
    }
}

- (NSUInteger)hash
{
    return self.typeId;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<(CKCalendarItem %p) typeID: %llu, summary: %@, startDate: %@>", self, self.typeId, self.title, self.startDate];
}

@end
