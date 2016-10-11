//
// Created by Jason Larsen on 8/11/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CSGAudioPlayerLarge.h"
#import "CSGAudioDocumentViewController.h"
#import "CSGAudioPlaybackManager.h"

#import "CSGFileTypes.h"
#import "CSGAudioPlaybackManager.h"

@interface CSGAudioDocumentViewController ()

@property (nonatomic, strong) CKISubmissionRecord *submissionRecord;
@property (nonatomic, strong) CKISubmission *submission;
@property (nonatomic, strong) CKIFile *attachment;
@property (nonatomic, strong) NSURL *cachedAttachmentURL;

@property (nonatomic, strong) NSArray *supportedFileTypes;
@property (nonatomic, weak) IBOutlet CSGAudioPlayerLarge *myAudioPlayer;

@end

@implementation CSGAudioDocumentViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    DDLogInfo(@"%@ - viewDidLoad", NSStringFromClass([self class]));
    
    if (self.attachment) {
        self.myAudioPlayer = [CSGAudioPlayerLarge presentInViewController:self];
        self.myAudioPlayer.audioURL = self.attachment.url;
        self.myAudioPlayer.mediaID = self.attachment.id;
    } else if (self.submission.mediaComment) {
        self.myAudioPlayer = [CSGAudioPlayerLarge presentInViewController:self];
        self.myAudioPlayer.audioURL = self.submission.mediaComment.url;
        self.myAudioPlayer.mediaID = self.submission.mediaComment.mediaID;
    }
    
    // This document vc doesn't want the panda, and has it's own loading indicator
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentVCFinishedLoading object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DDLogInfo(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopAllPlayback];
    
    self.myAudioPlayer = nil;
}

- (void)stopAllPlayback {
    [self.myAudioPlayer pause];
    [[CSGAudioPlaybackManager sharedManager] pause];
}

#pragma mark - CSGDocumentHandler Protocol
+ (UIViewController *)instantiateFromStoryboard {
    CSGAudioDocumentViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[self class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));

    return instance;
}

+ (BOOL)canHandleSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    if ([submission isEqual:[NSNull null]]) {
        return NO;
    }
    
    if ([self isNotSubmission:submission] || [self isDummySubmission:submission]) {
        return NO;
    }
    
    if ( [self isAudioMediaComment:submission] || [self isAcceptableOnlineUpload:submission attachment:attachment] ) {
        return YES;
    } else {
        return NO;
    }
}

+ (UIViewController *)createWithSubmissionRecord:(CKISubmissionRecord *)submissionRecord submission:(CKISubmission *)submission attachment:(CKIFile *)attachment {
    CSGAudioDocumentViewController *audioDocumentViewController = (CSGAudioDocumentViewController *)[self instantiateFromStoryboard];
    
    audioDocumentViewController.submissionRecord = submissionRecord;
    audioDocumentViewController.submission = submission;
    audioDocumentViewController.attachment = attachment;
    
    return audioDocumentViewController;
}

#pragma mark - Can Handle Submission attachment

+ (BOOL)isNotSubmission:(CKISubmission *)submission {
    return !submission;
}

+ (BOOL)isDummySubmission:(CKISubmission *)submission {
    return submission.attempt == 0;
}

+ (BOOL)isAudioMediaComment:(CKISubmission *)submission {
    return submission.type == CKISubmissionEnumTypeMediaRecording &&
    [submission.mediaComment.contentType containsString:CKIMediaCommentMediaTypeAudio];
}

+ (BOOL)isAcceptableOnlineUpload:(CKISubmission *)submission attachment:(CKIFile *)attachment {
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

+ (NSArray *)supportedFileTypes {
    return @[
             CSGAudioDocumentPathExtensionM4A,
             CSGAudioDocumentPathExtensionMP3,
             CSGAudioDocumentPathExtensionRM
             ];
}

+ (BOOL)URLIsMediaType:(NSURL *)url {
    NSString *uti;
    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    
    for (NSString *supportedUti in [AVURLAsset audiovisualTypes]) {
        if (UTTypeConformsTo((__bridge CFStringRef)(uti), (__bridge CFStringRef)(supportedUti))) {
            return YES;
        }
    }
    
    return NO;
}

@end