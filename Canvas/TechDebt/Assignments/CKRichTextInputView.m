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
    
    

#import "CKRichTextInputView.h"
#import "UIWebView+AccessoryHiding.h"
#import "CKActionSheetWithBlocks.h"
#import "CKAudioCommentRecorderView.h"
#import "CKEmbeddedMediaAttachment.h"
#import "CKAttachmentManager.h"
#import "CKURLPreviewViewController.h"
#import "NSArray+CKAdditions.h"
#import "NSString+CKAdditions.h"
#import "CKRemoteImageView.h"

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+TechDebt.h"

UIColor *CKPostButtonEnabledColor() {
    return [UIColor colorWithRed:255.0f/255.0f green:56.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
}

UIColor *CKPostButtonDisabledColor() {
    return [UIColor grayColor];
}

@interface CKRichTextInputView () <UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CKAttachmentManagerDelegate> {
    NSMutableDictionary *loadingImages;
}

@property (strong, nonatomic) IBOutlet UIImageView *webViewContainer;
@property (strong, nonatomic) IBOutlet UIButton *addAttachmentButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong, nonatomic) CKAudioCommentRecorderView *audioRecorderView;

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation CKRichTextInputView

@synthesize minimumHeight, maximumHeight;
@synthesize delegate;
@synthesize backgroundImageView;
@synthesize webView, webViewContainer;
@synthesize addAttachmentButton;
@synthesize sendButton;
@synthesize topLevelView;
@synthesize entry;
@synthesize imagePicker;
@synthesize popoverController;
@synthesize audioRecorderView;
@synthesize attachmentManager;
@synthesize showPostButton;
@synthesize showsAttachmentButton;
@synthesize initialText;
@synthesize finishedLoadingWebViewBlock;
@synthesize imageCache;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)loadNib
{
    [[NSBundle bundleForClass:[self class]] loadNibNamed:@"CKRichTextInputView" owner:self options:nil];
}

- (void)setup
{
    [self loadNib];
    
    [self.webView setIsAccessibilityElement:YES];
    self.webView.accessibilityLabel = NSLocalizedString(@"Add comment", nil);
    [self.sendButton setIsAccessibilityElement:YES];
    self.sendButton.accessibilityLabel = NSLocalizedString(@"Post comment", nil);
    [self.sendButton setTitle:NSLocalizedString(@"Post", nil) forState:UIControlStateNormal];
    [self.addAttachmentButton setIsAccessibilityElement:YES];
    self.addAttachmentButton.accessibilityLabel = NSLocalizedString(@"Add attachment", nil);
    [self.webView setKeyboardDisplayRequiresUserAction:NO];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.topLevelView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImage *backgroundImage = [[UIImage techDebtImageNamed:@"course-detail-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)];
    self.backgroundImageView.image = backgroundImage;
    
    [self addSubview:self.topLevelView];
    
    UIImage *webViewContainerBackground = [[UIImage techDebtImageNamed:@"textfield-background~iphone"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)];
    self.webViewContainer.image = webViewContainerBackground;
    
    self.placeholderLabel.frame = CGRectMake(12.0, 9.0, self.webViewContainer.frame.size.width, self.placeholderLabel.frame.size.height);
    
    self.webView.delegate = self;
    NSURL *templateURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"ExpandingComment"
                                                 withExtension:@"html"];
    NSString *commentTemplate = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:commentTemplate baseURL:[[NSBundle bundleForClass:[self class]] resourceURL]];
    self.webView.hackishlyHidesInputAccessoryView = YES;
    
    self.webViewContainer.layer.cornerRadius = 12;
    self.webViewContainer.clipsToBounds = YES;
    self.clipsToBounds = YES;
    for(UIView *wview in [[self.webView subviews][0] subviews]) { 
        if([wview isKindOfClass:[UIImageView class]]) { wview.hidden = YES; } 
    }
    
    self.minimumHeight = 42.0;
    self.maximumHeight = 130.0;

    [self.sendButton setTitleColor:CKPostButtonDisabledColor() forState:UIControlStateDisabled];
    [self.sendButton setTitleColor:CKPostButtonEnabledColor() forState:UIControlStateNormal];
    self.sendButton.enabled = NO;

    self.addAttachmentButton.tintColor = CKPostButtonEnabledColor();

    self.attachmentManager = [CKAttachmentManager new];
    self.attachmentManager.delegate = self;
    self.attachmentManager.shouldApplyOverlaysToThumbs = YES;
    
    showPostButton = YES;
    
    self.imageCache = [[NSCache alloc] init];
    loadingImages = [NSMutableDictionary new];
    
    self.placeholderLabel.text = _placeholderText;
}

- (CKAllowedAttachmentType)allowedAttachmentTypes
{
    return self.attachmentManager.allowedAttachmentTypes;
}

