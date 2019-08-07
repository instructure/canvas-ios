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

#import <CanvasKit1/CanvasKit1.h>
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import <CanvasKit1/NSFileManager+CKAdditions.h>

#import "ProfileViewController.h"

#import "AboutViewController.h"
#import "UIImage+ImageEffects.h"
#import "AFHTTPAvatarImageResponseSerializer.h"

#import <CanvasKeymaster/SupportTicketViewController.h>
#import "CKIClient+CBIClient.h"
#import "CKIUser+SwiftCompatibility.h"
#import "CKCanvasAPI+CurrentAPI.h"
#import "UIAlertController+TechDebt.h"

@import CanvasCore;
@import CanvasKit;
@import CanvasKeymaster;

#ifdef __APPLE__
#import "TargetConditionals.h"
#endif
#import "UIImage+TechDebt.h"

@interface ProfileViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *simulatorMasqueradeButton;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property UITapGestureRecognizer *keyboardDismissalGesture;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarButtonVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageViewVerticalConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerCenterXConstraint;
@property (nonatomic, retain) NSLayoutConstraint *minHeaderHeight;
@property (strong, nonatomic) NSArray *headerMaxHeightConstraints;

@property (strong, nonatomic, nullable) NSURL *gaugeLTIURL;

@end


// TODO: Unify the iPad and iPhone storyboards for profile
@implementation ProfileViewController

