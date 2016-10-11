//
//  CSGAudioPlayer.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 2/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CSGAudioPlayer : UIView

@property (nonatomic, strong) NSURL *audioURL;
@property (copy, nonatomic) NSString *mediaID;
@property (nonatomic, weak) IBOutlet UISlider *seekBar;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *totalLabel;
@property (nonatomic, weak) IBOutlet UILabel *remainingLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loading;

- (void)play;
- (void)pause;
- (IBAction)togglePlayPause;
- (IBAction)seek:(UISlider *)slider;

@end