- (void)setAllowedAttachmentTypes:(CKAllowedAttachmentType)theAllowedAttachmentTypes
{
    self.attachmentManager.allowedAttachmentTypes = theAllowedAttachmentTypes;
    
    if (theAllowedAttachmentTypes == CKAllowNoAttachments) {
        self.showsAttachmentButton = NO;
    } else {
        self.showsAttachmentButton = YES;
    }

}

- (void)setShowsAttachmentButton:(BOOL)show
{
    if (show == YES) {
        [self showAttachmentButton];
    }
    else {
        [self hideAttachmentButton];
    }
}

- (void)hideAttachmentButton
{
    if (self.addAttachmentButton.hidden)
        return; // Nothing to do
    
    CGFloat widthDifference = self.addAttachmentButton.frame.size.width + 6.0;
    
    CGRect inputContainerFrame = self.webViewContainer.frame;
    CGRect inputFrame = self.webView.frame;
    inputContainerFrame.size.width += widthDifference;
    inputFrame.size.width += widthDifference;
    inputFrame.origin.x -= widthDifference;
    inputContainerFrame.origin.x -= widthDifference;
    self.webViewContainer.frame = inputContainerFrame;
    self.webView.frame = inputFrame;
    
    self.addAttachmentButton.hidden = YES;
    self.addAttachmentButton.enabled = NO;
}

- (void)showAttachmentButton
{
    if (!self.addAttachmentButton.hidden)
        return; // Nothing to do
    
    CGFloat widthDifference = self.addAttachmentButton.frame.size.width + 6.0;
    
    CGRect inputContainerFrame = self.webViewContainer.frame;
    CGRect inputFrame = self.webView.frame;
    inputContainerFrame.size.width -= widthDifference;
    inputFrame.size.width -= widthDifference;
    inputContainerFrame.origin.x += widthDifference;
    inputFrame.origin.x += widthDifference;
    self.webViewContainer.frame = inputContainerFrame;
    self.webView.frame = inputFrame;
    
    self.addAttachmentButton.hidden = NO;
    self.addAttachmentButton.enabled = YES;
}

- (void)setShowPostButton:(BOOL)_showPostButton {
    if (_showPostButton == showPostButton) {
        return;
    }
    
    CGFloat widthDifference = self.sendButton.frame.size.width + 6.0;
    
    if (!_showPostButton) {
        
        CGRect inputContainerFrame = self.webViewContainer.frame;
        CGRect inputFrame = self.webView.frame;
        inputContainerFrame.size.width += widthDifference;
        inputFrame.size.width += widthDifference;
        self.webViewContainer.frame = inputContainerFrame;
        self.webView.frame = inputFrame;
        
        self.sendButton.hidden = YES;
        self.sendButton.enabled = NO;
        self.sendButton.layer.borderColor = CKPostButtonDisabledColor().CGColor;
    } else if (_showPostButton) {
        
        CGRect inputContainerFrame = self.webViewContainer.frame;
        CGRect inputFrame = self.webView.frame;
        inputContainerFrame.size.width -= widthDifference;
        inputFrame.size.width -= widthDifference;
        self.webViewContainer.frame = inputContainerFrame;
        self.webView.frame = inputFrame;
        
        self.sendButton.hidden = NO;
        self.sendButton.enabled = YES;
        self.sendButton.layer.borderColor = CKPostButtonEnabledColor().CGColor;
    }

    showPostButton = _showPostButton;
}

- (void)dismissKeyboard
{
    [self.webView endEditing:YES];
}

- (BOOL)hasContent
{
    return (![self isEmpty] || [[self attachments] count] > 0);
}

- (NSUInteger)addImage:(NSString *)pathToImage ofHeight:(CGFloat)height {
    
    [self.webView endEditing:YES];
    NSUInteger imageId = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"insertImage('%@', %f);", pathToImage, height]] intValue];
    [self resize];
    
    return imageId;
}

- (NSUInteger)replaceImageTag:(NSString *)imageTag withImageAtPath:(NSString *)pathToImage ofHeight:(CGFloat)height {
    NSString *js = [NSString stringWithFormat:@"insertImageReplacingImage('%@', '%@', %f);", pathToImage, imageTag, height];
    return [[self.webView stringByEvaluatingJavaScriptFromString:js] intValue];
}

- (void)clearContents {
    [self.webView stringByEvaluatingJavaScriptFromString:@"$('#comment').html('<br>');"];
    self.placeholderLabel.hidden = NO;
}