- (id)init {
    return [[UIStoryboard storyboardWithName:@"Profile" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

#pragma mark - View Lifecycle

CGFloat square(CGFloat x){return x*x;}

- (void)panned:(UIPanGestureRecognizer*) recognizer {
    [self.view layoutIfNeeded];
    
    CGPoint tranlation = [recognizer translationInView:self.view];
    
    /////////////////////
    // ALPHA CALCULATIONS
    CGFloat distanceToCompleteFade = 150;
    // Use a root to allow easy initial movement, then limited as the further you go
    // Equation of the form a*(y/a)^(1/3)
    CGFloat yDiff = tranlation.y > 0 ? distanceToCompleteFade*pow(tranlation.y/distanceToCompleteFade, 1/3.0) : 0;
    BOOL finished = recognizer.state == UIGestureRecognizerStateEnded;
    CGFloat alpha = (!finished) ? MAX(0, (distanceToCompleteFade-yDiff)/distanceToCompleteFade) : 1.0;

    //////////////////////
    // HEIGHT CALCULATIONS
    NSInteger heightPriority = (!finished) ? 999 : 100;
    CGFloat startHeight = 540.0/1364 * MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat yScale = 2/3.0;
    CGFloat headerHeight = startHeight + yDiff*yScale;
    self.headerHeightContraint.constant = headerHeight;
    self.headerHeightContraint.priority = heightPriority;

    for (NSLayoutConstraint *constraint in self.headerMaxHeightConstraints) {
        constraint.priority = (finished) ? 999 : 100;
    }
    ////////////
    // ANIMATING
    CGFloat animationDuration = finished ? 0.5 : 0;
    [UIView animateKeyframesWithDuration:animationDuration delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *sub in self.view.subviews) {
            if (sub != self.headerImageView) {
                sub.alpha = alpha;
            }
        }
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    Session *session = TheKeymaster.currentClient.authSession;
    
    [session updateBackdropFileFromServer:^(BOOL success) {
        [session backdropPhoto:^(UIImage *backdropPhoto) {
            self.headerImageView.image = backdropPhoto;
        }];
    }];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
    self.navigationController.tabBarItem.selectedImage = [UIImage techDebtImageNamed:@"icon_profile_selected"];
    
    self.canvasAPI = [CKCanvasAPI currentAPI];
    if (! self.user) {
        self.user = self.canvasAPI.user;
    }

    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"v %@ (%@)", bundleInfo[@"CFBundleShortVersionString"], bundleInfo[@"CFBundleVersion"]];
    self.versionLabel.text = versionString;
    
    [self.nameLabel setText:self.user.displayName];
    [self.emailLabel setText:self.user.primaryEmail];
    [self.nameLabel setAlpha:0.0f];
    [self.emailLabel setAlpha:0.0f];
    
    [self.avatarButton setAdjustsImageWhenHighlighted:NO];
    [self.avatarButton setContentMode:UIViewContentModeCenter];
    self.avatarButton.accessibilityIdentifier = @"profile_photo_button";
    self.avatarButton.accessibilityLabel = NSLocalizedStringFromTableInBundle(@"Change Profile Image", nil, [NSBundle bundleForClass:self.class], @"button to change user's profile image");

    [self updateForUser];
    
    UITapGestureRecognizer *chooseCoverPicture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseCoverPhoto)];
    [self.headerImageView addGestureRecognizer:chooseCoverPicture];
    self.headerImageView.userInteractionEnabled = YES;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.headerImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.headerImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.avatarButton setClipsToBounds:YES];
    [self loadAvatar];
    self.headerImageView.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat maxHeightMultiplier = 540.0/1364;
    NSLayoutConstraint *maxOnHeight = [NSLayoutConstraint constraintWithItem:self.headerImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:maxHeightMultiplier constant:0];
    maxOnHeight.priority = 999;
    [self.view addConstraint:maxOnHeight];
    NSLayoutConstraint *maxOnWidth = [NSLayoutConstraint constraintWithItem:self.headerImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:maxHeightMultiplier constant:0];
    maxOnWidth.priority = 999;
    [self.view addConstraint:maxOnWidth];
    self.headerMaxHeightConstraints = @[maxOnWidth, maxOnHeight];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)chooseCoverPhoto {
    @weakify(self);
    BackdropPickerViewController *backdropPicker = [[BackdropPickerViewController alloc] initWithSession:TheKeymaster.currentClient.authSession imageSelected:^(UIImage *selectedImage) {
        @strongify(self);
        self.headerImageView.image = selectedImage;
    }];
    [self.navigationController pushViewController:backdropPicker animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.view layoutIfNeeded];

    [self.avatarButton.layer setCornerRadius:self.avatarButton.frame.size.height/2];

    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-1, -1, (self.avatarButton.frame.size.width + 2), (self.avatarButton.frame.size.height + 2));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setCornerRadius:self.avatarButton.frame.size.height/2];
    [borderLayer setBorderWidth:4.0f];
    [borderLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.avatarButton.layer addSublayer:borderLayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        [self.nameLabel setAlpha:1.0f];
        [self.emailLabel setAlpha:1.0f];
        [self.view layoutIfNeeded];
    }];
}

-(void)setImage:(UIImage *)image {
    self.headerImageView.backgroundColor = [UIColor clearColor];
    [self.loadingIndicator stopAnimating];
    if (!image) image = [UIImage techDebtImageNamed:@"icon_student_fill"];
    if (self.profileImageSelected){
        self.profileImageSelected(image);
    }
        void (^gotPhoto)(UIImage*) = ^void(UIImage *backdropImage) {
            self.headerImageView.image = nil;
            if (!self.minHeaderHeight) {
                self.minHeaderHeight = [NSLayoutConstraint constraintWithItem:self.headerImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90];
                [self.view addConstraint:self.minHeaderHeight];
            }
            if (backdropImage) {
                self.headerImageView.image = backdropImage;
                self.minHeaderHeight.constant = 110;
            } else {
                self.headerImageView.image = [image applyLightEffect];
                self.minHeaderHeight.constant = 90;
            }
        };
        Session *session = [CKIClient currentClient].authSession;
        [session backdropPhoto:gotPhoto];

        [self.avatarButton setImage:image forState:UIControlStateNormal];
        [self.avatarButtonVerticalConstraint setConstant:10.0f];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.avatarButtonVerticalConstraint setConstant:30.0f];
        }
        [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.headerImageViewVerticalConstraint setConstant:0.0f];
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)loadAvatar
{
    [self.loadingIndicator startAnimating];
    SessionUser *user = [CKIClient currentClient].currentUser.swiftUser;
    [user getAvatarImage:^(UIImage * _Nullable image, NSError * _Nullable error) {
        [self setImage:image];
    }];
}

