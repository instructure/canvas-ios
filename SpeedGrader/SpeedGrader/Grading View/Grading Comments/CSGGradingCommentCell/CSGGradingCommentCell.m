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

#import "CSGGradingCommentCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CSGAudioPlayerSmall.h"
#import "CSGVideoPlayerView.h"
#import "UIImage+Helper.h"
@import CanvasKit;
@import Masonry;

#define kYOrigin 10

@interface CSGGradingCommentCell ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) CSGVideoPlayerView *videoPlayer;
@property (nonatomic, strong) CSGAudioPlayerSmall *audioPlayer;
@property (nonatomic, strong) UIImageView *mediaCommentThumbnailView;
//Adjust View Layout
@end

@implementation CSGGradingCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.commentContainerView.backgroundColor = [UIColor csg_gradingCommentTableBackgroundColor];
    
    CGRect shadowFrame = self.commentContainerView.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.commentContainerView.layer.shadowPath = shadowPath;
    
    self.commentLabel.textColor = [UIColor csg_gradingCommentTextColor];
    self.commentLabel.font = [UIFont systemFontOfSize:13.0f];
    self.dateLabel.textColor = [UIColor csg_gradingCommentDateTextColor];
    self.dateLabel.font = [UIFont systemFontOfSize:11.0f];
    
    self.contentView.backgroundColor = [UIColor csg_gradingCommentTableBackgroundColor];
    
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame)/2;
    self.avatarImageView.clipsToBounds = YES;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMM d, yyyy hh:mma"];

    self.audioPlayer = [CSGAudioPlayerSmall presentInTableViewCell:self];
    
    self.audioPlayer.hidden = YES;
    
    self.mediaCommentThumbnailView = [[UIImageView alloc] init];
    self.mediaCommentThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaCommentThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaCommentThumbnailView.clipsToBounds = YES;
    self.mediaCommentThumbnailView.layer.cornerRadius = 3.0f;
    self.mediaCommentThumbnailView.tintColor = [UIColor whiteColor];
    [self.mediaContainerView addSubview:self.mediaCommentThumbnailView];
    
    self.videoPlayer = [CSGVideoPlayerView instantiateFromXib];
    self.videoPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoPlayer.clipsToBounds = YES;
    self.videoPlayer.layer.cornerRadius = 3.0f;
    self.videoPlayer.tintColor = [UIColor whiteColor];
    [self.mediaContainerView addSubview:self.videoPlayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect shadowFrame = self.commentContainerView.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.commentContainerView.layer.shadowPath = shadowPath;
}

- (void)updateConstraints {
    [super updateConstraints];

    if (self.mediaContainerView) {
        [self.audioPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mediaContainerView);
        }];

        [self.mediaCommentThumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mediaContainerView);
        }];
        
        [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.mediaContainerView);
        }];
    }
}

- (void)setComment:(CKISubmissionComment *)comment {
    _comment = comment;
    
    self.commentLabel.text = comment.comment;

    self.dateLabel.text = [self.dateFormatter stringFromDate:comment.createdAt];
    
    if (comment.avatarPath) {
        NSURL *avatarURL = [[[TheKeymaster currentClient] baseURL] URLByAppendingPathComponent:comment.avatarPath];
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *originalURL = avatarURL;
            NSData *data = nil;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            NSURLResponse *response;
            NSError *error;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSURL *lastURL = [response URL];
            dispatch_async( dispatch_get_main_queue(), ^{
                if ([lastURL.absoluteString containsString:@"images/messages/avatar-50.png"]) {
                    [self.avatarImageView setImage:[UIImage imageNamed:@"icon_student_fill"]];
                } else {
                    [self.avatarImageView setImageWithURL:avatarURL];
                }
            });
        });
    }

    self.audioPlayer.hidden = YES;
    self.videoPlayer.hidden = YES;
    self.mediaCommentThumbnailView.hidden = YES;
    if (self.comment.mediaComment && [self.comment.mediaComment.mediaType isEqualToString:@"video"]) {
        [self.videoPlayer setUrl:comment.mediaComment.url];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyForDisplay:) name:CSGVideoPlayerViewReadyForDisplayNotification object:nil];
    } else if(self.comment.mediaComment && [self.comment.mediaComment.mediaType isEqualToString:@"audio"]) {
        self.audioPlayer.hidden = NO;
        self.audioPlayer.mediaID = self.comment.mediaComment.mediaID;
        self.audioPlayer.audioURL = self.comment.mediaComment.url;
    }
}

#pragma mark - Helper Methods

- (void)videoReadyForDisplay:(NSNotification *)note {
    self.videoPlayer.hidden = NO;
}

@end
