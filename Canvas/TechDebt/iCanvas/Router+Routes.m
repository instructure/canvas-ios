
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "Router+Routes.h"

#import "FileViewController.h"
#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit/CanvasKit.h>
#import "UIViewController+Transitions.h"
#import "CBIModuleItemTransitioningDelegate.h"
#import "CBIQuizzesTabViewModel.h"
#import "CBIQuizViewModel.h"
@import MyLittleViewController;

#import "CBIAnnouncementsTabViewModel.h"
#import "CBIModulesTabViewModel.h"
#import "CBIModuleViewModel.h"
#import "CBIModuleItemViewModel.h"
#import "CBISyllabusTabViewModel.h"
#import "CBISyllabusViewModel.h"
#import "CBICalendarEventViewModel.h"
#import "CBINotificationTableViewModel.h"

#import "ScheduleItem.h"
#import "WebBrowserViewController.h"
#import "ThreadedDiscussionViewController.h"
#import "CBIDiscussionsTabViewModel.h"
#import "CBIFilesTabViewModel.h"
#import "CBIFolderViewModel.h"
#import "CBISyllabusDetailViewController.h"
#import "ScheduleItem.h"
#import "ScheduleItemController.h"

#import "UnsupportedViewController.h"
#import "CBIExternalToolViewModel.h"
#import "CBILTIViewController.h"
#import "CBIFileViewModel.h"
#import "CBIFileViewController.h"
#import "CBIPeopleTabViewModel.h"
#import "CBIPeopleViewModel.h"
#import "CBIPeopleDetailViewController.h"
#import "CBIAnnouncementViewModel.h"
#import "CKIClient+CBIClient.h"
#import "CBISadPandaTabViewModel.h"
#import "UnsupportedViewController.h"
#import "CBIMessageViewModel.h"
#import "CBIMessageDetailViewController.h"

#import "CBIAssignmentViewModel.h"
#import "CBIAssignmentDetailViewController.h"
#import "UIViewController+AnalyticsTracking.h"

@import QuizKit;
#import <CanvasKit/CanvasKit.h>
#import "CKCanvasAPI+CurrentAPI.h"

@import PageKit;
@import WhizzyWig;
@import CanvasKeymaster;
@import EnrollmentKit;
@import SoPretty;

typedef UIViewController *(^ViewControllerRouteBlock)(NSDictionary *params, id viewModel);

@implementation Router (Routes)

- (void)configureInitialRoutes {
    [self addRoutes];
}

-(UIUserInterfaceIdiom)interfaceIdiom{
    return [UIDevice currentDevice].userInterfaceIdiom;
}

- (id)MLVCTableViewControllerForViewModel:(id)viewModel screenName:(NSString *)name canBeMaster:(BOOL)canBecomeMaster style:(UITableViewStyle)style
{
    MLVCTableViewController *tableViewController = [[MLVCTableViewController alloc] initWithStyle:style];
    [tableViewController trackScreenViewWithScreenName:name];
    tableViewController.viewModel = viewModel;
    tableViewController.cbi_canBecomeMaster = canBecomeMaster;
    return tableViewController;
}

- (id(^)(NSDictionary *params, CBIFilesTabViewModel *viewModel)) filesBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, CBIFilesTabViewModel *viewModel) {
        if(viewModel == nil){
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKITab *filesTab = [CKITab modelWithID:@"files" context:context];
            viewModel = [CBIFilesTabViewModel viewModelForModel:filesTab];
            viewModel.viewControllerTitle = NSLocalizedString(@"Files", @"Title for the files screen");
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Files List Screen" canBeMaster:YES style:UITableViewStylePlain];
    };
}

- (id(^)(NSDictionary *params, CBIFolderViewModel *viewModel)) folderBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, CBIFolderViewModel *viewModel) {
        if ([[params[@"folderID"] description] isEqualToString:@"root"]) {
            return [self filesBlockForClass:type](params, nil);
        }

        if (viewModel == nil) {
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKIFolder *folder = [CKIFolder modelWithID:[params[@"folderID"] description] context:context];
            viewModel = [CBIFolderViewModel viewModelForModel:folder];
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];

        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Folder List Screen" canBeMaster:YES style:UITableViewStylePlain];
    };
}

