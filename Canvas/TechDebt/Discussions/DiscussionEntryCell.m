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
    
    

#import <QuartzCore/QuartzCore.h>
#import <CanvasKit1/CanvasKit1.h>

#import "DiscussionEntryCell.h"
#import "DiscussionTemplateRenderer.h"
#import "DiscussionChildCountIndicatorView.h"

#import "UIView+Circular.h"
#import "CKCourse.h"

#import "UIWebView+SafeAPIURL.h"
@import SoPretty;
@import CanvasKeymaster;

// uncomment this #define to get some logging data to debug cell loading
#define DEBUG_DISCUSSION_SIZE_CALCULATIONS

#ifdef DEBUG_DISCUSSION_SIZE_CALCULATIONS
#define DebugDiscussionLog(format, args...) NSLog((format), args)
#else
#define DebugDiscussionLog(format, args...) (void)0
#endif

#define W_TO_H_VIDEO_RATIO 0.814545455f

@interface DiscussionEntryCell () <UIWebViewDelegate>

@property (nonatomic, strong) NSTimer *heightCalcTimer;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (assign) BOOL isLikingEntry;

@end

@implementation DiscussionEntryCell {
    __weak IBOutlet UILabel *participantNameLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *deletedEntryLabel;
    __weak IBOutlet UILabel *gradedDiscussionLabel;
    __weak IBOutlet UILabel *repliesHiddenUntilPostLabel;
    __weak IBOutlet UIActivityIndicatorView *loadingCellSpinner;
    
    id _avatarLoadingObserver;
    
    CGRect defaultNameFrame;
    CGFloat paddingHeightAroundWebview;
    
    dispatch_block_t visibilityDurationHandler;
    NSTimer *visibilityTimer;
}
@synthesize avatarView;

- (void)awakeFromNib {
    [super awakeFromNib];
    paddingHeightAroundWebview = self.bounds.size.height - _contentWebView.frame.size.height;
    
    defaultNameFrame = participantNameLabel.frame;
    participantNameLabel.clipsToBounds = NO;
    participantNameLabel.layer.cornerRadius = 3.0;
    
    UIView *backgroundView = [UIView new];
    self.backgroundView = backgroundView;
    [backgroundView setBackgroundColor:[UIColor prettyOffWhite]];
    
    _contentWebView.delegate = self;
    
    deletedEntryLabel.text = NSLocalizedString(@"This entry has been deleted", nil);
    repliesHiddenUntilPostLabel.text = NSLocalizedString(@"Other replies hidden until you reply", @"A message indicating that the user cannot see other people's replies until the user has first posted a reply of their own. Only one line of text, so as concise as possible.");
    
    _showsHighlightOnTouch = YES;
    _contentWebView.scrollView.scrollEnabled = NO;
}

- (void)dealloc {
    _preferredHeightHandler = nil;
    _contentWebView.delegate = nil;
    [_contentWebView stopLoading];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(indentPoints,
                                        self.bounds.origin.y,
                                        self.bounds.size.width - indentPoints, 
                                        self.bounds.size.height);
    CGFloat width = _contentWebView.bounds.size.width;
    NSString *js = [NSString stringWithFormat:@"resizeToWidth(%0.0f);", width];
    [_contentWebView stringByEvaluatingJavaScriptFromString:js];
}

- (void)updateHeader
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.doesRelativeDateFormatting = YES;
    }
    
    participantNameLabel.text = _entry.userName;
    dateLabel.text = [formatter stringFromDate:_entry.createdAt];
    
    if (_entry.discussionTopic.assignment) {
        NSString *formatString = NSLocalizedString(@"Graded discussion. %g points possible.", @"Graded discussion. 25 points possible");
        gradedDiscussionLabel.text = [NSString stringWithFormat:formatString, _entry.discussionTopic.assignment.pointsPossible];
    }
    else if (_entry.discussionTopic.assignmentIdent != 0) {
        gradedDiscussionLabel.text = NSLocalizedString(@"Graded discussion.", @"Lets user know discussion is graded");
    }
    else {
        gradedDiscussionLabel.text = nil;
    }
    
    [self loadAvatarFromEntry:_entry];
    
    [self updateUnreadIndicatorsAnimated:NO];
    
    [self updateLikeView];
}

- (void)resetEntry:(NSTimer *)timer
{
    if (_contentWebView.isLoading == NO && _preferredHeightHandler) {
        _preferredHeightHandler([self calculateHeightOfWebView:self.contentWebView]);
        _preferredHeightHandler = nil;
    }
}

- (void)setTopic:(CKDiscussionTopic *)topic {
    _topic = topic;
    
    if(!topic.allowRating) {
        self.likesView.hidden = YES;
        if([self.reuseIdentifier isEqualToString:@"DiscussionEntryCell"]) {
            CGRect frame = self.contentWebView.frame;
            frame.size.height += 40;
            self.contentWebView.frame = frame;
        }
    }
}

