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
#import "CBIQuizzesTabViewModel.h"
#import "CBIQuizViewModel.h"
#import <TechDebt/MyLittleViewController.h>

#import "CBISyllabusTabViewModel.h"
#import "CBISyllabusViewModel.h"
#import "CBICalendarEventViewModel.h"

#import "CBIFilesTabViewModel.h"
#import "CBIFolderViewModel.h"
#import "CBISyllabusDetailViewController.h"
#import "UIViewController+AnalyticsTracking.h"

#import "UnsupportedViewController.h"
#import "CBIFileViewModel.h"
#import "CBIFileViewController.h"
#import "CBIPeopleTabViewModel.h"
#import "CBIPeopleViewModel.h"
#import "CBIPeopleDetailViewController.h"
#import "CKIClient+CBIClient.h"
#import "UnsupportedViewController.h"

#import "CBIAssignmentViewModel.h"
#import "CBIAssignmentDetailViewController.h"
#import "UIViewController+AnalyticsTracking.h"

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
    [tableViewController trackScreenViewWithScreenName:name];
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
        NSString * url = [params[@"url"] description];
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Files List Screen" canBeMaster:YES style:UITableViewStylePlain url:url];
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
        NSString * url = [params[@"url"] description];
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Folder List Screen" canBeMaster:YES style:UITableViewStylePlain url: url];
    };
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
        [detailViewController trackScreenViewWithScreenName:@"People Detail Screen"];

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
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"People", @"Title for the people view");
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
    self.fallbackHandler = ^(NSURL *url, UIViewController *sender) {
        if ([url.scheme isEqualToString:@"canvas-courses"]) {
            return;
        }

        Session *session = TheKeymaster.currentClient.authSession;
        if (!session) { return; }
        [[ExternalToolManager shared] showAuthenticatedURL:url in:session from:sender completionHandler:nil];
    };
    
    UIViewController *(^syllabusListViewControllerBlock)(NSDictionary *params, id viewModel) = ^(NSDictionary *params, id viewModel) {
        if(viewModel == nil){
            CKICourse *course = [CKICourse modelWithID:[params[@"courseID"] description]];
            CKITab *syllabusTab = [CKITab modelWithID:@"syllabus" context:course];
            viewModel = [CBISyllabusTabViewModel viewModelForModel:syllabusTab];
            ((CBIColorfulViewModel *)viewModel).viewControllerTitle = NSLocalizedString(@"Course Syllabus",@"Title for Course Syllabus view controller");
        }
        
        ((CBIColorfulViewModel *)viewModel).tintColor = [TheKeymaster.currentClient.authSession colorForCourse:[params[@"courseID"] description]];
        NSString * url  = [params[@"url"] description];
        return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Syllabus List Screen" canBeMaster:YES style:UITableViewStyleGrouped url: url];
    };
    
    [self addRoutesWithDictionary:@{
        // TODO: SoPersistent assignments
        @"/courses/:courseID/assignments/:assignmentID" : ^ (NSDictionary *params, id viewModel) {
            if ([self moduleItemControllerForParams:params forClass:[CKICourse class]]) {
                return [self moduleItemControllerForParams:params forClass:[CKICourse class]];
            }
        
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
        
            return assignmentDetailViewController;
        },
        @"/groups/:contextID/files" : [self filesBlockForClass:[CKIGroup class]],
        @"/groups/:contextID/folders/root": [self filesBlockForClass:[CKIGroup class]],
        @"/groups/:contextID/folders/:folderID": [self folderBlockForClass:[CKIGroup class]],
        @"/folders/:folderID" : ^(NSDictionary *params, CBIColorfulViewModel *viewModel) {
            if(viewModel == nil){
                CKIFolder *folder = [CKIFolder modelWithID:[params[@"folderID"] description]];
                viewModel = [CBIFolderViewModel viewModelForModel:folder];
                viewModel.tintColor = [UIColor prettyBlack];
            }
        
            NSString * url = [params[@"url"] description];
            return [self MLVCTableViewControllerForViewModel:viewModel screenName:@"Folder List Screen" canBeMaster:YES style:UITableViewStylePlain url: url];
        },
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
            
            return syllabusViewController;
        },
        @"/courses/:courseID/quizzes": ^(NSDictionary *params, CBIQuizzesTabViewModel *quizzesTabViewModel) {
            NSString *contextID = [params[@"courseID"] description];
            if (quizzesTabViewModel == nil) {
                quizzesTabViewModel = [CBIQuizzesTabViewModel new];
                quizzesTabViewModel.model = [CKITab modelWithID:@"quizzes" context:[CKICourse modelWithID:contextID]];
            }
        
            quizzesTabViewModel.tintColor = [self tintColorForContextID:contextID contextClass:[CKICourse class]];
            NSString * url = [params[@"url"] description];
            return [self MLVCTableViewControllerForViewModel:quizzesTabViewModel screenName:@"Quizzes List Screen" canBeMaster:YES style:UITableViewStylePlain url: url];
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
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/conferences", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/courses/:contextID/collaborations" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Collaborations",@"Title for Collaborations tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/collaborations", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/courses/:contextID/outcomes" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Outcomes",@"Title for Outcomes tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"courses/%@/outcomes", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/groups/:contextID/conferences" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Conferences",@"Title for Conferences tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"groups/%@/conferences", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
        @"/groups/:contextID/collaborations" : ^(NSDictionary *params, CBIFileViewModel *viewModel) {
            UnsupportedViewController *unsupportedVC = [UnsupportedViewController new];
            unsupportedVC.tabName = NSLocalizedString(@"Collaborations",@"Title for Collaborations tab");
            NSURL *baseURL = TheKeymaster.currentClient.baseURL;
            NSString *path = [NSString stringWithFormat:@"groups/%@/collaborations", params[@"contextID"]];
            NSURL *fullURL = [baseURL URLByAppendingPathComponent: path];
            unsupportedVC.canvasURL = fullURL;
            return unsupportedVC;
        },
    }];
    
    
    // Quizzes
    UIViewController *(^quizControllerConstructor)(NSDictionary *, CBIQuizViewModel *) = ^ UIViewController *(NSDictionary *params, CBIQuizViewModel *vm) {
        if ([self moduleItemControllerForParams:params forClass:[CKICourse class]]) {
            return [self moduleItemControllerForParams:params forClass:[CKICourse class]];
        }

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
    
    UIViewController *(^fileDownloadConstructor)(NSDictionary *, CBIQuizViewModel *) = ^ UIViewController *(NSDictionary *params, CBIQuizViewModel *vm) {        
        FileViewController *fileVC = [[FileViewController alloc] init];
        [fileVC applyRoutingParameters:params];
        return (UIViewController *)fileVC;
    };
    
    [self addRoutesWithDictionary:@{
        @"/groups/:groupIdent/files/:fileIdent" : fileDownloadConstructor,
        @"/groups/:groupIdent/files/:fileIdent/download" : fileDownloadConstructor,
        @"/courses/:courseIdent/files/:fileIdent" : fileDownloadConstructor,
        @"/courses/:courseIdent/files/:fileIdent/download" : fileDownloadConstructor,
        @"/users/:userIdent/files/:fileIdent" : fileDownloadConstructor,
        @"/users/:userIdent/files/:fileIdent/download" : fileDownloadConstructor,
        @"/files/:fileIdent/download" : fileDownloadConstructor,
        @"/files/:fileIdent" : fileDownloadConstructor,
    }];
    
    [WhizzyWigView setOpenURLHandler:^(NSURL *url) {
        if ([url.host isEqualToString:TheKeymaster.currentClient.baseURL.host]) {
            [self openCanvasURL:url withOptions:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
