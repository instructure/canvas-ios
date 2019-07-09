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

#import <QuartzCore/QuartzCore.h>
#import <CanvasKit1/CanvasKit1.h>
#import "ContentLockViewController.h"
#import "Router.h"

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

    [self.modulesButton setTitle:NSLocalizedStringFromTableInBundle(@"View Modules", nil, [NSBundle bundleForClass:self.class], @"Return to modules from locked module") forState:UIControlStateNormal];
    
    [self updateForContentLock];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - Content Lock

- (void)updateForContentLock {
    self.explanationLabel.text = [self explanationForContentLock];
    [self hideModulesButtonIfNotPartOfModule];
}

- (NSString *)explanationForContentLock {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *moduleName = self.contentLock.moduleName;
    NSString *explanation = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ is locked", nil, bundle, @"explanation for locked item"), self.lockedItemName];
    
    if (moduleName && [moduleName class] != [NSNull class]) {
        NSString *explanationFormat = NSLocalizedStringFromTableInBundle(@"\"%@\" is locked as part of \"%@\"", nil, bundle, @"explanation for locked module item");
        explanation = [NSString stringWithFormat:explanationFormat, self.lockedItemName, moduleName];
    }
    
    if (self.contentLock.unlockDate && [self.contentLock.unlockDate compare:[NSDate date]] == NSOrderedDescending) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        NSString *dateExplanationFormat = NSLocalizedStringFromTableInBundle(@" until %@", nil, bundle, @"when locked item will become unlocked");
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
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        explanation = NSLocalizedStringFromTableInBundle(@"\n\nYou must first complete:", nil, bundle, @"prerequisites for unlocking item");
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
