//
//  ContentLockViewController.m
//  iCanvas
//
//  Created by Jason Larsen on 5/9/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"

#import "ContentLockViewController.h"

#import "Router.h"
#import "Analytics.h"

@interface ContentLockViewController ()
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UIButton *modulesButton;

@property CKContentLock *contentLock;
@property (copy) NSString *lockedItemName;
@property CKContextInfo *contextInfo;
@end

@implementation ContentLockViewController

#pragma mark - View Lifecycle

- (id)initWithContentLock:(CKContentLock *)contentLock itemName:(NSString *)name inContext:(CKContextInfo *)contextInfo {
    ContentLockViewController *vc = [[UIStoryboard storyboardWithName:@"ContentLockViewController" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    vc.contentLock = contentLock;
    vc.lockedItemName = name;
    vc.contextInfo = contextInfo;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.lockedItemName;
    
    [self updateForContentLock];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [Analytics logScreenView:kGAIScreenLockedContent];
 
}


#pragma mark - Content Lock

- (void)updateForContentLock {
    self.explanationLabel.text = [self explanationForContentLock];
    [self hideModulesButtonIfNotPartOfModule];
}

- (NSString *)explanationForContentLock {
    NSString *moduleName = self.contentLock.moduleName;
    NSString *explanation = [NSString stringWithFormat:NSLocalizedString(@"%@ is locked", @"explanation for locked item"), self.lockedItemName];
    
    if (moduleName && [moduleName class] != [NSNull class]) {
        NSString *explanationFormat = NSLocalizedString(@"\"%@\" is locked as part of \"%@\"", @"explanation for locked module item");
        explanation = [NSString stringWithFormat:explanationFormat, self.lockedItemName, moduleName];
    }
    
    if (self.contentLock.unlockDate && [self.contentLock.unlockDate compare:[NSDate date]] == NSOrderedDescending) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        NSString *dateExplanationFormat = NSLocalizedString(@" until %@", @"when locked item will become unlocked");
        NSString *formattedDate = [dateFormatter stringFromDate:self.contentLock.unlockDate];
        NSString *dateExplanation = [NSString stringWithFormat:dateExplanationFormat, formattedDate];
        explanation = [explanation stringByAppendingString:dateExplanation];
    }
    
    explanation = [explanation stringByAppendingString:@"."];
    
    if (moduleName && [moduleName class] != [NSNull class]) {
        NSString *prequisiteExplanation = [self explanationForContentLockPrerequisites];
        if (prequisiteExplanation) {
            explanation = [explanation stringByAppendingString:[self explanationForContentLockPrerequisites]];
        }
    }
    return explanation;
}

- (NSString *)explanationForContentLockPrerequisites {
    __block NSString *explanation;
    NSArray *requirementNames = [self.contentLock prerequisiteNames];
    if (requirementNames.count > 0) {
        explanation = NSLocalizedString(@"\n\nYou must first complete:", @"prerequisites for unlocking item");
        [requirementNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
            explanation = [explanation stringByAppendingFormat:@"\n\t• %@", name];
        }];
    }
    return explanation;
}

- (void)hideModulesButtonIfNotPartOfModule {
    if (!self.contentLock.moduleName || [self.contentLock.moduleName class] == [NSNull class]) {
        self.modulesButton.hidden = YES;
    }
}

#pragma mark - Actions

- (IBAction)viewModulesPressed:(id)sender {
    CKCourse *course = [[CKCourse alloc] initWithID:self.contextInfo.ident];
    NSURL *modulesURL = [course modulesURL];
    Router *router = [Router sharedRouter];
    [router routeFromController:self toURL:modulesURL];
}

#pragma mark - Presentation

- (void)lockViewController:(UIViewController *)viewController {
    self.view.frame = viewController.view.bounds;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    UIView *view = self.view;
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
}

@end
