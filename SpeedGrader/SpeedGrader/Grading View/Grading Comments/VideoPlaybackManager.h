//
//  VideoPlaybackManager.h
//  SpeedGrader
//
//  Created by Rick Roberts on 11/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlayerView.h"

@interface VideoPlaybackManager : NSObject
@property (nonatomic, strong) NSURL *sourceURL;
@property (nonatomic, retain) VideoPlayerView *playerView;
@end