- (id(^)(NSDictionary *params, id viewModel)) courseGroupActivityStreamBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        if(viewModel == nil){
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKITab *notificationsTab = [CKITab modelWithID:@"activity_stream" context:context];
            viewModel = [CBINotificationTableViewModel viewModelForModel:notificationsTab];
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Home Tab Screen" canBeMaster:YES style:UITableViewStylePlain];
    };
}

- (id(^)(NSDictionary *params, id viewModel)) courseGroupAnnouncementsBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        if(viewModel == nil){
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKITab *announcementsTab = [CKITab modelWithID:@"announcements" context:context];
            viewModel = [CBIAnnouncementsTabViewModel viewModelForModel:announcementsTab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Announcements", @"Title for the announcements view controller");
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Announcements List Screen" canBeMaster:YES style:UITableViewStyleGrouped];
    };
}

- (id(^)(NSDictionary *params, CBIAnnouncementViewModel *viewModel)) courseGroupAnnouncementBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, CBIAnnouncementViewModel *viewModel) {
        NSString *contextID = [params[@"contextID"] description];
        NSString *topicID = [params[@"announcementID"] description];
        
        CKContextInfo *info;
        if (type == [CKICourse class]) {
            info = [CKContextInfo contextInfoFromCourseIdent:[contextID longLongValue]];
        } else {
            info = [CKContextInfo contextInfoFromGroupIdent:[contextID longLongValue]];
        }

        ThreadedDiscussionViewController *discussionViewController = [ThreadedDiscussionViewController new];
        discussionViewController.viewModel = viewModel;
        [discussionViewController trackScreenViewWithScreenName:@"Announcement Screen"];

        discussionViewController.contextInfo = info;
        discussionViewController.topicIdent = [topicID longLongValue];
        discussionViewController.canvasAPI = CKCanvasAPI.currentAPI;
        [discussionViewController performSelector:@selector(fetchTopic:) withObject:@YES];
        return discussionViewController;
    };
}

- (id(^)(NSDictionary *params, id viewModel)) courseGroupDiscussionsBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, CBIDiscussionsTabViewModel *viewModel) {
        if (viewModel == nil) {
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKITab *tab = [CKITab modelWithID:@"discussions" context:context];
            viewModel = [CBIDiscussionsTabViewModel viewModelForModel:tab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Discussions",@"Title for Discussions view controller");
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Discussions List Screen" canBeMaster:YES style:UITableViewStyleGrouped];
    };
}

- (id(^)(NSDictionary *params, id viewModel)) courseGroupDiscussionTopicsBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, CBIDiscussionsTabViewModel *viewModel) {
        if (viewModel == nil) {
            CKIModel *context = [type modelWithID:[params[@"contextID"] description]];
            CKITab *tab = [CKITab modelWithID:@"discussions" context:context];
            viewModel = [CBIDiscussionsTabViewModel viewModelForModel:tab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Discussion Topics",@"Title for Discussion Topics view controller");
        }

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Discussion Topics List Screen" canBeMaster:YES style:UITableViewStyleGrouped];
    };
}

- (id(^)(NSDictionary *params, id viewModel)) courseGroupDiscussionTopicBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        
        NSString *contextID = [params[@"contextID"] description];
        NSString *topicID = [params[@"topicID"] description];
        
        ThreadedDiscussionViewController *discussionViewController = [ThreadedDiscussionViewController new];
        [discussionViewController trackScreenViewWithScreenName:@"Discussion Screen"];
        
        discussionViewController.viewModel = viewModel;

        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];

        discussionViewController.topicIdent = [topicID longLongValue];
        discussionViewController.canvasAPI = CKCanvasAPI.currentAPI;

        if (type == [CKICourse class]) {
            discussionViewController.contextInfo = [CKContextInfo contextInfoFromCourseIdent:[contextID longLongValue]];
        } else if(type == [CKIGroup class]) {
            discussionViewController.contextInfo = [CKContextInfo contextInfoFromGroupIdent:[contextID longLongValue]];
        }
    
        [discussionViewController performSelector:@selector(fetchTopic:) withObject:@NO];
        return discussionViewController;
    };
}

