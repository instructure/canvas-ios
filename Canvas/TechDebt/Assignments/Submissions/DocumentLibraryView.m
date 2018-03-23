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
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CanvasKit1/CKURLPreviewViewController.h>

#import "DocumentLibraryView.h"
#import "UIView_render_IN.h"
#import "NoPreviewAvailableController.h"

#ifndef FLT_EPSILON
#define FLT_EPSILON __FLT_EPSILON__
#endif

@interface CALayer (IN_implicitAnimations) <CALayerDelegate>
- (void)enableImplicitAnimationsInBlock:(void(^)(void))block;
@end

@implementation CALayer (IN_implicitAnimations)

static NSString *OldDelegateKey = @"OldDelegateKey";

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    id oldDelegate = [self valueForKey:OldDelegateKey];
    [oldDelegate actionForLayer:layer forKey:event];
    return nil;
}

- (void)enableImplicitAnimationsInBlock:(void(^)(void))block {    
    id oldDelegate = self.delegate;

    [self setValue:oldDelegate forKey:OldDelegateKey];
    
    self.delegate = self;
    block();
    self.delegate = oldDelegate;
    
    [self setValue:nil forKey:OldDelegateKey];
}

@end


#pragma mark - Main implementation -


@interface DocumentLibraryView () <UIScrollViewDelegate, QLPreviewControllerDelegate>
@property (strong, readwrite) NSURL *frontItem;
@end

@implementation DocumentLibraryView {
    UIScrollView *scrollView;
    UIPageControl *pageIndicator;
    UIView *helpContainer;
    UILabel *helpLabel;
    NSMutableArray *previewContainers;
    NSMutableArray *qlControllers;
    
    int currentItemIndex;
    
    CGFloat itemInterval;
    
    NSMutableIndexSet *selectedItemIndexes;
    UIPinchGestureRecognizer *disabledRecognizerForFullScreening;
    
    BOOL rebuildPreviewContainers;
    
    NSArray *accessibilityElements;
}

@synthesize delegate;
@synthesize itemURLs;
@synthesize frontItem;
@synthesize noItemsHelpString;

static const CGFloat kUnselectedAlpha = 0.4;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect pageControlFrame;
        CGRect scrollViewFrame;
        CGRectDivide(self.bounds, &pageControlFrame, &scrollViewFrame,
                     10, CGRectMaxYEdge);
        
        scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.delegate = self;
        scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.decelerationRate = 0;
        scrollView.clipsToBounds = NO;
        
        CGRect helpFrame = CGRectInset(scrollViewFrame, 10, 10);
        helpLabel = [[UILabel alloc] initWithFrame:helpFrame];
        helpLabel.textColor = [UIColor darkTextColor];
        helpLabel.hidden = YES;
        helpLabel.backgroundColor = [UIColor clearColor];
        helpLabel.opaque = NO;
        helpLabel.numberOfLines = 0;
        [helpLabel setLineBreakMode:NSLineBreakByWordWrapping];
        helpLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] + 2];
        helpLabel.textAlignment = NSTextAlignmentCenter;

        pageIndicator = [[UIPageControl alloc] initWithFrame:pageControlFrame];
        pageIndicator.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        pageIndicator.hidesForSinglePage = YES;
        [pageIndicator setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        [pageIndicator setPageIndicatorTintColor:[UIColor lightGrayColor]];
        
        selectedItemIndexes = [NSMutableIndexSet new];

        itemInterval = roundf(self.bounds.size.width / 3.0 * 2.0);
        
        [self addSubview:scrollView];
        [self addSubview:pageIndicator];
    }
    return self;
}

- (void)setSelected:(BOOL)selected forItem:(NSURL *)item {
    NSUInteger itemIndex = [self.itemURLs indexOfObject:item];
    if (selected) {
        [selectedItemIndexes addIndex:itemIndex];
    }
    else {
        [selectedItemIndexes removeIndex:itemIndex];
    }
    if (itemIndex == currentItemIndex) {
        [self updateAccessibilityTraitsForFrontItem];
    }
    [self setNeedsLayout];
    
}