- (void)resize {
    
    CGFloat documentHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"$('#comment').css('min-height', '0').height();"] floatValue];
    [self.webView stringByEvaluatingJavaScriptFromString:@"$('#comment').css('min-height', '100%');"];
    
    documentHeight += 16;
    
    if (documentHeight < self.minimumHeight) {
        documentHeight = self.minimumHeight;
    } else if (documentHeight > self.maximumHeight) {
        documentHeight = self.maximumHeight;
    }
    
    [self.delegate resizeRichTextInputViewToHeight:documentHeight];
}

- (NSString *)initialText
{
    return [self grabText];
}

- (void)setInitialText:(NSString *)someText
{
    someText = [someText stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    someText = [someText stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    someText = [someText stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    someText = [someText stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    someText = [someText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *js = [NSString stringWithFormat:@"setInitialText('%@');", someText];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (NSString *)replaceImagesWithThumbnailsInHTML:(NSString *)html
{
    NSString *htmlLowercase = [html lowercaseString];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*src=\"(\\S+)\"[^>]*>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block NSString *returnValue = html;
    __block int activityIndicatorCount = 1;
    [regex enumerateMatchesInString:htmlLowercase options:0 range:NSMakeRange(0, [htmlLowercase length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange imageTagRange = [match range];
        NSString *imageTag = [html substringWithRange:imageTagRange];
        
        NSRange srcRange = [match rangeAtIndex:1];
        NSString *srcUrlString = [html substringWithRange:srcRange];
        NSURL *srcUrl = [NSURL URLWithString:srcUrlString];
        
        NSString *activityGif = [[NSBundle bundleForClass:[self class]] pathForResource:@"glossy-spinner" ofType:@"gif"];
        NSString *activityImageTag = [NSString stringWithFormat:@"<img id=\"activity-indicator%d\" src=\"%@\">", activityIndicatorCount, activityGif];
        activityIndicatorCount++;
        loadingImages[activityImageTag] = imageTag;
        
        returnValue = [returnValue stringByReplacingOccurrencesOfString:imageTag withString:activityImageTag];
        
        CKRemoteImageView *imageView = [CKRemoteImageView new];
        imageView.imageCache = imageCache;
        __weak CKRemoteImageView *weakImageView = imageView;
        imageView.afterLoadingBlock = ^{
            UIImage *image = weakImageView.image;
            // create a glossy thumbnail only for the images that need it and not for images like equations
            if (image.size.height > 100) {
                CKEmbeddedMediaAttachment *mediaAttachment = [CKEmbeddedMediaAttachment new];
                mediaAttachment.image = image;
                mediaAttachment.type = CKAttachmentMediaTypeImage;
                mediaAttachment.url = srcUrl;
                mediaAttachment.stringForEmbedding = [NSString stringWithFormat:@"<img src='%@'>", srcUrlString];
                
                [mediaAttachment generateThumbnailAndApplyOverlay:YES];
                
                mediaAttachment.attachmentId = [self replaceImageTag:activityImageTag withImageAtPath:mediaAttachment.urlForThumb.absoluteString ofHeight:mediaAttachment.thumb.size.height];
                
                NSMutableArray *newAttachements = [NSMutableArray arrayWithArray:self.attachmentManager.attachments];
                [newAttachements addObject:mediaAttachment];
                self.attachmentManager.attachments = newAttachements;
            }
            else {
                NSString *js = [NSString stringWithFormat:@"replaceInComment('%@', '%@')", activityImageTag, imageTag];
                [self.webView stringByEvaluatingJavaScriptFromString:js];
            }
            
            [loadingImages removeObjectForKey:activityImageTag];
        };
        
        imageView.imageURL = srcUrl;
    }];
    
    return returnValue;
}

- (NSString *)attachmentSheetTitle
{
    if (_attachmentSheetTitle == nil) {
        _attachmentSheetTitle = NSLocalizedString(@"Add attachment", @"Title for attachment action sheet from rich text view");
    }
    return _attachmentSheetTitle;
}

- (void)setAttachmentButtonImage:(UIImage *)attachmentButtonImage
{
    UIImage *image = [attachmentButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.addAttachmentButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"comment"]) {
        
        if ([request.URL.host isEqualToString:@"commentHasText"]) {
            self.sendButton.enabled = YES;
            self.sendButton.layer.borderColor = CKPostButtonEnabledColor().CGColor;
            self.placeholderLabel.hidden = YES;
        } else {
            self.sendButton.enabled = NO;
            self.sendButton.layer.borderColor = CKPostButtonDisabledColor().CGColor;
            self.placeholderLabel.hidden = NO;
        }
        
        [self resize];
        
        return NO;
    } else if ([scheme isEqualToString:@"preview"]) {
        
        uint64_t attachmentId = [request.URL.host unsignedLongLongValue];
        CKEmbeddedMediaAttachment *attachment = [attachmentManager.attachments in_firstObjectPassingTest:^BOOL(CKEmbeddedMediaAttachment * attachment, NSUInteger idx, BOOL *stop) {
            if (attachmentId == attachment.attachmentId) {
                *stop = YES;
                return YES;
            }
            
            return NO;
        }];
        
        CKURLPreviewViewController *previewController = [[CKURLPreviewViewController alloc] init];
        previewController.title = NSLocalizedString(@"Attachment", @"An item for attaching to a discussion");
        previewController.url = attachment.url;
        previewController.modalBarStyle = UIBarStyleBlack;
        
        [[self presentingViewController] presentViewController:previewController animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // This is to get around a nasty web view issue where initially text wasn't pasteable, so to get around that you set and unset text...
    NSString *js = [NSString stringWithFormat:@"setInitialText('%@');", @"INITIAL SET"];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    js = [NSString stringWithFormat:@"replaceInComment('%@', '%@')", @"INITIAL SET", @""];
    [self.webView stringByEvaluatingJavaScriptFromString:js];

    if (finishedLoadingWebViewBlock) {
        finishedLoadingWebViewBlock();
    }
}

#pragma mark - Posting

- (void)beginPostingComment
{
    self.sendButton.enabled = NO;
    self.sendButton.layer.borderColor = CKPostButtonDisabledColor().CGColor;
}

- (void)finishPostingComment
{
    self.sendButton.enabled = YES;
    self.sendButton.layer.borderColor = CKPostButtonEnabledColor().CGColor;
}

- (BOOL)isEmpty {
    NSString *strippedText = [self strippedText];
    return [strippedText isEqualToString:@""];
}

- (NSString *)grabText {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"getText();"];
}

- (NSString *)strippedText {
    NSString *someText =  [self.webView stringByEvaluatingJavaScriptFromString:@"$('#comment').text()"];
    someText = [someText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return someText;
}

- (IBAction)tappedPostCommentButton:(id)sender
{
    [self beginPostingComment];
    NSArray *attachments = [self attachments];
     
    __block NSString *commentText = [self grabText];
    
    if (![self isEmpty] || attachments.count > 0) {
        
        [loadingImages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            commentText = [commentText stringByReplacingOccurrencesOfString:key withString:obj];
        }];
        
        [self.delegate richTextView:self postComment:commentText withAttachments:attachments andCompletionBlock:^(NSError *error, BOOL isFinalValue) {
            if (error) {
                NSLog(@"Failed to post comment");
            } else {
                [self clearContents];
            }
            
            [self finishPostingComment];
        }];
    } else {
        [self finishPostingComment];
    }
}

- (NSArray *)attachments
{    
    NSString * indexesString = [self.webView stringByEvaluatingJavaScriptFromString:@"grabImageIndexes();"];
    
    NSArray * indexesArray = [NSJSONSerialization JSONObjectWithData:[indexesString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSString *index in indexesArray) {
        [indexSet addIndex:[index intValue]];
    }
    return [self.attachmentManager.attachments objectsAtIndexes:indexSet];
}

# pragma mark - Choosing Media

- (UIViewController *)presentingViewController
{
    UIViewController *presentingViewController;
    id presenter = self;
    while (presenter && ![presenter isKindOfClass:[UIViewController class]]) {
        presenter = [presenter nextResponder];
    }
    if ([presenter isKindOfClass:[UIViewController class]]) {
        presentingViewController = presenter;
    }
    
    return presentingViewController;
}

- (IBAction)addAttachment:(id)sender
{   
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *superView = self;
        UIButton *button = addAttachmentButton;
        if (sender) {
            button = (UIButton *)sender;
            superView = button.superview;
        }
        if (!self.attachmentManager.presentFromViewController && [self.delegate isKindOfClass:[UIViewController class]]) {
            [self.attachmentManager setPresentFromViewController:(UIViewController *)self.delegate];
        }
        [self.attachmentManager showAttachmentPickerFromRect:button.frame
                                                      inView:superView
                                    permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                              withSheetTitle:self.attachmentSheetTitle];
    } else {
        // dismiss keyboard so that it won't cover up the audio widget
        [self dismissKeyboard];
        [self.attachmentManager showAttachmentPickerFromViewController:[self presentingViewController] withSheetTitle:self.attachmentSheetTitle];
    }
}

#pragma mark - CKAttachmentManagerDelegate

- (void)attachmentManager:(CKAttachmentManager *)manager didAddAttachmentAtIndex:(NSUInteger)index
{
    CKEmbeddedMediaAttachment *newAttachment = (manager.attachments)[index];
    newAttachment.attachmentId = [self addImage:[newAttachment.urlForThumb absoluteString]
                                        ofHeight:newAttachment.thumb.size.height];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Keeps the status bar black when the imagepicker tries to change it.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

@end

