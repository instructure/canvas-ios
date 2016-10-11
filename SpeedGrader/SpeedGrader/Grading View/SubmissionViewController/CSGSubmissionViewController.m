//
//  CSGSubmissionViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSubmissionViewController.h"
#import "CSGDocumentViewControllerFactory.h"
#import "CSGAppDataSource.h"
#import "CSGDocumentHandler.h"

@interface CSGSubmissionViewController ()

@property (nonatomic, strong) UIViewController<CSGDocumentHandler> *documentViewController;
@property (nonatomic, strong) CSGAppDataSource *dataSource;

@property (nonatomic, strong) NSString *submissionID;

@end

@implementation CSGSubmissionViewController

+ (instancetype)instantiateFromStoryboard {
    CSGSubmissionViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [CSGAppDataSource sharedInstance];
    
    @weakify(self);
    [RACObserve(self, submissionRecord) subscribeNext:^(id x) {
        @strongify(self);
        if (![self.submissionRecord.id isEqualToString:self.submissionID]) {
            self.submissionID = self.submissionRecord.id;
            [self reloadDocumentView];
        }
    }];
    
    [RACObserve(self, dataSource.selectedSubmissionRecord) subscribeNext:^(id x) {
        @strongify(self);
        if ([self.dataSource.selectedSubmissionRecord.id isEqualToString:self.submissionRecord.id]) {
            self.submissionRecord = self.dataSource.selectedSubmissionRecord;
        }
    }];
    
    RACSignal *observeSelectedSubmission = RACObserve(self, dataSource.selectedSubmission);
    RACSignal *observeSelectedAttachment = RACObserve(self, dataSource.selectedAttachment);
    RACSignal *mergedSignal = [RACSignal merge:@[observeSelectedSubmission, observeSelectedAttachment]];
    [mergedSignal subscribeNext:^(id x) {
        @strongify(self);
        if ([self.dataSource.selectedSubmissionRecord.id isEqualToString:self.submissionRecord.id]) {
            BOOL shouldReloadDocumentView = NO;
            
            if (self.selectedSubmission && self.dataSource.selectedSubmission && ![self.selectedSubmission isEqual:[NSNull null]] && ![self.dataSource.selectedSubmission isEqual:[NSNull null]]) {
                BOOL isSubmissionEqual = [self.selectedSubmission.id isEqualToString:self.dataSource.selectedSubmission.id] && self.selectedSubmission.attempt == self.dataSource.selectedSubmission.attempt;
                if (!isSubmissionEqual) {
                    self.selectedSubmission = self.dataSource.selectedSubmission;
                    shouldReloadDocumentView = YES;
                }
                
                if (![self.selectedAttachment.id isEqualToString:self.dataSource.selectedAttachment.id]) {
                    self.selectedAttachment = self.dataSource.selectedAttachment;
                    shouldReloadDocumentView = YES;
                }
            }
            
            if (shouldReloadDocumentView) {
                [self reloadDocumentView];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDocumentView {
    // remove previous document view
    [self.documentViewController willMoveToParentViewController:nil];
    [self.documentViewController.view removeFromSuperview];

    // create new document view
    self.documentViewController = [CSGDocumentViewControllerFactory createViewControllerForHandlingSubmissionRecord:self.submissionRecord submission:self.selectedSubmission attachment:self.selectedAttachment];
    self.documentViewController.view.frame = self.view.bounds;
    
    // add new document view
    [self addChildViewController:self.documentViewController];
    [self.view addSubview:self.documentViewController.view];
    [self.documentViewController didMoveToParentViewController:self];

    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    UIView *documentView = self.documentViewController.view;
    [documentView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // The jumping was being caused because self.topLayoutGuide adjusts after coming into view, not before, to reflect the difference with the nav bar.
    // Grabing the nav controller's root view and using the amount on that top layout guide works, however it can be nil the first time so we grab the lenght to avoid an exception.
    id<UILayoutSupport> topGuide = ((UIViewController *)self.navigationController.viewControllers.firstObject).topLayoutGuide;
    CGFloat length = topGuide.length;
    id bottomGuide = self.bottomLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(documentView, bottomGuide);
    NSDictionary *metrics = @{
                              @"topPadding":@(length)
                              };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topPadding-[documentView][bottomGuide]" options:0 metrics:metrics views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[documentView]|" options:0 metrics:nil views:viewsDictionary]];
}

#pragma mark - Custom Setters
- (void)setSubmissionRecord:(CKISubmissionRecord *)submissionRecord {
    // don't return if they are equal because we want to set the submissionAttempt either way
    if (_submissionRecord != submissionRecord) {
        _submissionRecord = submissionRecord;
    }
    
    // pick default attempt (attachment will be called as well)
    if (_submissionRecord && ![_submissionRecord isEqual:[NSNull null]]) {
        self.selectedSubmission = [_submissionRecord defaultAttempt];
    }
 
}

- (void)setSelectedSubmission:(CKISubmission *)selectedSubmission {
    // don't return if they are equal because we want to set the attachment either way
    if (_selectedSubmission != selectedSubmission) {
        _selectedSubmission = selectedSubmission;
    }
    
    // pick default attachment
    if (_selectedSubmission && ![_selectedSubmission isEqual:[NSNull null]]) {
        self.selectedAttachment = [_selectedSubmission defaultAttachment];
    }
}

@end