#pragma mark - User

- (void)setUser:(CKUser *)user {
    _user = user;
    [self updateForUser];
}

- (void)updateForUser {
    if (self.canvasAPI.actAsId && ![self.canvasAPI.actAsId isEqualToString:[@(self.user.ident) description]]) {
        [self.canvasAPI getUserProfileWithBlock:^(NSError *error, BOOL isFinalValue) {
            if (!error && isFinalValue) {
                self.user = self.canvasAPI.user;
            }
        }];
        return;
    }
    self.emailLabel.text = self.user.primaryEmail;
    [self.nameLabel setText:self.user.displayName];

    self.title = NSLocalizedStringFromTableInBundle(@"Profile", nil, [NSBundle bundleForClass:self.class], @"Title for profile screen");
    BOOL isPersonalProfile = [self isPersonalProfile];
    self.avatarButton.enabled = isPersonalProfile;
}

- (BOOL)isPersonalProfile {
    return self.user.ident == self.canvasAPI.user.ident;
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.keyboardDismissalGesture != gestureRecognizer ||
    [self.nameLabel isFirstResponder] ||
    [self.emailLabel isFirstResponder];
}

#pragma mark - Profile image setting

- (IBAction)pickAvatar:(id)sender
{
    [self.loadingIndicator startAnimating];
    __weak ProfileViewController *weakSelf = self;
    RACSignal *getUser = [[CKIClient currentClient] fetchResponseAtPath:@"api/v1/users/self" parameters:nil modelClass:[CKIUser class] context:nil];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    [getUser subscribeNext:^(CKIUser *user) {
        NSNumber *permission = user.permissions[@"can_update_avatar"];
        if ([permission isKindOfClass:[NSNumber class]] && [permission boolValue]) {
            [weakSelf showAvatarOptions:sender];
        } else {
            NSString *title = NSLocalizedStringFromTableInBundle(@"Permission Denied", nil, bundle, nil);
            NSString *message = NSLocalizedStringFromTableInBundle(@"You are not allowed to change your avatar at this time.", nil, bundle, nil);
            [UIAlertController showAlertWithTitle:title message:message];
        }
    } error:^(NSError * _Nullable error) {
        NSString *title = NSLocalizedStringFromTableInBundle(@"Network Error", nil, bundle, nil);
        NSString *message = NSLocalizedStringFromTableInBundle(@"Something went wrong. Please try again.", nil, bundle, nil);
        [UIAlertController showAlertWithTitle:title message:message];
    } completed:^{
        [weakSelf.loadingIndicator stopAnimating];
    }];
}

- (void)showAvatarOptions:(id)sender
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    UIButton *avatarButton = (UIButton *)sender;
    CKActionSheetWithBlocks *actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Choose Profile Picture", nil, bundle, nil)];
    
    __weak __typeof(&*self)weakSelf = self;
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Build Avatar", nil, bundle, @"Link to building panda avatar") handler:^{
        PandatarBuilderViewController *pandatarBuilderViewController = [[PandatarBuilderViewController alloc] init];
        __weak PandatarBuilderViewController *pandatarBuilder = pandatarBuilderViewController;
      pandatarBuilderViewController.doneBuilding = ^(UIImage *tehPandatar) {
            [self imagePicker:nil pickedImage:tehPandatar];
            [pandatarBuilder dismissViewControllerAnimated:YES completion:nil];
        };
        pandatarBuilderViewController.canceledBuilding = ^{
            [pandatarBuilder dismissViewControllerAnimated:YES completion:nil];
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: pandatarBuilderViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [weakSelf presentViewController:navController animated:YES completion:nil];
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Take Photo", nil, bundle, @"Button label for taking a photo") handler:^{
            UIImagePickerController *imagePicker = [UIImagePickerController new];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker animated:YES completion:^{
                nil;
            }];
        }];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Choose Photo", nil, bundle, @"Button label for choosing a photo") handler:^{
            UIImagePickerController *imagePicker = [UIImagePickerController new];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.allowsEditing = YES;
            imagePicker.modalPresentationStyle = UIModalPresentationPopover;
            imagePicker.popoverPresentationController.sourceView = avatarButton;
            imagePicker.popoverPresentationController.sourceRect = avatarButton.bounds;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Add Cover Photo", nil, bundle, nil) handler:^{
        [self chooseCoverPhoto];
    }];
    [actionSheet addCancelButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, bundle, nil)];
    if (self.tabBarController) {
        actionSheet.modalPresentationStyle = UIModalPresentationPopover;
        actionSheet.popoverPresentationController.sourceView = self.tabBarController.tabBar;
        actionSheet.popoverPresentationController.sourceRect = self.tabBarController.tabBar.bounds;
    }
    [actionSheet showfromViewController:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSLog(@"Image Selected");
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self imagePicker:picker pickedImage:image];
    }];
}