- (BOOL)itemIsSelected:(NSURL *)item {
    NSUInteger itemIndex = [self.itemURLs indexOfObject:item];
    return [selectedItemIndexes containsIndex:itemIndex];
}

- (BOOL)itemAtIndexIsSelected:(NSUInteger)itemIndex {
    return [selectedItemIndexes containsIndex:itemIndex];
}

- (void)setItemURLs:(NSArray *)someURLs {
    itemURLs = someURLs;
    
    [previewContainers makeObjectsPerformSelector:@selector(removeFromSuperview)];
    previewContainers = nil;
    [selectedItemIndexes removeAllIndexes];
    
    rebuildPreviewContainers = YES;
    [self setNeedsLayout];
}

- (void)removeItem:(NSURL *)item {
    if (item == nil) {
        return;
    }
    NSUInteger itemIndex = [self.itemURLs indexOfObject:item];
    NSMutableArray *mutableItems = [itemURLs mutableCopy];
    [mutableItems removeObjectAtIndex:itemIndex];
    
    [selectedItemIndexes shiftIndexesStartingAtIndex:itemIndex+1 by:-1];
    
    [previewContainers[itemIndex] removeFromSuperview];
    [previewContainers removeObjectAtIndex:itemIndex];
    
    [qlControllers removeObjectAtIndex:itemIndex];
    
    self.itemURLs = mutableItems;

    if (currentItemIndex == itemIndex) {
        
        NSInteger newItemIndex = (NSInteger) itemIndex;
        if (itemIndex == self.itemURLs.count) {
            newItemIndex -= 1;
        }
        if (newItemIndex >= 0) {
            [scrollView setContentOffset:[self contentOffsetForDisplayingItemAtIndex:newItemIndex] animated:YES];
            [self highlightItemAtIndex:newItemIndex];
            [self performSelector:@selector(updateScrollViewContentSize) withObject:nil afterDelay:0.5];
        }
        else {
            self.frontItem = nil;
            
            if (self.delegate) {
                [self.delegate libraryView:self didChangeFrontItem:self.frontItem];
            }
        }
    }
    [self setNeedsLayout];
}

- (void)addItem:(NSURL *)item {
    NSMutableArray *mutableItems = [itemURLs mutableCopy];
    [mutableItems addObject:item];
    
    self.itemURLs = mutableItems;
    
    if (self.itemURLs.count == 1) {
        // This is the first item
        [self highlightItemAtIndex:0];
        
        if (self.delegate) {
            [self.delegate libraryView:self didChangeFrontItem:self.frontItem];
        }
    }
    [self setNeedsLayout];
}

- (NSArray *)selectedItems {
    return [self.itemURLs objectsAtIndexes:selectedItemIndexes];
}

#pragma mark - internal

- (void)highlightItemAtIndex:(NSUInteger)index {
    [UIView animateWithDuration:0.4 animations:
     ^{
         for (UIView *container in previewContainers) {
             container.alpha = kUnselectedAlpha;
         }
         
         UIView *newSelection = previewContainers[index];
         newSelection.alpha = 1.0;
     }];
    
    currentItemIndex = (int) index;
    if (index < itemURLs.count) {
        self.frontItem = itemURLs[index];
    }
    else {
        self.frontItem = nil;
    }
    
    if (self.delegate) {
        [self.delegate libraryView:self didChangeFrontItem:self.frontItem];
    }

}

- (NSUInteger)numberOfPages {
    NSUInteger pageCount = itemURLs.count;
    if (helpLabel.hidden == NO) {
        pageCount += 1;
    }
    return pageCount;
}

- (void)updateScrollViewContentSize {
    NSUInteger lastIndex = [self numberOfPages]-1;
    CGPoint lastCenterPoint = [self centerForItemAtIndex:lastIndex];
    scrollView.contentSize = CGSizeMake(lastCenterPoint.x + (scrollView.bounds.size.width / 2.0) + 1, scrollView.bounds.size.height);
}

