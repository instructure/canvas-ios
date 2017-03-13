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

#import <Foundation/Foundation.h>
#import "SupportTicketViewController.h"

typedef enum {
    SupportTicketImpactLevelComment,
    SupportTicketImpactLevelNotUrgent,
    SupportTicketImpactLevelWorkaroundPossible,
    SupportTicketImpactLevelBlocking,
    SupportTicketImpactLevelEmergency,
    SupportTicketImpactLevelNone
} SupportTicketImpactLevel;

@interface SupportTicket : NSObject

@property (nonatomic, strong) NSString *requesterName;
@property (nonatomic, strong) NSString *requesterEmail;
@property (nonatomic, strong) NSString *commentBody;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic) SupportTicketImpactLevel impactValue;
@property (nonatomic) SupportTicketType ticketType;
@property (nonatomic, strong) NSArray *uploadTokens;
@property (nonatomic, strong) NSError *reportedError;

- (NSDictionary *)dictionaryValue;
- (NSString *)impactString;

@end
