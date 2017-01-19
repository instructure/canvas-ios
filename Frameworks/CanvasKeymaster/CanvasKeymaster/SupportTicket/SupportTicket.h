//
//  SupportTicket.h
//  iCanvas
//
//  Created by Rick Roberts on 8/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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

- (NSDictionary *)dictionaryValue;
- (NSString *)impactString;

@end