- (void)imagePicker:(UIImagePickerController *)imagePicker pickedImage:(UIImage *)image {
    NSURL *imageFileURL = [self saveImageToFile:image];
    
    self.avatarButton.highlighted = YES;
    
    UIActivityIndicatorView *activityIndicator = [UIActivityIndicatorView new];
    CGFloat x = CGRectGetMidX(self.avatarButton.bounds) - (activityIndicator.frame.size.width / 2.0f);
    CGFloat y = CGRectGetMidY(self.avatarButton.bounds) - (activityIndicator.frame.size.height / 2.0f);
    activityIndicator.frame = CGRectMake(x, y, activityIndicator.frame.size.width , activityIndicator.frame.size.height);
    [self.avatarButton addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    __weak CKCanvasAPI *weakAPI = self.canvasAPI;
    __weak ProfileViewController *weakSelf = self;
    [self.canvasAPI postAvatarNamed:nil fileURL:imageFileURL block:^(NSError *error, BOOL isFinalValue, CKAttachment *attachment) {
        if (isFinalValue) {
            if (error) {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                weakSelf.avatarButton.highlighted = NO;
                [weakSelf showUploadAvatarError];
                return;
            }

            [weakSelf setImage:image];
            weakSelf.canvasAPI.user.avatarURL = attachment.directDownloadURL;
            [weakAPI getFileWithId:attachment.ident block:^(NSError *error, BOOL isFinalValue, CKAttachment *file) {
                if (file.avatarToken) {
                    [weakAPI updateLoggedInUserAvatarWithToken:file.avatarToken block:^(NSError *error, BOOL isFinalValue, NSDictionary *dictionary) {
                        if (error) {
                            [weakSelf showUploadAvatarError];
                        }
                    }];
                } else {
                    [weakSelf showUploadAvatarError];
                }

                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                weakSelf.avatarButton.highlighted = NO;
            }];
        }
    }];
}

- (void)showUploadAvatarError
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *title = NSLocalizedStringFromTableInBundle(@"Error", nil, bundle, nil);
    NSString *message = NSLocalizedStringFromTableInBundle(@"Unable to upload to server", nil, bundle, nil);
    [UIAlertController showAlertWithTitle:title message:message];

}

- (NSURL *)saveImageToFile:(UIImage *)image {
    NSURL *fileURL = nil;
    
    CGFloat compression = 0.3f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 40*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    // Save the image to the filesystem    
    NSFileManager *fileManager = [NSFileManager new];
    NSURL *uniqueSaveURL = [fileManager uniqueFileURLWithURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"profilePic.jpg"]]];
    
    BOOL result = [imageData writeToURL:uniqueSaveURL atomically:YES];
    if (!result) {
        NSLog(@"Saving the file failed. We should use some default image instead");
    } else {
        fileURL = uniqueSaveURL;
    }
    
    return fileURL;
}

@end
