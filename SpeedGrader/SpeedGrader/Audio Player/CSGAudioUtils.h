//
//  CSGAudioUtils.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 2/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CSGAudioUtils : NSObject

+ (NSInteger)totalAudioTimeInSecondsForPlayer:(AVPlayer *)player;
+ (double)currentPositionForTime:(CMTime)time Player:(AVPlayer *)player;
+ (CMTime)currentTimeForSliderWithPlayer:(AVPlayer *)player SeekBarValue:(float)seekValue;
+ (NSString *)stringFormatForCMTime:(CMTime)time;
+ (NSString *)stringFormatForSeconds:(NSInteger)seconds;
+ (NSString *)verboseStringFormatForSeconds:(NSInteger)seconds;
+ (NSString *)titleForFileWithPlayer:(AVPlayer *)player;

@end
