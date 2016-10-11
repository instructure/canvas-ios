//
//  CSGMoviePlayerViewController.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 1/5/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface CSGMoviePlayerViewController : MPMoviePlayerViewController

+ (CSGMoviePlayerViewController *)sharedMoviePlayerViewController;

@end
