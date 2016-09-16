//
//  SGMediaCommentPlayerView.m
//  Speed Grader
//
//  Created by Mark Suman on 4/16/11.
//  Copyright 2011 Instructure, Inc. All rights reserved.
//

#import "INAVPlayerView.h"

@implementation INAVPlayerView

+ (Class)layerClass {
    
    return [AVPlayerLayer class];
    
}

- (AVPlayer*)player {
    
    return [(AVPlayerLayer *)[self layer] player];
    
}

- (void)setPlayer:(AVPlayer *)player {
    
    [(AVPlayerLayer *)[self layer] setPlayer:player];
    
}

@end
