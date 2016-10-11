//
// Created by Jason Larsen on 7/23/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSidebarViewController.h"

#import "CSGGradingCommentsViewController.h"
#import "CSGGradingRubricViewController.h"
#import "CSGAppDataSource.h"

typedef NS_ENUM(NSInteger, CSGSidebarViewControllerViewMode) {
    CSGSidebarViewControllerViewModeGrade,
    CSGSidebarViewControllerViewModeComments,
};

static NSString *const CSGSidebarViewControllerViewModeGradeTitle = @"Grade";
static NSString *const CSGSidebarViewControllerViewModeCommentsTitle = @"Comments";

@interface CSGSidebarViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *viewModeSegmentedControl;
@property (nonatomic, weak) IBOutlet UILabel *assignmentTitleLabel;

@property (nonatomic, strong) CSGGradingRubricViewController *gradingRubricViewController;
@property (nonatomic, strong) CSGGradingCommentsViewController *gradingCommentsViewController;
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic) CSGSidebarViewControllerViewMode viewMode;

@property (nonatomic, strong) CSGAppDataSource *dataSource;

@end

@implementation CSGSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    [self setupView];
}

#pragma mark - SetupView

- (void)setupView {
    self.view.backgroundColor = [UIColor csg_gradingRailHeaderBackgroundColor];
    self.view.layer.borderColor = [RGB(210, 210, 206) CGColor];
    self.view.layer.borderWidth = 1.0f;
    
    self.assignmentTitleLabel.textColor = [UIColor csg_gradingRailAssignmentNameTextColor];
    
    self.viewModeSegmentedControl.tintColor = [UIColor csg_gradingRailLightSegmentControlColor];
    [self.viewModeSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor csg_gradingRailDarkSegmentControlColor]}
                                                 forState:UIControlStateHighlighted];
    [self.viewModeSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor csg_gradingRailDarkSegmentControlColor]}
                                                 forState:UIControlStateSelected];
    [self.viewModeSegmentedControl setTitle:NSLocalizedString(CSGSidebarViewControllerViewModeGradeTitle, @"Sidebar SegmentedControl Grade Title") forSegmentAtIndex:CSGSidebarViewControllerViewModeGrade];
    [self.viewModeSegmentedControl setTitle:NSLocalizedString(CSGSidebarViewControllerViewModeCommentsTitle, @"Sidebar SegmentedControl Comments Title") forSegmentAtIndex:CSGSidebarViewControllerViewModeComments];
    
    [self setViewMode:CSGSidebarViewControllerViewModeGrade completion:nil];
    
    [self setupRACBindings];
}

- (void)setupRACBindings {
    // the submissionRecord and assignment are passed to us, then we are responsible for passing the submission attempt and submission attachment back

    RAC(self, assignmentTitleLabel.text) = RACObserve(self, dataSource.assignment.name);
}

#pragma mark - UI Actions

- (IBAction)viewModeSegmentValueChanged:(UISegmentedControl *)sender {
    [self setViewMode:sender.selectedSegmentIndex completion:nil];
}

- (void)setViewMode:(CSGSidebarViewControllerViewMode)viewMode completion:(void (^)(BOOL finished))completion {
    self.viewMode = viewMode;
    
    switch (self.viewMode) {
        case CSGSidebarViewControllerViewModeGrade:
            DDLogInfo(@"GRADE SEGMENT PRESSED");
            [self showContentViewController:self.gradingRubricViewController completion:completion];
            break;
        case CSGSidebarViewControllerViewModeComments:
            DDLogInfo(@"COMMENT SEGMENT PRESSED");
            [self showContentViewController:self.gradingCommentsViewController completion:completion];
            break;
            
        default:
            break;
    }
}

- (void)showContentViewController:(UIViewController *)contentViewController completion:(void (^)(BOOL finished))completion{
    if (contentViewController == self.contentViewController) {
        return;
    }
    
    [self hideContentController:_contentViewController];    // Hide the previous content view controller
    self.contentViewController = contentViewController;     // set current contentViewController
    [self displayContentController:contentViewController frame:[self contentFrame]];  // show the current contentViewController
}

- (void)displayContentController:(UIViewController*)content frame:(CGRect)frame {
    [self addChildViewController:content];
    [self.view addSubview:content.view];
    
    UIView *contentView = content.view;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[contentView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(contentView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:NULL views:NSDictionaryOfVariableBindings(contentView)]];
    [self.view layoutIfNeeded];
    
    [content didMoveToParentViewController:self];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (CGRect)contentFrame {
    return CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height - 150);
}

#pragma mark - Lazy Loaders
- (CSGGradingCommentsViewController *)gradingCommentsViewController {
    if (!_gradingCommentsViewController) {
        _gradingCommentsViewController = [CSGGradingCommentsViewController instantiateFromStoryboard];
    }
    return _gradingCommentsViewController;
}

- (CSGGradingRubricViewController *)gradingRubricViewController {
    if (!_gradingRubricViewController) {
        _gradingRubricViewController = [CSGGradingRubricViewController instantiateFromStoryboard];
    }
    return _gradingRubricViewController;
}

@end