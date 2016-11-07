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

#import "CSGStudentPickerViewController.h"

#import "CSGAppDataSource.h"
#import "CSGStudentPickerTableViewController.h"
#import "CSGCourseSectionsTableViewController.h"
#import "CSGSectionPickView.h"
#import "UIColor+CSGColor.h"

static CGFloat const CSGStudentPickerPreferredContentWidth = 480.0f;
static CGFloat const CSGStudentPickerPreferredContentHeight = 480.0f;

static CGFloat const CSGGradingSectionMaxWidth = 300.0f;
static CGFloat const CSGGradingSectionMinWidth = 100.0f;
static CGFloat const CSGGradingSectionHeight = 34.0f;

static NSTimeInterval const CSGStudentPickerViewSectionAnimationDuration = 0.45f;
static CGFloat const CSGStudentPickerViewSectionTopConstraintShowingValue = -44.0f;
static CGFloat const CSGStudentPickerViewSectionTopConstraintHiddenValue = CSGStudentPickerPreferredContentHeight + 44;
static CGFloat const CSGStudentPickerSortSegmentWidth = 150.0f;

@interface CSGStudentPickerViewController ()

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sectionsTopConstraint;

@property (nonatomic, strong) CSGStudentPickerTableViewController *studentTableViewController;
@property (nonatomic, strong) CSGCourseSectionsTableViewController *sectionsTableViewController;

@property (nonatomic, strong) RACSubject *submissionRecordPickedSubject;

@property (nonatomic, strong) UITapGestureRecognizer *tapSectionPicker;

@property (nonatomic, strong) UIView *sectionsPickerView;
@property (nonatomic, strong) UISegmentedControl *sortSegmentControl;
@property (nonatomic, strong) CSGSectionPickView *sectionPickerView;

@property (nonatomic) BOOL isSectionPickerVisible;

@end

@implementation CSGStudentPickerViewController

+ (instancetype)instantiateFromStoryboard {
    CSGStudentPickerViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    self.preferredContentSize = CGSizeMake(CSGStudentPickerPreferredContentWidth, CSGStudentPickerPreferredContentHeight);
    
    [self setupSegmentControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    self.studentTableViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupSectionPicker];
}

- (void)setupSegmentControl {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsHideNames]]) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    self.sortSegmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Name", @"Student picker name sort control string"), NSLocalizedString(@"Grade", @"Student picker grade sort control string")]];
    self.sortSegmentControl.frame = CGRectMake(0, 0, CSGStudentPickerSortSegmentWidth, self.sortSegmentControl.frame.size.height);
    self.sortSegmentControl.tintColor = [UIColor csg_studentPickerHeaderTintColor];
    [self.sortSegmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(129, 129, 130)}
                                           forState:UIControlStateHighlighted];
    [self.sortSegmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB(129, 129, 130)}
                                           forState:UIControlStateSelected];
    [self.sortSegmentControl setTitle:NSLocalizedString(@"Name", @"Student picker name sort control string") forSegmentAtIndex:CSGStudentSortOrderAlphabetical];
    [self.sortSegmentControl setTitle:NSLocalizedString(@"Grade", @"Student picker grade sort control string") forSegmentAtIndex:CSGStudentSortOrderGrade];
    [self.sortSegmentControl addTarget:self action:@selector(sortSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortSegmentControl];
    
    // set initial sortOrder
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[CSGUserPrefsKeys userSpecificPrefWithKey:CSGUserPrefsShowUngradedFirst]]) {
        self.sortSegmentControl.selectedSegmentIndex = CSGStudentSortOrderGrade;
    } else {
        self.sortSegmentControl.selectedSegmentIndex = CSGStudentSortOrderAlphabetical;
    }
}

