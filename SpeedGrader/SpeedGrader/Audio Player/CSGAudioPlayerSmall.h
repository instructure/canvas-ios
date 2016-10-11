//
//  CSGAudioPlayer.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 11/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGAudioPlayer.h"

@class CSGAudioPlayerSmall;
@class CSGGradingCommentCell;

@interface CSGAudioPlayerSmall : CSGAudioPlayer

+ (id)presentInTableViewCell:(CSGGradingCommentCell *)tableViewCell;

- (void)preloadMedia;
- (void)pause;

@end
