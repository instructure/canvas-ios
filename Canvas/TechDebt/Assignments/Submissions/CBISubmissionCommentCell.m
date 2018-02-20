//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "CBISubmissionCommentCell.h"
#import "CBISubmissionCommentViewModel.h"
#import <MediaPlayer/MediaPlayer.h>
@import CanvasKeymaster;
@import CanvasCore;

static NSString *const CBISubmissionCommentCellPlayingNotification = @"CBISubmissionCommentCellPlayingNotification";

@interface CBISubmissionCommentCell ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *myTalkBubbleImageView;

@property (nonatomic) MPMoviePlayerController *mediaPlayer;
@end

@implementation CBISubmissionCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarContainerView.layer.cornerRadius = self.avatarContainerView.bounds.size.width/2.0;
    self.avatarContainerView.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidBeginPlaying:) name:CBISubmissionCommentCellPlayingNotification object:nil];
    
    RAC(self, commentLabel.text) = RACObserve(self, viewModel.model.comment);
    RAC(self, userNameLabel.text) = RACObserve(self, viewModel.model.authorName);
    RACSignal *dateStream = [RACObserve(self, viewModel.date) map:^id(NSDate *date) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        return [dateFormatter stringFromDate:date];
    }];
    RAC(self, dateLabel.text) = dateStream;
    RAC(self, avatarImageView.imageURL) = [RACObserve(self, viewModel.model.avatarPath) map:^id(NSString *path) {
        if (path == nil) {
            return nil;
        }
        return [TheKeymaster.currentClient.baseURL URLByAppendingPathComponent:path];
    }];
    
    RAC(self, tintColor) = RACObserve(self, viewModel.tintColor);
    
    self.avatarContainerView.clipsToBounds = YES;
    self.avatarContainerView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2.f;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor prettyLightGray];
    self.backgroundView = backgroundView;
    
    self.myTalkBubbleImageView.image = [self.myTalkBubbleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.playButton setImage:[[self.playButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startPlayback {
    self.mediaPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.viewModel.model.mediaComment.url];
    self.mediaPlayer.view.frame = self.playButton.frame;
    [self addSubview:self.mediaPlayer.view];
    self.playButton.hidden = YES;
    [self.mediaPlayer play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CBISubmissionCommentCellPlayingNotification object:self];
}

- (IBAction)playMediaComment:(id)sender {
    if (self.mediaPlayer) {
        return;
    }

    [self startPlayback];
}

- (void)stopPlayback {
    [self.mediaPlayer pause];
}

- (void)playerDidBeginPlaying:(NSNotification *)note {
    if (note.object == self) {
        return;
    }

    [self stopPlayback];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stopPlayback];
    [self.mediaPlayer.view removeFromSuperview];
    self.mediaPlayer = nil;
    self.playButton.hidden = NO;
}

- (void)updateFonts {
    self.commentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}
@end
