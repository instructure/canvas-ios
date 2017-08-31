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
    
    

#import <CanvasKit/CKIEnrollment.h>
#import "CBIPeopleTabViewModel.h"
#import "CBIPeopleViewModel.h"
@import CanvasKeymaster;

typedef NS_ENUM(NSInteger, CBIPeopleTabSection) {
    CBIPeopleTabSectionTeacher,
    CBIPeopleTabSectionTA,
    CBIPeopleTabSectionStudent,
    CBIPeopleTabSectionObserver,
    CBIPeopleTabSectionOther
};

@interface CBIPeopleTabViewModel ()

@end

@implementation CBIPeopleTabViewModel


- (id)init
{
    self = [super init];
    if (self) {
        self.viewControllerTitle = NSLocalizedString(@"People", @"Title for the people view");
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(CBIPeopleViewModel *viewModel) {
            CKIUser *user = (CKIUser *) viewModel.model;
            NSArray *enrollments = user.enrollments;
            NSInteger section = [self sectionForEnrollment:enrollments.firstObject];
            return @(section);
        } groupTitleBlock:^NSString *(CBIPeopleViewModel *viewModel) {
            CKIUser *user = (CKIUser *) viewModel.model;

            if ([user.context isKindOfClass:[CKIGroup class]]) {
                return nil; // groups don't have enrollments, so return nil to not have any header for the section.
            }

            NSArray *enrollments = user.enrollments;
            NSInteger section = [self sectionForEnrollment:enrollments.firstObject];
            NSString *title = [self titleForSection:section];
            return title;
        } sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"model.sortableName" ascending:YES]]];
    }
    return self;
}

- (NSInteger)sectionForEnrollment:(CKIEnrollment *)enrollment
{
    NSString *role = enrollment.role;
    NSDictionary *roleSectionMap = @{
            @"TeacherEnrollment" : @(CBIPeopleTabSectionTeacher),
            @"TaEnrollment" : @(CBIPeopleTabSectionTA),
            @"StudentEnrollment" : @(CBIPeopleTabSectionStudent),
            @"ObserverEnrollment" : @(CBIPeopleTabSectionObserver),
    };
    NSNumber *section = roleSectionMap[role] ?: @(CBIPeopleTabSectionOther);
    return [section integerValue];
}

- (NSString *)titleForSection:(NSInteger)section
{
    NSDictionary *sectionTitleMap = @{
            @(CBIPeopleTabSectionTeacher) : NSLocalizedString(@"Teachers", nil),
            @(CBIPeopleTabSectionTA) : NSLocalizedString(@"TAs",nil),
            @(CBIPeopleTabSectionStudent) : NSLocalizedString(@"Student",nil),
            @(CBIPeopleTabSectionObserver) : NSLocalizedString(@"Observer",nil),
            @(CBIPeopleTabSectionOther) : NSLocalizedString(@"Other",nil)
    };
    NSString *title = sectionTitleMap[@(section)];
    NSAssert(title, @"Asked for title of an impossible section");
    return title;
}

#pragma mark - MLVCViewModel

- (RACSignal *)refreshViewModelsSignal
{
    return [[[CKIClient currentClient] fetchUsersForContext:self.model.context] map:^id(NSArray *userModels) {
        return [[userModels.rac_sequence map:^id(CKIUser *user) {
            CBIPeopleViewModel *viewModel = [CBIPeopleViewModel viewModelForModel:user];
            RAC(viewModel, tintColor) = RACObserve(self, tintColor);
            return viewModel;
        }] array];
    }];
}

#pragma mark - MLVCTableViewModel

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [super tableViewControllerViewDidLoad:tableViewController];
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIPeopleAvatarCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
    tableViewController.tableView.rowHeight = 50;
    tableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 20.f, 0, 0);
}

@end