static CGRect CGRectWithAspect(CGRect input, float widthOverHeight) {
    
    CGRect final = CGRectZero;
    CGFloat startingAspectRatio = input.size.width / input.size.height;
    if (startingAspectRatio > widthOverHeight) {
        // It's too wide; we need to trim off the sides
        CGFloat targetWidth = widthOverHeight / startingAspectRatio * input.size.width;
        CGFloat trimAmount = input.size.width - targetWidth;
        CGFloat insetAmount = trimAmount / 2.0;
        final = CGRectInset(input, insetAmount, 0);
    }
    else {
        // It's too tall; we need to trim off the top and bottom
        CGFloat targetHeight = startingAspectRatio / widthOverHeight * input.size.height;
        CGFloat trimAmount = input.size.height - targetHeight;
        CGFloat insetAmount = trimAmount / 2.0;
        final = CGRectInset(input, 0, insetAmount);
    }
    
    return final;
}

static CGRect CGRectForDisplayingItemOfSize(CGRect container, CGSize itemSize) {
    CGRect aspectRect = CGRectWithAspect(container, itemSize.width / itemSize.height);
    CGRect final = aspectRect;
    if (aspectRect.size.height > itemSize.height && aspectRect.size.width > itemSize.width) {
        CGFloat heightRatio = itemSize.height / aspectRect.size.height;
        CGFloat widthRatio = itemSize.width / aspectRect.size.width;
        
        CGFloat scalingRatio = MAX(heightRatio, widthRatio);
        CGAffineTransform shiftToCenter = CGAffineTransformMakeTranslation(-CGRectGetMidX(aspectRect), -CGRectGetMidY(aspectRect));
        CGAffineTransform scale = CGAffineTransformMakeScale(scalingRatio, scalingRatio);
        CGAffineTransform shiftBack = CGAffineTransformInvert(shiftToCenter);
        CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(shiftToCenter, scale), shiftBack);
        final = CGRectApplyAffineTransform(aspectRect, transform);
    }
    return final;
}


- (void)layoutHelpContainer {
    helpLabel.text = self.noItemsHelpString;
    
    CGRect boundingFrame = helpContainer.bounds;
    
    CGRect rect = [self.noItemsHelpString boundingRectWithSize:boundingFrame.size options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:helpLabel.font} context:nil];
    CGSize stringSize = rect.size;
    
    CGPoint oldCenter = helpLabel.center;
    CGRect oldFrame = helpLabel.frame;
    oldFrame.size = stringSize;
//    helpLabel.frame = oldFrame;
    
    helpLabel.center = oldCenter;
    
//    helpLabel.frame = CGRectIntegral(helpLabel.frame);
    
    helpContainer.center = [self centerForItemAtIndex:self.itemURLs.count];
}


- (UIView *)thumbnailViewForURL:(NSURL *)url ofSize:(CGSize)size {
    UIView *previewView = nil;
    CGSize preferredSize = CGSizeZero;
    
    NSString *uti;
    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    
    NSArray *movieTypes = [AVURLAsset audiovisualTypes];
    if ([movieTypes containsObject:uti]) {
        // Make a thumbnail of the first frame
            
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0, 30)
                                               actualTime:NULL error:NULL];
        
        if (cgImage) {
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            preferredSize = image.size;
            CFRelease(cgImage);
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            previewView = imageView;
            [qlControllers addObject:[NSNull null]];
        }
    }
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)){
        UIImage *image = [UIImage imageWithContentsOfFile:url.path];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        previewView = imageView;
        [qlControllers addObject:[NSNull null]];
    }
    else if ([QLPreviewController canPreviewItem:url]) {
        // Just use a QLPreviewController
        CKURLPreviewViewController *previewController = [[CKURLPreviewViewController alloc] init];
        previewController.url = url;
        
        [qlControllers addObject:previewController];
        previewView = previewController.view;
        // previewView.opaque = NO;
        
        [previewController reloadData];
        [previewController viewWillAppear:NO];
    }
    
    if (UTTypeConformsTo((__bridge CFTypeRef)uti, kUTTypeImage)) {
        UIImage *image = [UIImage imageWithContentsOfFile:url.path];
        preferredSize = image.size;
    }
    
    if (previewView == nil) {
        NoPreviewAvailableController *noPreviewController = [NoPreviewAvailableController new];
        noPreviewController.url = url;
        previewView = noPreviewController.view;
    }
    
    CGRect frame = (CGRect){.origin=CGPointZero, .size=size};
    
    if (CGSizeEqualToSize(preferredSize, CGSizeZero) == NO) {
        // Respect the aspect ratio
        frame = CGRectForDisplayingItemOfSize(frame, preferredSize);
    }
    previewView.frame = frame;
    previewView.userInteractionEnabled = NO;
    return previewView;
}