- (void)setEntry:(CKDiscussionEntry *)entry {
    
    _entry = entry;
    
    [self updateHeader];
    
    if (self.preferredHeightHandler) {
        self.heightCalcTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(resetEntry:) userInfo:@{@"entry": entry} repeats:NO];
    }
    
    DiscussionTemplateRenderer *renderer = [[DiscussionTemplateRenderer alloc] init];
    NSString *htmlContent = [renderer htmlStringForThreadedEntry:entry];
    
    [_contentWebView loadHTMLString:htmlContent baseURL:TheKeymaster.currentClient.baseURL];
    DebugDiscussionLog(@"0x%llx loading html", (unsigned long long)self.entry);
    
    if (_contentWebView == nil && _preferredHeightHandler) {
        _preferredHeightHandler(self.bounds.size.height);
        _preferredHeightHandler = nil;
    }

}

- (BOOL)entryContainsEmbeddedLTI {
    return [self.entry.entryMessage containsString:@"iframe"] && [self.entry.entryMessage containsString:@"lti"];
}

- (void)loadAvatarFromEntry:(CKDiscussionEntry *)entry {
    static NSCache *avatarCache = nil;
    if (!avatarCache) {
        avatarCache = [NSCache new];
    }
    
    NSURL *url = entry.userAvatarURL;
    if (!url) {
        url = [[NSBundle bundleForClass:[self class]] URLForResource:@"avatar-default-50" withExtension:@"png"];
    }
    avatarView.imageURL = url;
    avatarView.imageCache = avatarCache;
    
    [avatarView makeViewCircular];
}

- (void)updateUnreadIndicatorsAnimated:(BOOL)animated {
    _childCountIndicator.totalCount = _entry.recursiveReplyCount;
    _childCountIndicator.unreadCount = _entry.recursiveUnreadCount;
    [_childCountIndicator setNeedsDisplay];

    UIColor *destinationColor = nil;
    if (_entry.unread == NO) {
        destinationColor = [UIColor whiteColor];
    }
    else {
        destinationColor = [UIColor colorWithHue:0.6 saturation:0.2 brightness:1.000 alpha:1.000];
    }
    
    if ([_unreadIndicator.backgroundColor isEqual:destinationColor]) {
        return;
    }
    
    if (animated) {
        UIColor *flareColor = [UIColor colorWithHue:0.6 saturation:0.35 brightness:1 alpha:1];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
        animation.values = @[(__bridge id)_unreadIndicator.backgroundColor.CGColor ?: (__bridge id)flareColor.CGColor,
                            (__bridge id)flareColor.CGColor,
                            (__bridge id)destinationColor.CGColor];
        animation.duration = 0.5;
        [_unreadIndicator.layer addAnimation:animation forKey:@"unreadFlare"];
        _unreadIndicator.backgroundColor = destinationColor;
        
    }
    else {
        _unreadIndicator.backgroundColor = destinationColor;
    }
}

-(void)updateLikeView {
    if (self.entry.likeCount > 0) {
        switch (self.entry.likeCount) {
            case 0:
                self.likeLabel.text = @"";
                break;
            case 1:
                self.likeLabel.text = NSLocalizedString(@"1 like", @"Description for a post that has been liked once");
                break;
            default:
                self.likeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ likes", @"Description for how many times a specific discussion has been liked by other users"), @(self.entry.likeCount)];
                break;
        }
    } else {
        self.likeLabel.text = @"";
    }
    
    if(self.entry.isLiked) {
        self.likeButton.tintColor = [UIColor colorWithRed:0/255.0 green:135/255.0 blue:194/255.0 alpha:1.0];
    } else {
        self.likeButton.tintColor = [UIColor blackColor];
    }
    
    if(self.topic.onlyGradersCanRate && ![self userHaveGraderPermissions]) {
        self.likeButton.hidden = YES;
        CGRect frame = self.likeLabel.frame;
        frame.origin.x = self.likeButton.frame.origin.x;
        self.likeLabel.frame = frame;
    }
}

