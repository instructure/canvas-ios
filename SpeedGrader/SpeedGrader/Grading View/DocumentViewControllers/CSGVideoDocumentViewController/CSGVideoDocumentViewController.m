//
// Created by Jason Larsen on 8/11/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGVideoDocumentViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CSGFileTypes.h"
#import "UIImage+Color.h"
#import "CSGMoviePlayerViewController.h"
#import <CanvasKit/CanvasKit.h>

typedef void (^AnimationBlock)();

@interface CSGVideoDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UIButton *playMediaButton;

@property (nonatomic, strong) MPMoviePlayerController *internalPlayer;
@property (nonatomic) BOOL isTransitioningFullscreen;

@property (nonatomic, strong) NSMutableDictionary *viewConstraintsDictionary;
@property (nonatomic, strong) NSMutableDictionary *aspectConstraintsDictionary;

@property (nonatomic, weak) NSLayoutConstraint *thumbnailAspectRatioConstraint;

@end

@implementation CSGVideoDocumentViewController

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard
{
    CSGVideoDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    if ([self isNotSubmission:submission] || [self isDummySubmission:submission]) {
        return NO;
    }
    
    return [self isAcceptableOnlineUpload:submission attachment:attachment] ||
           [self isAcceptableMediaComment:submission];
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    CSGVideoDocumentViewController *videoDocumentViewController = (CSGVideoDocumentViewController *)[self instantiateFromStoryboard];
    
    videoDocumentViewController.submissionRecord = submissionRecord;
    videoDocumentViewController.submission = submission;
    videoDocumentViewController.attachment = attachment;
    
    return videoDocumentViewController;
}

#pragma mark - Can Handle Submission attachment

+ (BOOL)isNotSubmission:(CKISubmission *)submission
{
    return !submission;
}

+ (BOOL)isDummySubmission:(CKISubmission *)submission
{
    return submission.attempt == 0;
}

