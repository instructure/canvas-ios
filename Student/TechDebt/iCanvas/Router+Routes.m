//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "Router+Routes.h"

#import "FileViewController.h"
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit/CanvasKit.h>
#import "UIViewController+Transitions.h"
#import <TechDebt/MyLittleViewController.h>

#import "UnsupportedViewController.h"
#import "CBIPeopleTabViewModel.h"
#import "CBIPeopleViewModel.h"
#import "CBIPeopleDetailViewController.h"
#import "CKIClient+CBIClient.h"
#import "UnsupportedViewController.h"

#import <CanvasKit/CanvasKit.h>
#import "CKCanvasAPI+CurrentAPI.h"
#import <SafariServices/SafariServices.h>

@import CanvasCore;
@import CanvasKeymaster;
@import CanvasCore;

typedef UIViewController *(^ViewControllerRouteBlock)(NSDictionary *params, id viewModel);

@implementation Router (Routes)

- (void)configureInitialRoutes {
    [self addRoutes];
}

-(UIUserInterfaceIdiom)interfaceIdiom{
    return [UIDevice currentDevice].userInterfaceIdiom;
}

- (id)MLVCTableViewControllerForViewModel:(id)viewModel screenName:(NSString *)name canBeMaster:(BOOL)canBecomeMaster style:(UITableViewStyle)style url:(NSString*) url
{
    MLVCTableViewController *tableViewController = [[MLVCTableViewController alloc] initWithStyle:style];
    tableViewController.url = url;
    tableViewController.viewModel = viewModel;
    return tableViewController;
}

- (UIViewController *)moduleItemControllerForParams:(NSDictionary *)params forClass:(Class)type
{
    NSString *contextID = [params[@"contextID"] description] ?: [params[@"courseID"] description];
    NSDictionary *query = params[@"query"];
    NSString *moduleItemID = query[@"module_item_id"];

    if (moduleItemID) {
        return [self controllerForHandlingURL:[self urlForModuleItemID:moduleItemID contextID:contextID contextClass:type]];
    }

    return nil;
}

- (id(^)(NSDictionary *params, id viewModel)) usersDetailBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        if(viewModel == nil) {
            CKICourse *course = [type modelWithID:[params[@"contextID"] description]];
            CKIUser *user = [CKIUser modelWithID:[params[@"userID"] stringValue] context:course];
            viewModel = [CBIPeopleViewModel viewModelForModel:user];
        }


        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];

        CBIPeopleDetailViewController *detailViewController = [CBIPeopleDetailViewController new];
        detailViewController.viewModel = viewModel;
        return detailViewController;
    };
}

- (id(^)(NSDictionary *params, id viewModel)) usersBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        if (viewModel == nil) {
            NSString *contextID = [params[@"contextID"] description];
            id<CKIContext> context = ([type isSubclassOfClass:[CKICourse class]]) ? [CKICourse modelWithID:contextID] : [CKIGroup modelWithID:contextID];
            CKITab *peopleTab = [CKITab modelWithID:@"people" context:context];
            viewModel = [CBIPeopleTabViewModel viewModelForModel:peopleTab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedStringFromTableInBundle(@"People", nil, [NSBundle bundleForClass:self.class], @"Title for the people view");
        }
        
        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        NSString * url = [params[@"url"] description];
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"People Tab" canBeMaster:YES style:UITableViewStylePlain url: url];
    };
}


- (UIColor *)tintColorForContextID:(NSString *)contextID contextClass:(Class)contextClass
{
    UIColor *tintColor;
    NSString *contextIDString = [contextID description];
    if([contextClass isSubclassOfClass:[CKIGroup class]]){
        tintColor = [TheKeymaster.currentClient.authSession colorForGroup:contextIDString];
    } else {
        tintColor = [TheKeymaster.currentClient.authSession colorForCourse:contextIDString];
    }
    return tintColor;
}

- (NSURL *)urlForModuleItemID:(NSString *)moduleItemID contextID:(NSString *)contextID contextClass:(Class)contextClass
{
    NSString *context = [contextClass isSubclassOfClass:[CKIGroup class]] ? @"groups" : @"courses";
    NSString *urlString = [NSString stringWithFormat:@"/%@/%@/modules/items/%@", context, contextID, moduleItemID];
    return [NSURL URLWithString:urlString];
}

#pragma mark - Routes
- (void)addRoutes
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    self.fallbackHandler = ^(NSURL *url, UIViewController *sender) {
        if ([url.scheme isEqualToString:@"canvas-courses"]) {
            return;
        }

        Session *session = TheKeymaster.currentClient.authSession;
        if (!session) { return; }
        [[ExternalToolManager shared] showAuthenticatedURL:url in:session from:sender completionHandler:nil];
    };
    
    [self addRoutesWithDictionary:@{
        @"/courses/:contextID/users/:userID" : [self usersDetailBlockForClass:[CKICourse class]],
        @"/groups/:contextID/users/:userID" : [self usersDetailBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/settings" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Settings", nil, bundle, @"Title for Settings");
            unsupportedVC.canvasURL = params[@"url"];
            return unsupportedVC;
        },
        @"/courses/:contextID/conferences" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Conferences", nil, bundle, @"Title for Conferences tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/conferences", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/courses/:contextID/collaborations" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Collaborations", nil, bundle, @"Title for Collaborations tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/collaborations", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/courses/:contextID/outcomes" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Outcomes", nil, bundle, @"Title for Outcomes tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/outcomes", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/groups/:contextID/conferences" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Conferences", nil, bundle, @"Title for Conferences tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"groups/%@/conferences", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/groups/:contextID/collaborations" : ^(NSDictionary *params, CBIViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedStringFromTableInBundle(@"Collaborations", nil, bundle, @"Title for Collaborations tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"groups/%@/collaborations", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/courses/:courseID/quizzes/:quizID" : ^ UIViewController *(NSDictionary *params, CBIViewModel *vm) {
            if ([self moduleItemControllerForParams:params forClass:[CKICourse class]]) {
                return [self moduleItemControllerForParams:params forClass:[CKICourse class]];
            }

            Session *session = TheKeymaster.currentClient.authSession;
            QuizIntroViewController *intro = [[QuizIntroViewController alloc] initWithSession:session courseID:[params[@"courseID"] description] quizID:[params[@"quizID"] description]];
            return intro;
        }
    }];
    
    [WhizzyWigView setOpenURLHandler:^(NSURL *url) {
        [self openCanvasURL:url withOptions:nil];
    }];

}

BOOL waitForBlock(NSTimeInterval timeout,
                  BOOL (^condition)(void)) {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
    BOOL val = condition();
    while ( val == NO && [timeoutDate timeIntervalSinceNow] > 0 ) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        val = condition();
    }
    return val;
}

@end
