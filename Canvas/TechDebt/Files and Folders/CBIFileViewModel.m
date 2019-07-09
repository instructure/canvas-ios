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

#import "CBIFileViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "EXTScope.h"
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"
#import "UIAlertController+TechDebt.h"
#import "FileViewController.h"

@import CanvasCore;

@interface CBIFileViewModel () <UIAlertViewDelegate>
@property (nonatomic) ToastManager *toastManager;
@end

@implementation CBIFileViewModel

@dynamic model;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.name);
        RAC(self, lockedItemName) = RACObserve(self, model.name);
        self.icon = [[UIImage techDebtImageNamed:@"icon_page"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        RAC(self, viewControllerTitle) = RACObserve(self, model.name);
        
        @weakify(self);
        [RACObserve(self, model.context) subscribeNext:^(id x) {
            @strongify(self);
            if ([self.model.context isKindOfClass:[CKIGroup class]]) {
                self.canEdit = YES;
            } else {
                CKICourse *course = (CKICourse *)self.model.context;
                if ([course isKindOfClass:[CKICourse class]]) {
                    RAC(self, canEdit) = [RACObserve(course, enrollments) map:^id(NSArray *enrollments) {
                        BOOL isTeacherOrTA = [enrollments.rac_sequence any:^BOOL(CKIEnrollment *enrollment) {
                            return enrollment.type == CKIEnrollmentTypeTeacher || enrollment.type == CKIEnrollmentTypeTA || enrollment.type == CKIEnrollmentTypeDesigner;
                        }];
                        return @(isTeacherOrTA);
                    }];
                }
            }
        }];
        self.canEdit = NO;
        
    }
    return self;
}

#pragma mark - tableview delegate

- (void)viewControllerViewDidLoad:(UIViewController *)viewController {
    self.toastManager = [[ToastManager alloc] initWithNavigationBar:viewController.navigationController.navigationBar];
}

- (BOOL)tableViewController:(MLVCTableViewController *)controller canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.canEdit;
}

- (void)tableViewController:(MLVCTableViewController *)tableViewController commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableViewController.viewModel.collectionController removeObjectAtIndexPath:indexPath];
    MLVCViewController *detail = [tableViewController.splitViewController.viewControllers objectAtIndex:1];
    if (detail.class == [FileViewController class] || self == detail.viewModel) {
        UINavigationController *emptyNav = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
        emptyNav.view.backgroundColor = [UIColor whiteColor];
        tableViewController.splitViewController.viewControllers = @[tableViewController.splitViewController.viewControllers.firstObject, emptyNav];
    }
    
    RACSignal *deleteSignal = [[CKIClient currentClient] deleteFile:self.model];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];

    [deleteSignal subscribeCompleted:^{
        [self.toastManager toastSuccess:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Deleted file: \"%@\"", nil, bundle, @"delete file confirmation alert"), self.name]];
    }];
    
    @weakify(self);
    [deleteSignal subscribeError:^(NSError *error) {
        @strongify(self);
        [self.toastManager endToast];
        [tableViewController.viewModel.collectionController insertObjects:@[self]];
        NSString *title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Error deleting file \"%@\"", nil, bundle, @"Error deleting file alert view title"), self.name];
        [UIAlertController showAlertWithTitle:title message:error.localizedDescription];
    }];
}

@end