- (void)setupSectionPicker {
    self.sectionPickerView = [CSGSectionPickView instantiateFromXib];
    
    self.tapSectionPicker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSectionPressed:)];
    [self.sectionPickerView addGestureRecognizer:self.tapSectionPicker];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sectionPickerView];
    
    if (self.dataSource.section) {
        [self setupSectionBarButtonItemWithTitle:self.dataSource.section.name];
    } else {
        [self setupSectionBarButtonItemWithTitle:NSLocalizedString(@"All Sections", nil)];
    }
    [self animateSectionPickerShowing:NO animated:NO];
}

- (void)setupSectionBarButtonItemWithTitle:(NSString *)title {
    if (!title) {
        return;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18.0f]};
    CGSize titleRect = [title sizeWithAttributes:attributes];
    CGFloat width = titleRect.width < CSGGradingSectionMaxWidth ? titleRect.width : CSGGradingSectionMaxWidth;
    width = width >= CSGGradingSectionMinWidth ? width : CSGGradingSectionMinWidth;
    CGFloat padding = 20;
    
    UIButton *sectionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width + padding, CSGGradingSectionHeight)];
    [sectionButton addTarget:self action:@selector(selectSectionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sectionButton setBackgroundColor:[UIColor csg_tappableButtonBackgroundColor]];
    [sectionButton.layer setMasksToBounds:YES];
    [sectionButton.layer setCornerRadius:10.0f];
    [sectionButton setTitle:title forState:UIControlStateNormal];
    sectionButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sectionButton];
}

#pragma mark - UIViewController Embedding
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embed_students"]) {
        self.studentTableViewController = segue.destinationViewController;
        [self.studentTableViewController.submissionRecordPickedSignal subscribeNext:^(id x) {
            [self.submissionRecordPickedSubject sendNext:x];
        }];
    } else if ([segue.identifier isEqualToString:@"embed_sections"]) {
        self.sectionsTableViewController = segue.destinationViewController;
        
        @weakify(self);
        [RACObserve(self, dataSource.section) subscribeNext:^(CKISection *section) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                // update the label
                if (section) {
                    [self setupSectionBarButtonItemWithTitle:self.dataSource.section.name];
                } else {
                    [self setupSectionBarButtonItemWithTitle:NSLocalizedString(@"All Sections", nil)];
                }
                
                [self animateSectionPickerShowing:NO animated:YES];
            });
        }];
    }
}

- (IBAction)sortSegmentControlValueChanged:(UISegmentedControl *)sender {
    DDLogInfo(@"SORT STUDENTS PRESSED INDEX: %ld", (long)sender.selectedSegmentIndex);
    
    // set sortMode correctly
    @weakify(self);
    [self.dataSource setStudentSortOrder:sender.selectedSegmentIndex success:^{
        @strongify(self);
        [self.studentTableViewController.tableView reloadData];
    }];
}

- (void)selectSectionPressed:(UITapGestureRecognizer *)tapRecognizer {
    DDLogInfo(@"SELECT SECTION PRESSED");
    [self animateSectionPickerShowing:!self.isSectionPickerVisible animated:YES];
}

- (void)animateSectionPickerShowing:(BOOL)visible animated:(BOOL)animated {
    NSTimeInterval animationDuration = animated ? CSGStudentPickerViewSectionAnimationDuration : 0.0f;
    
    [self.sectionsTableViewController.tableView reloadData];
    self.tapSectionPicker.enabled = NO;
    self.sectionsTopConstraint.constant = visible ? CSGStudentPickerViewSectionTopConstraintShowingValue : CSGStudentPickerViewSectionTopConstraintHiddenValue;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.tapSectionPicker.enabled = YES;
        self.isSectionPickerVisible = visible;
    }];
}

#pragma mark - RAC

- (RACSubject *)submissionRecordPickedSubject {
    if (!_submissionRecordPickedSubject) {
        _submissionRecordPickedSubject = [RACSubject subject];
    }
    return _submissionRecordPickedSubject;
}

- (RACSignal *)submissionRecordPickedSignal {
    return self.submissionRecordPickedSubject;
}

@end
