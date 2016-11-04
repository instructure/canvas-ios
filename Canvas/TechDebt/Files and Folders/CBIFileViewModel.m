
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
    
    

#import "CBIFileViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBISplitViewController.h"
#import "EXTScope.h"
@import CanvasKeymaster;
#import "UIImage+TechDebt.h"

#import "FileViewController.h"

@import SoPretty;

@interface CBIDeleteFileConfirmationAlertView : UIAlertView
@property (nonatomic) MLVCTableViewController *tableViewController;
@property (nonatomic) NSIndexPath *indexPathToDelete;
@end

@implementation CBIDeleteFileConfirmationAlertView
@end

@interface CBIFileViewModel () <UIAlertViewDelegate>
@property (nonatomic) ToastManager *toastManager;
@end

@implementation CBIFileViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.toastManager = [ToastManager new];
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

- (BOOL)tableViewController:(MLVCTableViewController *)controller canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.canEdit;
}

- (void)tableViewController:(MLVCTableViewController *)tableViewController commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableViewController.viewModel.collectionController removeObjectAtIndexPath:indexPath];
    if (tableViewController.cbi_splitViewController.detail.class == [FileViewController class] || self == ((MLVCViewController *)tableViewController.cbi_splitViewController.detail).viewModel) {
        tableViewController.cbi_splitViewController.detail = nil;
    }
    
    RACSignal *deleteSignal = [[CKIClient currentClient] deleteFile:self.model];
    
    [deleteSignal subscribeCompleted:^{
        [self.toastManager statusBarToastSuccess:[NSString stringWithFormat:NSLocalizedString(@"Deleted file: \"%@\"", @"delete file confirmation alert"), self.name]];
    }];
    
    @weakify(self);
    [deleteSignal subscribeError:^(NSError *error) {
        @strongify(self);
        [self.toastManager dismissNotification];
        [tableViewController.viewModel.collectionController insertObjects:@[self]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error deleting file \"%@\"", @"Error deleting file alert view title"), self.name] message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }];
}

@end
