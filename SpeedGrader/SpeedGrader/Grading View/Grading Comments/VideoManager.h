//
//  VideoManager.h
//  SpeedGrader
//
//  Created by Rick Roberts on 11/11/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoManager : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSURL *videoRecorderFileURL;

- (instancetype)initWithView:(UIView *)view;

- (void)stopVideoRecordingWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void)changeCamera;

- (BOOL)recordVideoComment;
- (void)playVideo;
- (void)pauseVideo;
- (void)deleteAndReset;

- (void)rotateVideoToOrientation:(UIInterfaceOrientation)orientation;
@end