-(BOOL)userHaveGraderPermissions {
    if (self.topic.contextInfo.contextType == CKContextTypeCourse) {
        if ([self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTeacher] ||
            [self.course loggedInUserHasEnrollmentOfType:CKEnrollmentTypeTA]) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)likeButtonPressed:(id)sender {
    [self likeEntry];
}

-(void)likeEntry {
    if(self.isLikingEntry) return;
    
    self.isLikingEntry = true;
    typeof(self) weakSelf = self;
    [self.delegate entryCell:self requestLikeEntry:!self.entry.isLiked completion:^(NSError *error) {
        if(error) {
            weakSelf.likeButton.backgroundColor = [UIColor redColor];
            [UIView animateWithDuration:1.5 animations:^{
                weakSelf.likeButton.backgroundColor = [UIColor clearColor];
            }];
        } else {
            [weakSelf updateLikeView];
        }
        self.isLikingEntry = false;
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        [visibilityTimer invalidate];
        visibilityTimer = nil;
        visibilityDurationHandler = nil;
        [_contentWebView stopLoading];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_contentWebView stopLoading];
    _contentWebView.hidden = YES;
    self.heightCalcTimer = nil;
    _preferredHeightHandler = nil;
    
    [visibilityTimer invalidate];
    visibilityTimer = nil;
    visibilityDurationHandler = nil;
    if (_avatarLoadingObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_avatarLoadingObserver];
        _avatarLoadingObserver = nil;
    }
    
    [loadingCellSpinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DebugDiscussionLog(@"0x%llx finished load", (unsigned long long)self.entry);
    [webView replaceHREFsWithAPISafeURLs];
    _contentWebView.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DebugDiscussionLog(@"0x%llx starting request (%@)", (unsigned long long)self.entry, self.entry.entryMessage);
    if ((navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted) && ![self entryContainsEmbeddedLTI])
    {        
        [self.delegate entryCell:self requestsOpenURL:request.URL];
        return NO;
    }
    
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:@"discussioncell"] && [url.host isEqualToString:@"finishedLoadingImages"]) {

        if (_preferredHeightHandler) {
            _preferredHeightHandler([self calculateHeightOfWebView:webView]);
            _preferredHeightHandler = nil;
            self.heightCalcTimer = nil;
        }

        return NO;
    }
    
    return YES;
}

- (CGFloat)calculateHeightOfWebView:(UIWebView *)webView {
    NSString *heightStr = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entry').scrollHeight"];
    NSString *widthStr = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('entry').scrollWidth"];
    long long numberOfVideoObjects = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video').length"] longLongValue];
    
    CGFloat maxCumulativeVideoHeight = [widthStr floatValue] * W_TO_H_VIDEO_RATIO * numberOfVideoObjects;
    CGFloat cumulativeVideoHeight = 0;
    for (long start = 0; start <= numberOfVideoObjects; start++) {
        NSString *javascriptString = [NSString stringWithFormat:@"document.getElementsByTagName('video')[%li].scrollHeight",start];
        cumulativeVideoHeight += [[webView stringByEvaluatingJavaScriptFromString:javascriptString] floatValue];
    }
    
    CGFloat height = [heightStr floatValue];
    
    //This code adjusts the height for UIWebView unreliably calculating video heights.
    //This is the best I can do without manually calculating all the HTML myself; which would be the worst and not feasible. --nlambson
    if (cumulativeVideoHeight < maxCumulativeVideoHeight){
        height += maxCumulativeVideoHeight - cumulativeVideoHeight;
    }
    
    height = height < maxCumulativeVideoHeight ? maxCumulativeVideoHeight : height;
    
    CGFloat totalHeight = paddingHeightAroundWebview + height;
    return totalHeight;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DebugDiscussionLog(@"err = %@", error);
    if (_preferredHeightHandler) {
        _preferredHeightHandler(paddingHeightAroundWebview);
        _preferredHeightHandler = nil;
        self.heightCalcTimer = nil;
    }
}

+ (NSString *)reuseIdentifierForItem:(CKDiscussionEntry *)entry {
    NSString *identifier;
    if (entry.ident == entry.discussionTopic.ident && [entry.entryMessage isEqualToString:entry.discussionTopic.message])
    {
        identifier = @"DiscussionTopicCell";
    }
    else if ([entry isDeleted]) {
        identifier = @"DiscussionEntryDeletedCell";
    }
    else {
        identifier = @"DiscussionEntryCell";
    }
    return identifier;
}

- (void) whenVisibleForDuration:(NSTimeInterval)timeInterval
                        doBlock:(dispatch_block_t)block
{
    visibilityDurationHandler = [block copy];
    visibilityTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                       target:self
                                                     selector:@selector(_invokeVisibilityHandler:)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)_invokeVisibilityHandler:(NSTimer *)timer {
    if (visibilityDurationHandler) {
        visibilityDurationHandler();
        visibilityDurationHandler = nil;
    }
    [timer invalidate];
    timer = nil;
}

- (void)setHeightCalcTimer:(NSTimer *)heightCalcTimer {
    if (_heightCalcTimer) {
        [_heightCalcTimer invalidate];
    }
    
    if (heightCalcTimer) {
        _heightCalcTimer = heightCalcTimer;
    }
}

@end
