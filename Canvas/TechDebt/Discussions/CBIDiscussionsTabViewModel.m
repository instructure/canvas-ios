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
    
    

#import "CBIDiscussionsTabViewModel.h"
#import "CBIDiscussionTopicViewModel.h"
#import "EXTScope.h"
#import "CreateDiscussionViewController.h"
#import "EXTScope.h"
#import "DiscussionCreationIPhoneStrategy.h"

#import "CKIDiscussionTopic+LegacySupport.h"
#import "CBIAnnouncementsTabViewModel.h"
@import CanvasKeymaster;
#import "CKCanvasAPI+CurrentAPI.h"
#import "UIImage+TechDebt.h"

@interface CBIDiscussionsTabViewModel () <CreateDiscussionDelegate>

@end

@implementation CBIDiscussionsTabViewModel

typedef NS_ENUM(NSInteger, sectionType) {
    PinnedSection,
    DiscussionsSection,
    ClosedForCommentsSection
};

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *sortDescriptors = [@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]] mutableCopy];
        if([self isMemberOfClass:[CBIDiscussionsTabViewModel class]]) {
            [sortDescriptors insertObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES] atIndex:0];
        }
        
        self.viewControllerTitle = NSLocalizedString(@"Discussions", @"Title for Discussions view controller");
        
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(CBIDiscussionTopicViewModel *viewModel) {
            if (viewModel.model.isPinned) {
                return @(PinnedSection);
            }
            
            if (viewModel.model.isLocked) {
                return @(ClosedForCommentsSection);
            }
            
            return @(DiscussionsSection);
        } groupTitleBlock:^NSString *(CBIDiscussionTopicViewModel *viewModel) {
            if (viewModel.model.isPinned) {
                return NSLocalizedString(@"Pinned Discussions", nil);
            }
            
            if (viewModel.model.isLocked) {
                return NSLocalizedString(@"Closed for Comments", nil);
            }
            
            if ([self isKindOfClass:[CBIAnnouncementsTabViewModel class]]){
                return NSLocalizedString(@"Announcements", nil);
            }
            
            return NSLocalizedString(@"Discussions", nil);
        } sortDescriptors:sortDescriptors];
        
        self.discussionCreationStrategy = [DiscussionCreationIPhoneStrategy new];
        self.discussionViewModelClass = [CBIDiscussionTopicViewModel class];
        self.createButtonImage = [UIImage techDebtImageNamed:@"icon_add_discussion"];

        self.canCreateSignal = [RACObserve(self, model.context) flattenMap:^RACStream *(id context) {
            if ([context isKindOfClass:[CKICourse class]]) {
                CKICourse *course = (CKICourse *)context;
                return RACObserve(course, canCreateDiscussionTopics);
            }
            return [RACSignal return:@YES];
        }];
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIDiscussionTopicCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIDiscussionTopicCell"];
    
    tableViewController.tableView.rowHeight = 52.f;
    tableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 42.f, 0, 0);
    
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithImage:self.createButtonImage landscapeImagePhone:nil style:(UIBarButtonItemStylePlain) target:nil action:nil];
    @weakify(self, tableViewController);
    if ([self.model.context isKindOfClass:[CKICourse class]]){
        [[[CKIClient currentClient] courseWithUpdatedPermissionsSignalForCourse:((CKICourse *)self.model.context)] subscribeError:^(NSError *error) {
            NSLog(@"what went wrong getting the course permissions?");
        }];
    }
    
    [self.canCreateSignal subscribeNext:^(NSNumber *canCreate) {
        @strongify(tableViewController);
        tableViewController.navigationItem.rightBarButtonItem = [canCreate boolValue] ? create : nil;
    }];

    create.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self, tableViewController);

        CreateDiscussionViewController *create = [[CreateDiscussionViewController alloc] initWithStrategy:self.discussionCreationStrategy];
        create.canvasAPI = CKCanvasAPI.currentAPI;
        
        long long ident = [[((CKIModel *)self.model.context) id] longLongValue];
        if ([self.model.context isKindOfClass:[CKICourse class]]) {
            create.contextInfo = [CKContextInfo contextInfoFromCourseIdent:ident];
        } else if ([self.model.context isKindOfClass:[CKIGroup class]]) {
            create.contextInfo = [CKContextInfo contextInfoFromGroupIdent:ident];
        }
        
        create.delegate = self;
        create.iPadToolbarHidden = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:create];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [tableViewController presentViewController:nav animated:YES completion:nil];
        return [RACSignal empty];
    }];
}

#pragma mark - syncing

- (RACSignal *)refreshModelSignal
{
    return [[CKIClient currentClient] fetchDiscussionTopicsForContext:self.model.context];
}

- (RACSignal *)refreshViewModelsSignal
{
    __block NSInteger count = 0;
    @weakify(self);
    return [self.refreshModelSignal map:^(NSArray *discussionTopics) {
        return [[discussionTopics.rac_sequence map:^id(id value) {
            @strongify(self);
            CBIDiscussionTopicViewModel *topic = [self.discussionViewModelClass viewModelForModel:value];
            RAC(topic, tintColor) = RACObserve(self, tintColor);
            topic.index = count++;
            if([topic isKindOfClass:[CBIDiscussionTopicViewModel class]]) {
                topic.position = topic.model.position;
            }
            return topic;
        }] array];
    }];
}

- (void)showNewDiscussion:(CKDiscussionTopic *)discussionTopic
{
    CBIDiscussionTopicViewModel *newViewModel = [self.discussionViewModelClass viewModelForModel:[CKIDiscussionTopic discussionTopicFromLegacyDiscussionTopic:discussionTopic]];
    
    NSUInteger items = self.collectionController.groups.count;
    NSInteger min = items ? [[[self.collectionController[0] objects] valueForKeyPath:@"@min.index"] integerValue] : 0;
    
    newViewModel.index = --min;
    newViewModel.tintColor = self.tintColor;
    [self.collectionController insertObjects:@[newViewModel]];
}

@end