- (id(^)(NSDictionary *params, id viewModel)) usersDetailBlockForClass:(Class)type
{
    return ^ (NSDictionary *params, id viewModel) {
        if(viewModel == nil) {
            CKICourse *course = [type modelWithID:[params[@"contextID"] description]];
            CKIUser *user = [CKIUser modelWithID:params[@"userID"] context:course];
            viewModel = [CBIPeopleViewModel viewModelForModel:user];
        }


        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];

        CBIPeopleDetailViewController *detailViewController = [CBIPeopleDetailViewController new];
        [detailViewController trackScreenViewWithScreenName:@"People Detail Screen"];

        detailViewController.viewModel = viewModel;
        detailViewController.cbi_canBecomeMaster = NO;

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
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"People", @"Title for the people view");
        }
        
        ((CBIColorfulViewModel *)viewModel).tintColor = [self tintColorForContextID:params[@"contextID"] contextClass:type];

        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"People Tab" canBeMaster:YES style:UITableViewStylePlain];
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

#pragma mark - Routes
- (void)addRoutes
{
    @weakify(self);
    
    self.fallbackHandler = ^(NSURL *url, UIViewController *sender) {
        @strongify(self);
        if ([url.scheme isEqualToString:@"canvas-courses"]) {
            return;
        }
        
        UINavigationController *controller = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
        WebBrowserViewController *browser = controller.viewControllers[0];
        [browser setUrl:url];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [sender presentViewController:controller animated:YES completion:nil];
    };
    
    UIViewController *(^syllabusListViewControllerBlock)(NSDictionary *params, id viewModel) = ^(NSDictionary *params, id viewModel) {
        if(viewModel == nil){
            CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
            CKITab *syllabusTab = [CKITab modelWithID:@"syllabus" context:course];
            viewModel = [CBISyllabusTabViewModel viewModelForModel:syllabusTab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Course Syllabus",@"Title for Course Syllabus view controller");
        }
        
        ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
        
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Syllabus List Screen" canBeMaster:YES style:UITableViewStyleGrouped];
    };
    
    [self addRoutesWithDictionary:@{
        @"/courses/:contextID/announcements" : [self courseGroupAnnouncementsBlockForClass:[CKICourse class]],
        @"/groups/:contextID/announcements" : [self courseGroupAnnouncementsBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/activity_stream" : [self courseGroupActivityStreamBlockForClass:[CKICourse class]],
        @"/groups/:contextID/activity_stream" : [self courseGroupActivityStreamBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/discussions" : [self courseGroupDiscussionsBlockForClass:[CKICourse class]],
        @"/groups/:contextID/discussions" : [self courseGroupDiscussionsBlockForClass:[CKIGroup class]],
        //This is identical to @"/courses/:courseID/discussions" but both routes are needed
        @"/courses/:contextID/discussion_topics" : [self courseGroupDiscussionTopicsBlockForClass:[CKICourse class]],
        @"/groups/:contextID/discussion_topics" : [self courseGroupDiscussionTopicsBlockForClass:[CKIGroup class]],
        
        // TODO: SoPersistent assignments
        @"/courses/:courseID/assignments/:assignmentID" : ^ (NSDictionary *params, id viewModel) {
        
            NSString *assignmentID = [params[@"assignmentID"] description];
            if ([assignmentID isEqualToString:@"syllabus"]) {
                return syllabusListViewControllerBlock(params, viewModel);
            }
        
            if(viewModel == nil){
                CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
                CKIAssignment *assignment = [CKIAssignment modelWithID:[params[@"assignmentID"] description] context:course];
                viewModel = [CBIAssignmentViewModel viewModelForModel:assignment];
            }

            ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
            UIViewController *viewController = [CBIAssignmentDetailViewController new];
            [viewController trackScreenViewWithScreenName:@"Assignment Detail Screen"];
            ((CBIAssignmentDetailViewController *)viewController).viewModel = viewModel;
            viewController.cbi_canBecomeMaster = NO;
        
            return viewController;
        },
        

        @"/courses/:courseID/assignments/:assignmentID/submissions/:submissionID" : ^ (NSDictionary *params, id viewModel) {
            if(viewModel == nil){
                CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
                CKIAssignment *assignment = [CKIAssignment modelWithID:[params[@"assignmentID"] description] context:course];
                viewModel = [CBIAssignmentViewModel viewModelForModel:assignment];
            }

        ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
            CBIAssignmentDetailViewController *assignmentDetailViewController = [CBIAssignmentDetailViewController new];
            [assignmentDetailViewController trackScreenViewWithScreenName:@"Assignment Detail Screen"];

            assignmentDetailViewController.viewModel = viewModel;
            assignmentDetailViewController.cbi_canBecomeMaster = NO;
        
            return assignmentDetailViewController;
        },
        @"/courses/:contextID/files" : [self filesBlockForClass:[CKICourse class]],
        @"/groups/:contextID/files" : [self filesBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/folders/root": [self filesBlockForClass:[CKICourse class]],
        @"/groups/:contextID/folders/root": [self filesBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/folders/:folderID": [self folderBlockForClass:[CKICourse class]],
        @"/groups/:contextID/folders/:folderID": [self folderBlockForClass:[CKIGroup class]],
        @"/folders/:folderID" : ^(NSDictionary *params, CBIColorfulViewModel *viewModel) {
            if(viewModel == nil){
                CKIFolder *folder = [CKIFolder modelWithID:[params[@"folderID"] description]];
                viewModel = [CBIFolderViewModel viewModelForModel:folder];
                viewModel.tintColor = [UIColor prettyBlack];
            }
        
            return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Folder List Screen" canBeMaster:YES style:UITableViewStylePlain];
        },
        @"/courses/:contextID/discussion_topics/:topicID" : [self courseGroupDiscussionTopicBlockForClass:[CKICourse class]],
        @"/groups/:contextID/discussion_topics/:topicID" : [self courseGroupDiscussionTopicBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/announcements/:announcementID" : [self courseGroupAnnouncementBlockForClass:[CKICourse class]],
        @"/groups/:contextID/announcements/:announcementID" : [self courseGroupAnnouncementBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/people" : [self usersBlockForClass:[CKICourse class]],
        @"/courses/:contextID/users" : [self usersBlockForClass:[CKICourse class]],
        @"/groups/:contextID/people" : [self usersBlockForClass:[CKIGroup class]],
        @"/groups/:contextID/users" : [self usersBlockForClass:[CKIGroup class]],
        @"/courses/:contextID/users/:userID" : [self usersDetailBlockForClass:[CKICourse class]],
        @"/groups/:contextID/users/:userID" : [self usersDetailBlockForClass:[CKIGroup class]],
        @"/courses/:courseID/syllabus" : syllabusListViewControllerBlock,
        @"/courses/:courseID/item/syllabus" : ^ (NSDictionary *params, id viewModel) {
            if(viewModel == nil){
                CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
                viewModel = [CBISyllabusViewModel viewModelForModel:course];
                ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Syllabus",@"Title for Syllabus screen");
            }

        ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
    
            CBISyllabusDetailViewController *syllabusViewController = [CBISyllabusDetailViewController new];
            [syllabusViewController trackScreenViewWithScreenName:@"Syllabus Detail Screen"];

            syllabusViewController.viewModel = viewModel;
            syllabusViewController.cbi_canBecomeMaster = NO;
            
            return syllabusViewController;
        },
        @"/calendar_events/:eventID" : ^ (NSDictionary *params, CBICalendarEventViewModel *viewModel) {
            if(viewModel == nil){
                CKICalendarEvent *calendarEvent = [CKICalendarEvent modelWithID:[params[@"eventID"] description]];
                viewModel = [CBICalendarEventViewModel viewModelForModel:calendarEvent];
            }
        ScheduleItemController *calendarEventViewController = [ScheduleItemController new];
        [calendarEventViewController trackScreenViewWithScreenName:@"Calendar Event Screen"];
        calendarEventViewController.cbi_canBecomeMaster = NO;

        [[TheKeymaster.currentClient refreshModel:viewModel.model parameters:nil] subscribeCompleted:^{
            CKICalendarEvent *calendarEvent = ((CBICalendarEventViewModel *)viewModel).model;
            CKCalendarItem *model = [CKCalendarItem new];
            model = [model initWithInfo:[calendarEvent JSONDictionary]];
            ScheduleItem *event = [[ScheduleItem new] initWithObject:model];
            [calendarEventViewController loadDetailsForScheduleItem:event];
        }];
        
            return calendarEventViewController;
        },
        @"/courses/:courseID/modules": ^(NSDictionary *params, CBIModulesTabViewModel *modulesTabViewModel) {
        NSString *courseID = [params[@"courseID"] description];
            if (modulesTabViewModel == nil) {
                modulesTabViewModel = [CBIModulesTabViewModel new];
                modulesTabViewModel.model = [CKITab modelWithID:@"modules" context:[CKICourse modelWithID:courseID]];
            }
            modulesTabViewModel.tintColor = [self tintColorForContextID:courseID contextClass:[CKICourse class]];
            return [self MLVCTableViewControllerForViewModel:modulesTabViewModel screenName:@"Modules List Screen" canBeMaster:YES style:UITableViewStylePlain];
        },
        @"/courses/:courseID/modules/:id": ^(NSDictionary *params, CBIModuleViewModel *tabViewModel) {
            if (tabViewModel == nil) {
                tabViewModel = [CBIModuleViewModel new];
                
                //When routing from Pages id is stored as a NSNumber. This fells a little hacky, but safer then possibly breaking the code by changing where it is set.
                NSString *moduleID = [NSString stringWithFormat:@"%@", params[@"id"]];
                
                tabViewModel.model = [CKIModule modelWithID:moduleID context:[CKICourse modelWithID:[params[@"courseID"] description]]];
            }

            MLVCTableViewController *viewController = [self MLVCTableViewControllerForViewModel:tabViewModel screenName:@"Module Detail Screen" canBeMaster:YES style:UITableViewStylePlain];

            // use a custom transitioning delegate to wrap the module item in the module progression vc
            viewController.cbi_transitioningDelegate = [[CBIModuleItemTransitioningDelegate alloc] initWithTransitioningDelegate:viewController.cbi_transitioningDelegate];

            return viewController;
        },
        @"/courses/:courseID/modules/:moduleID/items/:moduleItemID" : ^ (NSDictionary *params, id viewModel) {
            if(viewModel == nil){
                CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
                CKIModule *module = [CKIModule modelWithID:[params[@"moduleID"] description] context:course];
                CKIModuleItem *moduleItem = [CKIModuleItem modelWithID:params[@"moduleItemID"] context:module];
                viewModel = [CBIModuleItemViewModel viewModelForModel:moduleItem];
            }
            
            ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
            return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Module Item Screen" canBeMaster:YES style:UITableViewStylePlain];
        },
        @"/courses/:courseID/quizzes": ^(NSDictionary *params, CBIQuizzesTabViewModel *quizzesTabViewModel) {
            NSString *contextID = [params[@"courseID"] description];
            if (quizzesTabViewModel == nil) {
                quizzesTabViewModel = [CBIQuizzesTabViewModel new];
                quizzesTabViewModel.model = [CKITab modelWithID:@"quizzes" context:[CKICourse modelWithID:contextID]];
            }
        
            quizzesTabViewModel.tintColor = [self tintColorForContextID:contextID contextClass:[CKICourse class]];
        
            return [self MLVCTableViewControllerForViewModel:quizzesTabViewModel screenName:@"Quizzes List Screen" canBeMaster:YES style:UITableViewStylePlain];
        },
        @"/courses/:courseID/external_tools/:toolID": ^(NSDictionary *params, CBIExternalToolViewModel *toolViewModel) {
            if (toolViewModel == nil) {
                CKIExternalTool *tool = [CKIExternalTool modelWithID:[params[@"toolID"] description] context:[CKICourse modelWithID:[params[@"courseID"] description]]];
                tool.url = params[@"url"];
                toolViewModel = [CBIExternalToolViewModel viewModelForModel:tool];
            }
        
            CBILTIViewController *ltiViewController = [CBILTIViewController new];
            ltiViewController.viewModel = toolViewModel;
            return ltiViewController;
        },
        @"/courses/:courseIdent/files/:fileIdent" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            if (viewModel == nil) {
                CKICourse *course = [CKICourse modelWithID:[params[@"courseIdent"] description]];
                CKIFile *file = [CKIFile modelWithID:[params[@"fileIdent"] description] context:course];
                viewModel = [CBIFileViewModel viewModelForModel:file];
            }
            
            CBIFileViewController *controller = [[CBIFileViewController alloc] init];
            controller.viewModel = viewModel;
            [controller applyRoutingParameters:params];
            return controller;
        },

        @"/courses/:contextID/settings" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Settings",@"Title for Settings");
            unsupportedVC.canvasURL = params[@"url"];
            return unsupportedVC;
        },
        @"/courses/:contextID/conferences" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Conferences",@"Title for Conferences tab");
            unsupportedVC.canvasURL = params[@"url"];
            return unsupportedVC;
        },
        @"/courses/:contextID/collaborations" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Collaborations",@"Title for Collaborations tab");
            unsupportedVC.canvasURL = params[@"url"];
            return unsupportedVC;
        },
        @"/courses/:contextID/outcomes" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Outcomes",@"Title for Outcomes tab");
            unsupportedVC.canvasURL = params[@"url"];
            return unsupportedVC;
        },

        @"/files/:fileIdent/download" : ^(NSDictionary *params, id viewModel) {
            NSURL *downloadURL = params[@"downloadURL"];
        
            if (downloadURL.absoluteString.length) {
                WebBrowserViewController *browserController = [[WebBrowserViewController alloc] initWithNibName:@"WebBrowserViewController" bundle:[NSBundle bundleForClass:[self class]]];
                [browserController setUrl:downloadURL];
                return (UIViewController *)browserController;
            }
        
            FileViewController *fileVC = [[FileViewController alloc] init];
            [fileVC applyRoutingParameters:params];
            return (UIViewController *)fileVC;
        },
        
        @"/conversations/:conversationID" : ^ (NSDictionary *params, CBIMessageViewModel *viewModel) {
            if (viewModel == nil) {
                CKIConversation *conversation = [CKIConversation modelWithID:[params[@"conversationID"] description]];
                viewModel = [CBIMessageViewModel viewModelForModel:conversation];
            }
        
            CBIMessageDetailViewController *messageVC = [[CBIMessageDetailViewController alloc] init];
            messageVC.viewModel = viewModel;
            
            return messageVC;
        },
    }];
    
    
    // Quizzes
    UIViewController *(^quizControllerConstructor)(NSDictionary *, CBIQuizViewModel *) = ^(NSDictionary *params, CBIQuizViewModel *vm) {
        if (vm == nil) {
            CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
            vm = [CBIQuizViewModel viewModelForModel:[CKIQuiz modelWithID:[params[@"quizID"] description] context:course]];
        }
        
        Session *session = TheKeymaster.currentClient.authSession;
        NSURL *baseURL = TheKeymaster.currentClient.baseURL;
        NSURL *fullURL = [baseURL URLByAppendingPathComponent:vm.model.path];
        
        QuizIntroViewController *intro = [[QuizIntroViewController alloc] initWithSession:session quizURL:fullURL quizID:vm.model.id];
        return intro;
    };
    
    [self addRoute:@"/courses/:courseID/quizzes/:quizID" handler:quizControllerConstructor];
    
    [self addRoutesWithDictionary:@{
        // Discussions
        @"/courses/:courseIdent/files/:fileIdent" : [FileViewController class],
        @"/groups/:groupIdent/files/:fileIdent" : [FileViewController class],
        // Files
        @"/files/:fileIdent" : [FileViewController class],
        @"/courses/:courseIdent/files/:fileIdent/download" : [FileViewController class],
    }];
    
    [WhizzyWigView setOpenURLHandler:^(NSURL *url) {
        if ([url.host isEqualToString:TheKeymaster.currentClient.baseURL.host]) {
            [self openCanvasURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
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
