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
    
    

#import "CKUploadProgressToolbar.h"

@implementation CKUploadProgressToolbar {
    
    __weak IBOutlet UIToolbar *progressToolbar;
    __weak IBOutlet UIProgressView *progressView;
    UIBarButtonItem *cancelButton;
    UILabel *progressCompleteLabel;
    UILabel *submittingLabel;
    UIActivityIndicatorView *submittingSpinner;
}

@synthesize uploadCompleteText = _uploadCompleteText;
@synthesize uploadInProgressText = _uploadInProgressText;
@synthesize cancelText = _cancelText;
@synthesize cancelBlock = _cancelBlock;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _uploadCompleteText = @"";
        _uploadInProgressText = @"";
        [self _loadSubviewsFromXib];
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleTopMargin);
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Only accept touches if it will hit a non-hidden subview
    for (UIView *view in self.subviews) {
        CGPoint transformedPoint = [self convertPoint:point toView:view];
        UIView *hitView = [view hitTest:transformedPoint withEvent:event];
        if (hitView) {
            return YES;
        }
    }
    return NO;
}

- (void)_loadSubviewsFromXib {
    UINib *nib = [UINib nibWithNibName:@"CKUploadProgressToolbar" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *topLevelObjects = [nib instantiateWithOwner:self options:nil];
    
    progressToolbar.frame = self.bounds;
    progressToolbar.hidden = YES;
    
    for (UIView *subview in topLevelObjects) {
        [self addSubview:subview];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (progressCompleteLabel == nil) {
        [self _loadLocalizedSubviews];
    }
}

- (void)_loadLocalizedSubviews {
    progressCompleteLabel = [self addProgressViewLabelWithText:self.uploadCompleteText];
    
    submittingLabel = [self addProgressViewLabelWithText:self.uploadInProgressText];
    CGSize fittingSize = [submittingLabel sizeThatFits:submittingLabel.bounds.size];
    CGFloat labelRightEdge = submittingLabel.center.x + (fittingSize.width / 2.0);
    submittingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    submittingSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGFloat width = submittingSpinner.bounds.size.width;
    CGFloat bufferSize = 6;
    submittingSpinner.center = CGPointMake(labelRightEdge + (width / 2.0) + bufferSize, submittingLabel.center.y);
    [progressToolbar addSubview:submittingSpinner];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.subviews.count == 0) {
        self.backgroundColor = [UIColor clearColor];
        [self _loadSubviewsFromXib];
        [self _loadLocalizedSubviews];
    }
}

- (UILabel *)addProgressViewLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:progressToolbar.bounds];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.0;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [progressToolbar addSubview:label];
    return label;
}

- (void)setCancelBlock:(void (^)(void))cancelBlock {
    _cancelBlock = cancelBlock;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSMutableArray *items = [NSMutableArray arrayWithArray:progressToolbar.items];
    UIBarButtonItem *progressButton = items[0];
    if (cancelButton) {
        [items removeObject:cancelButton];
    }
    
    progressToolbar.items = items;
    
    CGRect bounds = progressToolbar.bounds;
    CGFloat spaceBetweenButtons = 10;
    CGFloat edgeSpace = progressView.frame.origin.x;
    
    CGFloat progressWidth = bounds.size.width - edgeSpace - /* the view goes here */ 0 - edgeSpace;
    
    cancelButton = nil;
    UIView *cancelView = nil;
    if (_cancelBlock) {
        cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                     target:self
                                                                     action:@selector(userDidPressCancelButton:)];
        
        [items addObject:cancelButton];
        progressToolbar.items = items;
        
        cancelView = [progressToolbar.subviews lastObject];
        progressWidth -= (spaceBetweenButtons + cancelView.frame.size.width);
    }
    progressButton.customView.frame = CGRectMake(bounds.origin.x, bounds.origin.y, progressWidth, bounds.size.height);
}

///////////////////////////////////
#pragma mark - Public methods
///////////////////////////////////

+ (CGFloat)preferredHeight {
    return 44;
}

- (void)updateProgressViewWithProgress:(float)progress {
    if (progressToolbar.hidden) {
        [self showProgressView];
    }
    [progressView setProgress:progress animated:YES];
}

- (void)showProgressView {
    progressToolbar.hidden = NO;
    progressToolbar.alpha = 0.0;
    [UIView animateWithDuration:0.4 animations:^{
        progressView.alpha = 1.0;
        progressToolbar.alpha = 1.0;
        progressCompleteLabel.alpha = 0.0;
        
        submittingSpinner.alpha = 0.0;
        submittingLabel.alpha = 0.0;
    }];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                    submittingLabel.text);
}

- (void)updateProgressViewWithIndeterminateProgress {
    if (progressToolbar.hidden) {
        progressToolbar.hidden = NO;
        progressToolbar.alpha = 0.0;
    }
    [UIView animateWithDuration:0.4 animations:^{
        progressView.alpha = 0.0;
        progressCompleteLabel.alpha = 0.0;
        
        progressToolbar.alpha = 1.0;
        submittingLabel.alpha = 1.0;
        submittingSpinner.alpha = 1.0;
    }];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                    submittingLabel.text);
    [submittingSpinner startAnimating];
}



- (void)transitionToUploadCompletedWithError:(NSError *)error completion:(dispatch_block_t)completion {
    [self transitionToMessage:self.uploadCompleteText withError:error fadesOut:YES completion:completion];
}

- (void)transitionToMessage:(NSString *)message withError:(NSError *)error fadesOut:(BOOL)fadeOut completion:(dispatch_block_t)completion {
    double messageDisplayTime = 2.0;
    
    UIView *cancelView = nil;
    if (_cancelBlock) {
        cancelView = (UIView *)[progressToolbar.subviews lastObject];
    }
    
    if (error) {
        progressCompleteLabel.text = [error localizedDescription];
        progressCompleteLabel.textColor = [UIColor colorWithHue:1.000 saturation:0.632 brightness:1.000 alpha:1.000];
        messageDisplayTime = 5.0;
    }
    else {
        progressCompleteLabel.text = message;
        progressCompleteLabel.textColor = [UIColor whiteColor];
    }
    [submittingSpinner stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        if (error) {
            progressToolbar.alpha = 1.0; // In case it was previously hidden
        }
        progressView.alpha = 0.0;
        progressCompleteLabel.alpha = 1;
        submittingSpinner.alpha = 0.0;
        submittingLabel.alpha = 0.0;
        cancelView.alpha = 0.0;
    }];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                    progressCompleteLabel.text);
    
    if (fadeOut) {
        [self fadeOutAfterTime:messageDisplayTime completion:completion];
    }
}

- (void)fadeOutAfterTime:(double)messageDisplayTime completion:(dispatch_block_t)completion  {
    UIView *cancelView = nil;
    if (_cancelBlock) {
        cancelView = (UIView *)[progressToolbar.subviews lastObject];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, messageDisplayTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:0.4 animations:^{
            progressToolbar.alpha = 0.0;
        } completion:^(BOOL finished) {
            progressToolbar.hidden = YES;
            progressView.progress = 0.0;
            cancelView.alpha = 1.0;
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)userDidPressCancelButton:(id)sender {
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self cancel];
}

- (void)cancel {
    [self transitionToMessage:_cancelText withError:nil fadesOut:YES completion:nil];
}

- (void)showMessage:(NSString *)message
{
    [self showProgressView];
    [self transitionToMessage:message withError:nil fadesOut:NO completion:nil];
}

- (void)hideMessageWithCompletionBlock:(dispatch_block_t)completionBlock; {
    [self fadeOutAfterTime:0.0 completion:completionBlock];
}


@end