- (void)insertPreviewControllers {
    
    int i=0;
    qlControllers = [NSMutableArray new];
    NSMutableArray *containers = [NSMutableArray new];

    CGSize previewItemSize = CGSizeMake(itemInterval - 20, scrollView.bounds.size.height - 40);

    for (NSURL *item in itemURLs) {
        UIView *previewView = nil;
        
        previewView = [self thumbnailViewForURL:item ofSize:previewItemSize];
        CGRect frame = (CGRect){.origin = CGPointZero, .size = previewItemSize};
        
        UIView *previewContainer = [[UIView alloc] initWithFrame:frame];
        previewContainer.layer.borderColor = [[UIColor colorWithHue:0.125 saturation:0.756 brightness:1.000 alpha:1.000] CGColor];
        previewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        [containers addObject:previewContainer];
        
        if (i != 0) {
            previewContainer.alpha = kUnselectedAlpha;
        }
        i += 1;
        [scrollView addSubview:previewContainer];
        
        previewView.userInteractionEnabled = NO;
        
        [previewContainer addSubview:previewView];

        UIView *gestureReceiver = [[UIView alloc] initWithFrame:previewContainer.bounds];
        gestureReceiver.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        gestureReceiver.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [previewContainer addSubview:gestureReceiver];
        
        UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tappedContainer:)];
        [gestureReceiver addGestureRecognizer:tapRecognizer];
        
        if ([QLPreviewController canPreviewItem:item]) {
            UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(doubleTappedContainer:)];
            doubleTapRecognizer.numberOfTapsRequired = 2;
            [gestureReceiver addGestureRecognizer:doubleTapRecognizer];
        }
    }
    
    CGRect helpFrame = (CGRect){.origin = CGPointZero, .size = previewItemSize};
    helpContainer = [[UIView alloc] initWithFrame:helpFrame];
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tappedContainer:)];
    UIView *gestureReceiver = [[UIView alloc] initWithFrame:helpContainer.bounds];
    gestureReceiver.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    gestureReceiver.backgroundColor = [UIColor clearColor];
    [helpContainer addSubview:gestureReceiver];
    [helpContainer addGestureRecognizer:tapRecognizer];
    
    helpLabel.frame = helpContainer.bounds;
    [helpContainer addSubview:helpLabel];
    [scrollView addSubview:helpContainer];
    [containers addObject:helpContainer];
    
    previewContainers = containers;
    
    [self updateScrollViewContentSize];
    
    if (itemURLs.count > 0) {
        self.frontItem = itemURLs[0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    itemInterval = roundf(self.bounds.size.width / 3.0 * 2.0);
    if (itemURLs.count == 0 || [self.delegate libraryViewShouldShowHelpString:self]) {
        helpLabel.hidden = NO;
    }
    else {
        helpLabel.hidden = YES;
    }
    
    if (rebuildPreviewContainers) {
        [self insertPreviewControllers];
        rebuildPreviewContainers = NO;
        [self highlightItemAtIndex:currentItemIndex];
    }
    
    [self updatePageIndicator];
    
    

    [CATransaction setAnimationDuration:0.2];
    [previewContainers enumerateObjectsUsingBlock:^(UIView *container, NSUInteger idx, BOOL *stop) {
        if (container.frame.origin.y != 0) {
            [UIView animateWithDuration:0.2 animations:^{
                container.center = [self centerForItemAtIndex:idx];
            }];
        } else {
            container.center = [self centerForItemAtIndex:idx];
        }
        
        [container.layer enableImplicitAnimationsInBlock:^{
            container.layer.borderWidth = 0.0;
        }];
    }];
    
    [selectedItemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        UIView *container = previewContainers[idx];
        
        [container.layer enableImplicitAnimationsInBlock:^{
            container.layer.borderWidth = 5.0;
        }];

    }];
    
    [self layoutHelpContainer];

}

