//
//  CSGSlideMenuViewController.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSlideMenuViewController.h"

#import "CSGCourseViewController.h"
#import "CSGSettingsMenuViewController.h"
#import "CSGSlideMenuViewController.h"

#import "UIView+ImageEffects.h"

static CGFloat const DRAWER_MAX_WIDTH = 347.0f;
static CGFloat const DRAWER_DEFAULT_ANIMATION_DURATION = 0.25f;
static CGFloat const MENU_PAN_VELOCITY_X_THRESHOLD = 200.0f;
static CGFloat const MAX_X_CLOSE_CONSTANT_THRESHOLD = -200.0f;
static CGFloat const MIN_X_OPEN_CONSTANT_THRESHOLD = -100.0f;

static NSString *const TUTORIAL_USER_PREF_KEY = @"tutorial_user_pref";

@interface CSGSlideMenuViewController () <UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic) BOOL animatingDrawer;
@property (nonatomic) BOOL drawerOpen;
@property (nonatomic) CGFloat contraintStartPosition;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint referencePanLocation;

@property (nonatomic, weak) CSGCourseViewController *coursesViewController;
@property (nonatomic, weak) CSGSettingsMenuViewController *settingsMenuViewController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *navMenuLeftConstraint;
@property (nonatomic, weak) IBOutlet UIView *menuContainerView;
@property (nonatomic, weak) IBOutlet UIView *contentContainerView;
@property (nonatomic, strong) UIImageView *menuOverlay;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation CSGSlideMenuViewController

+ (instancetype)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self closeDrawerAnimated:NO completion:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenuVisible:)];
    
    // Set UINavigationBarImage
    UIImage *image = [UIImage imageNamed: @"navigation_bar_image"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = imageView;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    [self setupSegmentedControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor csg_defaultNavigationBarColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)setupSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Favorites", @"All Courses"]];
    UISegmentedControl *segmentedControl = self.segmentedControl;
    [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl sizeToFit];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    [self segmentedControlSelected:self.segmentedControl];
}

- (void)toggleMenuVisible:(UIBarButtonItem *)item
{
    if (self.drawerOpen) {
        DDLogInfo(@"MENU PRESSED - CLOSE DRAWER");
        [self closeDrawerAnimated:YES completion:nil];
    }
    else {
        DDLogInfo(@"MENU PRESSED - OPEN DRAWER");
        [self updateOverlayImage];
        [self openDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - Slide Menu Animation details

-(void)openDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.animatingDrawer) {
        if(completion){
            completion(NO);
        }
        return;
    }
    
    self.coursesViewController.view.userInteractionEnabled = NO;
    [self updateMenuOverlayIfNeeded];
    
    self.animatingDrawer = animated;
    
    self.navMenuLeftConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animated ? DRAWER_DEFAULT_ANIMATION_DURATION : 0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        
        self.menuOverlay.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.animatingDrawer = NO;
        self.drawerOpen = YES;
        if (completion) {
            completion(YES);
        }
    }];
}

- (void)closeMenu:(UITapGestureRecognizer *)gestureRecognizer {
    [self closeDrawerAnimated:YES completion:nil];
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if(self.animatingDrawer){
        if(completion){
            completion(NO);
        }
        return;
    }
 
    self.coursesViewController.view.userInteractionEnabled = YES;
    
    self.animatingDrawer = animated;
    
    self.navMenuLeftConstraint.constant = -DRAWER_MAX_WIDTH;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animated ? DRAWER_DEFAULT_ANIMATION_DURATION : 0.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];

        self.menuOverlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.animatingDrawer = NO;
        self.drawerOpen = NO;
        
        [self.menuOverlay removeFromSuperview];
        if (completion) {
            completion(YES);
        }
    }];
}

#pragma mark - UIViewController Embedding
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embed_courses"]) {
        self.coursesViewController = segue.destinationViewController;
    }
    if ([segue.identifier isEqualToString:@"embed_settings"]) {
        self.settingsMenuViewController = segue.destinationViewController;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint location = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            if(self.animatingDrawer){
                [panGestureRecognizer setEnabled:NO];
                break;
            }
            else {
                self.animatingDrawer = YES;
                self.referencePanLocation = location;
                
                if (!self.drawerOpen) {
                    [self updateOverlayImage];
                    [self updateMenuOverlayIfNeeded];
                }
            }
        }
        case UIGestureRecognizerStateChanged:{
            CGFloat xDelta = location.x - self.referencePanLocation.x;
            CGFloat newConstant = self.navMenuLeftConstraint.constant + xDelta;
            newConstant = newConstant < -DRAWER_MAX_WIDTH ? -DRAWER_MAX_WIDTH : newConstant;
            newConstant = newConstant > 0 ? 0 : newConstant;
            self.referencePanLocation = location;
            
            self.navMenuLeftConstraint.constant = newConstant;
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
            
            self.menuOverlay.alpha = (DRAWER_MAX_WIDTH - fabs(self.navMenuLeftConstraint.constant))/DRAWER_MAX_WIDTH;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            self.animatingDrawer = NO;
            
            CGFloat xVelocity = velocity.x;
            if(xVelocity > MENU_PAN_VELOCITY_X_THRESHOLD){
                [self openDrawerAnimated:YES completion:nil];
            }
            else if(xVelocity < -MENU_PAN_VELOCITY_X_THRESHOLD){
                [self closeDrawerAnimated:YES completion:nil];
            }
            else if(self.navMenuLeftConstraint.constant < MAX_X_CLOSE_CONSTANT_THRESHOLD){
                [self closeDrawerAnimated:YES completion:nil];
            }
            else if(self.navMenuLeftConstraint.constant > MIN_X_OPEN_CONSTANT_THRESHOLD){
                [self openDrawerAnimated:YES completion:nil];
            }
            else {
                [self openDrawerAnimated:YES completion:nil];
            }
            
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            self.animatingDrawer = NO;
            
            [panGestureRecognizer setEnabled:YES];
            break;
        }
        default:
            break;
    }
}

- (void)updateMenuOverlayIfNeeded
{
    if (!self.menuOverlay) {
        self.menuOverlay = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.menuOverlay.image = [self.view blurredDarkSnapshot];
        self.menuOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *tappity = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu:)];
        [self.menuOverlay addGestureRecognizer:tappity];
        [self.menuOverlay setUserInteractionEnabled:YES];
    }
    
    self.menuOverlay.frame = self.view.frame;
    if (![self.menuOverlay superview]) {
        [self.view insertSubview:self.menuOverlay belowSubview:self.menuContainerView];
    }
}

- (void)updateOverlayImage {
    self.menuOverlay.image = [self.view blurredDarkSnapshot];
}

- (void)segmentedControlSelected:(UISegmentedControl *)sender
{
    switch(sender.selectedSegmentIndex) {
        case 0:
            self.coursesViewController.showFavorites = YES;
            break;
        case 1:
            self.coursesViewController.showFavorites = NO;
            break;
        default:
            NSAssert(NO, @"unknown segment selected");
    }
}

@end
