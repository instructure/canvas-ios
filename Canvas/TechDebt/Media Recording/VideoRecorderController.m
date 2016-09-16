//
//  VideoRecorderController.m
//  iCanvas
//
//  Created by BJ Homer on 4/24/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "VideoRecorderController.h"
#import "UIViewController+AnalyticsTracking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "iCanvasConstants.h"
#import "Analytics.h"

@interface VideoRecorderController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation VideoRecorderController {
    void (^videoHandler)(NSURL *movieURL);
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)type Handler:(void (^)(NSURL *movieURL))handler {
    self = [super init];
    if (self) {
        videoHandler = handler;
        
        self.delegate = self;
        self.sourceType = type;
        self.mediaTypes = @[(__bridge NSString *) kUTTypeMovie];

    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    videoHandler(info[UIImagePickerControllerMediaURL]);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSLog(@"TRACKING: %@", kGAIScreenVideoRecorder);
    [Analytics logScreenView:kGAIScreenVideoRecorder];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
