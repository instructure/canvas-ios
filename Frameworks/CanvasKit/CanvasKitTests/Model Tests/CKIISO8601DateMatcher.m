//
//  CKIISO8601DateMatcher.m
//  CanvasKit
//
//  Created by Miles Wright on 10/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIISO8601DateMatcher.h"
#import "ISO8601DateFormatter.h"

@interface CKIISO8601DateMatcher ()

@property (nonatomic, strong) id otherSubject;

@end

@implementation CKIISO8601DateMatcher

#pragma mark Getting Matcher Strings

+ (NSArray *)matcherStrings
{
    return @[@"equalISO8601String:"];
}

#pragma mark Matching

- (BOOL)evaluate
{
    static ISO8601DateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [ISO8601DateFormatter new];
    });
    
    NSDate *expectedDate = [formatter dateFromString:self.otherSubject];
    
    return [self.subject isEqual:expectedDate];
}

#pragma mark Getting Failure Messages

- (NSString *)failureMessageForShould
{
    return [NSString stringWithFormat:@"expected subject to be %@, value was %@", self.subject, self.otherSubject];
}

#pragma mark Configuring Matchers

- (void)equalISO8601String:(id)anObject
{
    self.otherSubject = anObject;
}

@end
