//
//  CSGMoviePlayerViewController.m
//  SpeedGrader
//
//  Created by Nathan Lambson on 1/5/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CSGMoviePlayerViewController.h"

@interface CSGMoviePlayerViewController ()

@end

@implementation CSGMoviePlayerViewController

+ (CSGMoviePlayerViewController *)sharedMoviePlayerViewController
{
    static CSGMoviePlayerViewController *_sharedMoviePlayer = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedMoviePlayer = [[CSGMoviePlayerViewController alloc] init];
    });
    
    
    return _sharedMoviePlayer;
}

@end