+ (BOOL)isAcceptableOnlineUpload:(CKISubmission *)submission attachment:(CKIFile *)attachment
{
    if (submission.type == CKISubmissionEnumTypeOnlineUpload) {
        NSString *fileExtension = attachment.name.pathExtension;
        
        for (NSString *fileType in [self supportedFileTypes]) {
            if (fileType && [fileType compare:fileExtension options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSArray *)supportedFileTypes
{
    return [CSGFileTypes supportedVideoFileTypes];
}

+ (BOOL)isAcceptableMediaComment:(CKISubmission *)submission
{
    return submission.type == CKISubmissionEnumTypeMediaRecording &&
    [submission.mediaComment.mediaType isEqualToString:CKIMediaCommentMediaTypeVideo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusLabel.hidden = YES;
    
    self.viewConstraintsDictionary = [NSMutableDictionary new];
    self.aspectConstraintsDictionary = [NSMutableDictionary new];
    [self setupView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unregisterForMediaPlayerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
    [self registerForMediaPlayerNotifications];
    if ([CSGVideoDocumentViewController isAcceptableMediaComment:self.submission]) {
        NSURL *videoURL = self.submission.mediaComment.url;
        DDLogInfo(@"VIDEO SUBMISSION URL: %@", [videoURL absoluteString]);
        [self setupInternalPlayerWithURL:videoURL];
    } else if ([CSGVideoDocumentViewController isAcceptableOnlineUpload:self.submission attachment:self.attachment]) {
        DDLogInfo(@"VIDEO SUBMISSION URL: %@", [self.attachment.url absoluteString]);
        [self setupInternalPlayerWithURL:self.attachment.url];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unregisterForMediaPlayerNotifications];
    if (!self.isTransitioningFullscreen) {
        [self.internalPlayer stop];
        [self.internalPlayer.view removeFromSuperview];
        self.internalPlayer = nil;
    }
}

#pragma mark -
#pragma mark Published Controls

- (IBAction)play:(UIButton *)button
{
    self.internalPlayer.view.frame = self.playMediaButton.frame;
    self.internalPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addAspectRatioConstraintsToView:self.internalPlayer.view naturalSize:self.thumbnailView.frame.size];
    
    [self animateView:self.internalPlayer.view visible:YES finished:^{
        [self.internalPlayer play];
    }];
}

- (void)setupView
{
    self.thumbnailView = [UIImageView new];
    self.thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // style the thumbnailView
    self.thumbnailView.layer.borderColor = [RGB(143, 144, 143) CGColor];
    self.thumbnailView.layer.borderWidth = 1.0f;
    self.thumbnailView.alpha = 0.0;
    [self.view addSubview:self.thumbnailView];
    
    self.playMediaButton = [UIButton new];
    self.playMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playMediaButton setImage:[UIImage imageNamed:@"large_play_btn"] forState:UIControlStateNormal];
    self.playMediaButton.contentMode = UIViewContentModeCenter;
    self.playMediaButton.alpha = 0.0;
    [self.playMediaButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    // style the thumbnailView
    [self.view addSubview:self.playMediaButton];
}

- (void)setupInternalPlayerWithURL:(NSURL *)url
{
    // Clear out a media file if one is already loaded and/or playing
    if (self.internalPlayer) {
        [self.internalPlayer stop];
        [self.internalPlayer.view removeFromSuperview];
        self.internalPlayer = nil;
    }
    
    // This kicks off the player. It is controlled through notifications.
    self.internalPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.internalPlayer.view.frame = CGRectMake(0, 0, 400, 400);
    self.internalPlayer.controlStyle = MPMovieControlStyleDefault;
    self.internalPlayer.shouldAutoplay = NO;
    [self.internalPlayer prepareToPlay];

    // style the video player
    self.internalPlayer.view.layer.borderColor = [RGB(143, 144, 143) CGColor];
    self.internalPlayer.view.layer.borderWidth = 1.0f;
    self.internalPlayer.view.alpha = 0.0;
    // hide initially.  We'll show it when play is tapped
    [self.view addSubview:self.internalPlayer.view];
}

- (void)registerForMediaPlayerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioOrVideo:)
                                                 name:MPMovieSourceTypeAvailableNotification object:nil];
    
    //    // MPMoviePlayerControl Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMediaPlayer:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeMediaPlayerViews:)
                                                 name:MPMovieNaturalSizeAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerFinishedPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullScreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullScreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterFullScreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullScreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

- (void)unregisterForMediaPlayerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Internal Controls

- (void)willEnterFullScreen:(NSNotification *)note
{
    self.isTransitioningFullscreen = YES;
}

- (void)willExitFullScreen:(NSNotification *)note
{
    self.isTransitioningFullscreen = YES;
}

- (void)didEnterFullScreen:(NSNotification *)note
{
    self.isTransitioningFullscreen = NO;
}

- (void)didExitFullScreen:(NSNotification *)note
{
    self.isTransitioningFullscreen = NO;
}

- (void)thumbnailsLoaded:(NSNotification *)note
{
    UIImage *image = [note.userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    NSError *error = [note.userInfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
    
    // if we have an image set the thumbnail correctly
    if (image) {
        self.thumbnailView.image = image;
    } else if (error) { // if not make the box black
        self.thumbnailView.image = [UIImage imageWithColor:[UIColor blackColor]];
    }
    
    [self animateView:self.thumbnailView visible:YES finished:nil];
    [self animateView:self.playMediaButton visible:YES finished:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
        self.statusLabel.hidden = YES;
    }];
}

- (void)sizeMediaPlayerViews:(NSNotification *)note
{
    // create all views now that we know size/aspectRatio
    [self addAspectRatioConstraintsToView:self.thumbnailView naturalSize:self.internalPlayer.naturalSize];
    [self addAspectRatioConstraintsToView:self.playMediaButton naturalSize:self.internalPlayer.naturalSize];
}

- (void)handleAudioOrVideo:(NSNotification *)note {
    
    BOOL hasVideoTrack = (self.internalPlayer.movieMediaTypes & MPMovieMediaTypeMaskVideo) == MPMovieMediaTypeMaskVideo;
    if (hasVideoTrack) {
        // no need to resize here.  We'll finish sizing the view when the natural size comes back
        // video tracks should be fine handled by the other notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMediaPlayer:)
                                                     name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
        return;
    }
    
    [self addAspectRatioConstraintsToView:self.thumbnailView naturalSize:CGSizeMake(4, 3)];
    [self addAspectRatioConstraintsToView:self.playMediaButton naturalSize:CGSizeMake(4, 3)];
    
    NSError *error = [NSError errorWithDomain:@"CSGVideoFileIsAudioTrackOnly" code:10001 userInfo:nil];
    NSNotification *notification = [NSNotification notificationWithName:@"CSGVideoFileIsAudioTrackOnlyNotification" object:nil userInfo:@{MPMoviePlayerThumbnailErrorKey : error}];
    [self thumbnailsLoaded:notification];
}

- (void)presentMediaPlayer:(NSNotification *)note
{
    // request images once we know the duration
    [self.internalPlayer requestThumbnailImagesAtTimes:@[@(self.internalPlayer.duration/2)] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    // set correct sizing here (should be variable based on aspect ratio
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailsLoaded:)
                                                 name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                               object:self.internalPlayer];
}

- (void)mediaPlayerFinishedPlaying:(NSNotification *)note
{
    //Check for an NSError object in the userInfo dictionary
    if ([[note userInfo] objectForKey:@"error"]) {
        //There was an error loading the movie. This is most likely the caused by the server not being finished rendering the clip.
        self.statusLabel.text = NSLocalizedString(@"The movie could not be played. The server may need to finish processing it.",nil);
        return;
    }
    
    [self.internalPlayer stop];
    [self animateView:self.internalPlayer.view visible:NO finished:nil];
}

- (void)animateView:(UIView *)view visible:(BOOL)visible finished:(AnimationBlock)completion
{
    CGFloat alpha = visible ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        [view setAlpha:alpha];
    } completion:^(BOOL finished) {
        if(completion && finished) {
            completion();
        }
    }];
}

- (void)addAspectRatioConstraintsToView:(UIView *)view naturalSize:(CGSize)naturalSize
{
    NSMutableArray *viewConstraints = [NSMutableArray new];
    NSMutableArray *aspectConstraints = [NSMutableArray new];
    
    [viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[view]-(>=20)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [viewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=20)-[view]-(>=20)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [widthConstraint setPriority:800];
    [viewConstraints addObject:widthConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [heightConstraint setPriority:800];
    [viewConstraints addObject:heightConstraint];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [centerXConstraint setPriority:1000];
    [viewConstraints addObject:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [centerYConstraint setPriority:1000];
    [viewConstraints addObject:centerYConstraint];
    
    [self.view removeConstraints:self.viewConstraintsDictionary[[NSValue valueWithNonretainedObject:view]]];
    [self.view addConstraints:viewConstraints];
    self.viewConstraintsDictionary[[NSValue valueWithNonretainedObject:view]] = viewConstraints;
    
    NSLayoutConstraint *aspect = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:naturalSize.height/naturalSize.width constant:0.0];
    [aspect setPriority:1000];
    [aspectConstraints addObject:aspect];
    
    [view removeConstraints:self.aspectConstraintsDictionary[[NSValue valueWithNonretainedObject:view]]];
    [view addConstraints:aspectConstraints];
    self.aspectConstraintsDictionary[[NSValue valueWithNonretainedObject:view]] = aspectConstraints;
}

@end