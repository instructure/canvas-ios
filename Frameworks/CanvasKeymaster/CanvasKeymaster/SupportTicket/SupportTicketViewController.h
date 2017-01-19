//
//  SupportTicketViewController.h
//  iCanvas
//
//  Created by Rick Roberts on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SupportTicketTypeProblem,
    SupportTicketTypeFeatureRequest
} SupportTicketType;

@interface SupportTicketViewController : UIViewController
+ (SupportTicketViewController *)presentFromViewController:(UIViewController *)presenter supportTicketType:(SupportTicketType)type;
@property (nonatomic) SupportTicketType ticketType;
@property (nonatomic) NSString *initialTicketBody;
@end
