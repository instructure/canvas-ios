//
//  CBINotificationViewModel.m
//  iCanvas
//
//  Created by Jason Larsen on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBINotificationViewModel.h"
#import "CBIMessageDetailViewController.h"
#import "UIViewController+Transitions.h"
#import "Router.h"
#import "CBINotificationMessageViewController.h"
#import "EXTScope.h"
#import "CKIClient+CBIClient.h"
#import "CBILog.h"
#import "UIImage+TechDebt.h"

@import EnrollmentKit;
@import CanvasKeymaster;

@interface CKIActivityStreamItem (RoutingPath)
/**
 A path used specifically for routing to the appropriate model
 */
- (NSString *)routingPath;
@end

@implementation CKIActivityStreamDiscussionTopicItem (RoutingPath)

- (NSString *)routingPath
{
    if (self.groupID && !self.courseID) {
        return [NSString stringWithFormat:@"/api/v1/groups/%@/discussion_topics/%@", self.groupID, self.discussionTopicID];
    }
    return [NSString stringWithFormat:@"/api/v1/courses/%@/discussion_topics/%@", self.courseID, self.discussionTopicID];
}

@end

@implementation CKIActivityStreamAnnouncementItem (RoutingPath)

- (NSString *)routingPath
{
    if (self.groupID && !self.courseID) {
        return [NSString stringWithFormat:@"/api/v1/groups/%@/discussion_topics/%@", self.groupID, self.announcementID];
    }
    return [NSString stringWithFormat:@"/api/v1/courses/%@/discussion_topics/%@", self.courseID, self.announcementID];
}

@end

// Not implementing category method for Conversation items
// because we're ignoring them—they will never be displayed
// in the notifications list

@implementation CKIActivityStreamMessageItem (RoutingPath)

- (NSString *)routingPath
{
    // parsing the URL in this manner is not shard-safe
    // we will have to wait on the backend to make sure we always
    // get the assignment ID along with the message.
    // when we do, we can remove this temporary hack.
    NSString *path = [@"/api/v1" stringByAppendingPathComponent:self.url.path];
    return path;
}

@end

@implementation CKIActivityStreamSubmissionItem (RoutingPath)

- (NSString *)routingPath
{
    // route to submission's assignment, not to the submission itself
    return [NSString stringWithFormat:@"/api/v1/courses/%@/assignments/%@", self.courseID, self.assignmentID];
}

@end

@implementation CKIActivityStreamConferenceItem (RoutingPath)

- (NSString *)routingPath
{
    return self.htmlURL.absoluteString;
}

@end

@implementation CKIActivityStreamCollaborationItem (RoutingPath)

- (NSString *)routingPath
{
    return self.htmlURL.absoluteString;
}

@end

@implementation CBINotificationViewModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        RAC(self, updatedAt) = RACObserve(self, model.updatedAt);
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, viewControllerTitle) = RACObserve(self, model.title);
        RAC(self, icon) = [RACObserve(self, model) map:^id(id value) {
            return [CBINotificationViewModel iconForStreamItem:value];
        }];
        
        RAC(self, message) = [RACObserve(self, model.message) map:^id(NSString *message) {
            return [[[NSAttributedString alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil] string];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColors:) name:CBICourseColorUpdatedNotification object:nil];
        
        RAC(self, subtitle) = [RACObserve(self, model) map:^id(CKIActivityStreamItem *model) {
            if (model.courseID != nil) {
                return [TheKeymaster.currentClient.authSession courseWithID:model.courseID].name;
            } else if (model.groupID != nil) {
                return [TheKeymaster.currentClient.authSession groupWithID:model.groupID].name;
            } else {
                return nil;
            }
        }];
        
        [self rac_liftSelector:@selector(setTintColor:) withSignals:[RACObserve(self, model) map:^id(CKIActivityStreamItem *model) {
            if (model.courseID != nil) {
                return [TheKeymaster.currentClient.authSession courseWithID:model.courseID].color;
            } else if (model.groupID != nil) {
                return [TheKeymaster.currentClient.authSession groupWithID:model.groupID].color;
            } else {
                return nil;
            }
        }], nil];
        
    }
    return self;
}

- (void)updateColors:(NSNotification *)notification
{
    if ([self.model.courseID length]) {
        NSDictionary *userInfo = [notification userInfo];
        NSString *courseID = userInfo[CBICourseColorUpdatedCourseIDKey];
        if ([courseID isEqualToString:self.model.courseID]) {
            self.tintColor = userInfo[CBICourseColorUpdatedValue];
        }
    } else if ([self.model.groupID length]) {        
        self.tintColor = [TheKeymaster.currentClient.authSession groupWithID:self.model.groupID].color;
    }
}

+ (UIImage *)iconForStreamItem:(CKIActivityStreamItem *)streamItem;
{
    if (!streamItem) {
        return nil;
    }
    NSDictionary *iconNameMap = @{(id <NSCopying>)[CKIActivityStreamDiscussionTopicItem class]: @"icon_discussions",
                                  (id <NSCopying>)[CKIActivityStreamAnnouncementItem class]: @"icon_announcements",
                                  (id <NSCopying>)[CKIActivityStreamMessageItem class]: @"icon_assignments",
                                  (id <NSCopying>)[CKIActivityStreamSubmissionItem class]: @"icon_assignments",
                                  (id <NSCopying>)[CKIActivityStreamConferenceItem class]: @"icon_conference",
                                  (id <NSCopying>)[CKIActivityStreamCollaborationItem class]: @"icon_collaborations"};
    NSString *iconName = iconNameMap[streamItem.class];
    return [[UIImage techDebtImageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.model.courseID || self.model.groupID) {
        DDLogVerbose(@"didSelectCourse : %@ or group: %@", self.model.courseID, self.model.groupID);
        NSURL *routingURL = [NSURL URLWithString:self.model.routingPath];
        [[Router sharedRouter] routeFromController:controller toURL:routingURL];
    } else {
        // for now, just display the message for all group stuffs.
        DDLogVerbose(@"didSelectNotification : %@", self.model.title);
        CBINotificationMessageViewController *messageViewController = [[CBINotificationMessageViewController alloc] init];
        messageViewController.cbi_canBecomeMaster = NO;
        messageViewController.streamItem = self.model;
        [controller cbi_transitionToViewController:messageViewController animated:YES];
    }
}

@end