- (CGPoint)centerForItemAtIndex:(NSUInteger)index {
    
    CGFloat y = CGRectGetMidY(scrollView.bounds);
    CGFloat x = CGRectGetWidth(scrollView.bounds) / 2.0 + index * itemInterval;
    return CGPointMake(x, y);
}

- (CGPoint)contentOffsetForDisplayingItemAtIndex:(NSUInteger)index {
    CGPoint target = [self centerForItemAtIndex:index];
    
    target.x -= scrollView.bounds.size.width / 2.0 - FLT_EPSILON;
    target.y = 0.0;
    return target;
}

- (NSUInteger)nearestItemIndexForContentOffset:(CGPoint)scrollOffset {
    CGFloat x = scrollOffset.x;
    x /= itemInterval;
    x = roundf(x);
    x = MAX(0, MIN(x, [self numberOfPages] - 1));
    return (NSUInteger)x;
}

- (void)scrollToItemAtIndex:(NSUInteger)index {
    CGPoint offset = [self contentOffsetForDisplayingItemAtIndex:index];
    [scrollView setContentOffset:offset animated:YES];
    NSString *accessibilityStr = [NSString stringWithFormat:NSLocalizedString(@"Item %d of %d", nil), index + 1, [self numberOfPages]];
    if ([selectedItemIndexes containsIndex:index]) {
        accessibilityStr = [accessibilityStr stringByAppendingFormat:@", %@", NSLocalizedString(@"Selected", nil)];
    }
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, accessibilityStr);
}


- (void)updatePageIndicator {
    pageIndicator.numberOfPages = [self numberOfPages];
    
    NSUInteger itemIndex = [self nearestItemIndexForContentOffset:scrollView.contentOffset];
    itemIndex = MAX(0, MIN(itemIndex, [self numberOfPages]-1));
    pageIndicator.currentPage = itemIndex;
}

- (void)tappedContainer:(UIGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    UIView *container = recognizer.view.superview;
    NSUInteger index = [previewContainers indexOfObject:container];
    
    //Fix for MBL-4185: Couldn't find view, they probably tapped the white space belonging to the UIScrollView around the image
    if (index == NSIntegerMax) {
        return;
    }
    
    if (index == currentItemIndex && index < self.itemURLs.count) {
        NSURL *item = (self.itemURLs)[index];
        [self.delegate libraryView:self didTapFrontItem:item];
    }
    else
    {
        [self scrollToItemAtIndex:index];
    }
}

- (void)doubleTappedContainer:(UITapGestureRecognizer *)recognizer {
    // Undo the effects of the first tap
    // We *could* require the double-tap recognizer to fail before triggering
    // the single-tap recognizer, but that adds a bunch of lag to the single-
    // tap responsiveness.
    [self tappedContainer:recognizer];
    
    [self showFullScreenPreviewForContainer:recognizer.view.superview];
}

- (void)showFullScreenPreviewForContainer:(UIView *)container {
    NSUInteger index = [previewContainers indexOfObject:container];
    CKURLPreviewViewController *fullScreenController = [[CKURLPreviewViewController alloc] init];
    fullScreenController.url = (self.itemURLs)[index];
    fullScreenController.delegate = self;
    fullScreenController.modalBarStyle = UIBarStyleBlackOpaque;
    
    UIViewController *presenter = [self.delegate libraryViewControllerForPresentingFullScreenPreview:self];
    [presenter presentViewController:fullScreenController animated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [self updatePageIndicator];
    if (pageIndicator.currentPage != currentItemIndex) {
        [self highlightItemAtIndex:pageIndicator.currentPage];
    }

}

- (void)scrollViewWillEndDragging:(UIScrollView *)aScrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint offsetAfterVelocity = scrollView.contentOffset;
    offsetAfterVelocity.x += velocity.x * 5;
    offsetAfterVelocity.y += velocity.y * 5;
    
    NSInteger itemIndex = [self nearestItemIndexForContentOffset:*targetContentOffset];
    
    CGPoint target = [self contentOffsetForDisplayingItemAtIndex:itemIndex];
    
    *targetContentOffset = target;
}

