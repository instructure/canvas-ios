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