#pragma mark - QLPreviewControllerDelegate

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView *__autoreleasing *)view {
    NSURL *url = (id)item;
    
    NSUInteger index = [self.itemURLs indexOfObject:url];
    if (index == NSNotFound) {
        return CGRectZero;
    }
    
    UIView *container = previewContainers[index];
    CGRect frame = container.frame;
    
    *view = container.superview;
    return frame;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    // Re-enable the pinch recognizer we used to go full screen;
    disabledRecognizerForFullScreening.enabled = YES;
    disabledRecognizerForFullScreening = nil;
    
    [self.superview setNeedsLayout];
}

#pragma mark - Accessibility

- (void)updateAccessibilityTraitsForFrontItem {
    UIAccessibilityElement *element = [self accessibilityElements][1];
    element.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitImage;
    if ([self itemAtIndexIsSelected:currentItemIndex]) {
        element.accessibilityTraits |= UIAccessibilityTraitSelected;
    }
    
    // Accessibility frame
    element.accessibilityFrame = [self accessibilityFrameForFrontItem];
    
    // Accessibility label
    if (currentItemIndex < itemURLs.count) {
        element.accessibilityLabel = [itemURLs[currentItemIndex] lastPathComponent];
    }
    else if (helpLabel.hidden == NO) {
        element.accessibilityLabel = helpLabel.text;
    }
}

- (NSArray *)accessibilityElements {
    if (!accessibilityElements) {
        UIAccessibilityElement *prevTab = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        
        CGRect garbage;
        
        CGRect leftSide;
        CGRectDivide(self.bounds, &leftSide, &garbage, 50, CGRectMinXEdge);
        leftSide = [self convertRect:leftSide toView:nil];
        prevTab.accessibilityFrame = leftSide;
        prevTab.accessibilityLabel = NSLocalizedString(@"Previous item", nil);
        
        UIAccessibilityElement *nextTab = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        CGRect rightSide;
        CGRectDivide(self.bounds, &rightSide, &garbage, 50, CGRectMaxXEdge);
        rightSide = [self convertRect:rightSide toView:nil];
        nextTab.accessibilityFrame = rightSide;
        nextTab.accessibilityLabel = NSLocalizedString(@"Next item", nil);
        
        UIAccessibilityElement *middleItem = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        middleItem.accessibilityHint = NSLocalizedString(@"Toggles selection of item", nil);
        // The accessibility properties of the middle item will be dynamically
        // configured, based on whatever item is in front.
                
        accessibilityElements = @[prevTab, middleItem, nextTab];
    }
    return accessibilityElements;
}

- (CGRect)accessibilityFrameForFrontItem {
    UIView *currentItem = previewContainers[currentItemIndex];
    CGRect itemBounds = currentItem.bounds;
    CGRect itemRect = [currentItem convertRect:itemBounds toView:nil];
    return itemRect;
}

- (NSInteger)accessibilityElementCount {
    return [[self accessibilityElements] count]; // Previous, current, next
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    UIAccessibilityElement *element = [self accessibilityElements][index];
    if (index == 0) {
        element.isAccessibilityElement = (currentItemIndex > 0);
    }
    if (index == 1) {
        [self updateAccessibilityTraitsForFrontItem];
    }
    if (index == 2) {
        element.isAccessibilityElement = (currentItemIndex < [self numberOfPages] - 1);
    }
    return element;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [[self accessibilityElements] indexOfObject:element];
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    switch (direction) {
        case UIAccessibilityScrollDirectionLeft:
        case UIAccessibilityScrollDirectionNext:
            if (currentItemIndex != self.numberOfPages - 1) {
                [self scrollToItemAtIndex:currentItemIndex + 1];
            }
            break;
            
        case UIAccessibilityScrollDirectionRight:
        case UIAccessibilityScrollDirectionPrevious:
            if (currentItemIndex != 0) {
                [self scrollToItemAtIndex:currentItemIndex - 1];
            }
            break;
            
        default:
            return NO;
            break;
    }
    return YES;
}
@end
