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
    
    

#import "DiscussionChildCountIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@import SoPretty;

@import SoPretty;

@implementation DiscussionChildCountIndicatorView {
    UILabel *textDrawingLabel;
    UIColor *totalCountColor;
    UIColor *unreadCountColor;
}
@synthesize totalCount = _totalCount;
@synthesize unreadCount = _unreadCount;
@synthesize width = _width;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}

- (void)commonSetup {
    textDrawingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textDrawingLabel.shadowOffset = CGSizeMake(0, -1);
    textDrawingLabel.shadowColor = [UIColor prettyGray];
    textDrawingLabel.font = [UIFont boldSystemFontOfSize:12.0];
    textDrawingLabel.textColor = [UIColor whiteColor];
    textDrawingLabel.textAlignment = NSTextAlignmentCenter;
    
    self.backgroundColor = [UIColor clearColor];
    totalCountColor = [UIColor prettyGray];
    unreadCountColor = Brand.current.secondaryTintColor;
}

- (void)setTotalCount:(int)totalCount
{
    _totalCount = totalCount;
    [self calculateWidth];
}

- (int)totalCount
{
    return _totalCount;
}

- (void)setUnreadCount:(int)unreadCount
{
    _unreadCount = unreadCount;
    [self calculateWidth];
}

- (int)unreadCount
{
    return _unreadCount;
}

- (void)calculateWidth
{
    _width = 0;
    if (_totalCount > 0) {
        NSString *totalCount = [NSString stringWithFormat:@"%d", _totalCount];
        _width = [totalCount sizeWithAttributes:@{NSFontAttributeName:textDrawingLabel.font}].width;
    }
    if (_unreadCount > 0) {
        NSString *unreadCount = [NSString stringWithFormat:@"%d", _unreadCount];
        _width = _width + [unreadCount sizeWithAttributes:@{NSFontAttributeName:textDrawingLabel.font}].width;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    const CGFloat PADDING_AROUND_TEXT = 4;
    const CGFloat CORNER_RADIUS = 2.0;

    CGRect totalCountRect = CGRectZero;
    CGRect remainder = self.bounds;
    CGSize totalCountSize = CGSizeZero;
    
    NSString *totalCount = [NSString stringWithFormat:@"%d", _totalCount];
    if (_totalCount > 0) {
        totalCountSize = [totalCount sizeWithAttributes:@{NSFontAttributeName:textDrawingLabel.font}];
        
        CGRectDivide(self.bounds, &totalCountRect, &remainder, totalCountSize.width + 2*PADDING_AROUND_TEXT, CGRectMaxXEdge);
    }
    
    // Drawing code
    
    if (_unreadCount > 0) {
        NSString *unreadCount = [NSString stringWithFormat:@"%d", _unreadCount];
        CGSize unreadCountSize = [unreadCount sizeWithAttributes:@{NSFontAttributeName:textDrawingLabel.font}];
        CGRect unreadCountRect;
        CGRect garbage;
        CGFloat amount = unreadCountSize.width + 2*PADDING_AROUND_TEXT;
        CGRectDivide(remainder, &unreadCountRect, &garbage, amount, CGRectMaxXEdge);
        
        CGRect backgroundRect = unreadCountRect;
        
        if (_totalCount > 0) {
            // make the unread background rect hide slightly behind the total rect
            backgroundRect.size.width += PADDING_AROUND_TEXT;
            unreadCountRect.origin.x += floor(PADDING_AROUND_TEXT / 2.0);
        }
        
        UIBezierPath *unreadBackground = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:CORNER_RADIUS];
        [unreadCountColor set];
        [unreadBackground fill];
        textDrawingLabel.text = unreadCount;
        [textDrawingLabel drawTextInRect:unreadCountRect];
    }
    
    if (_totalCount > 0) {
        UIBezierPath *roundedBackground = [UIBezierPath bezierPathWithRoundedRect:totalCountRect cornerRadius:CORNER_RADIUS];
        [totalCountColor set];
        [roundedBackground fill];
        textDrawingLabel.text = totalCount;
        [textDrawingLabel drawTextInRect:totalCountRect];
    }
}

- (NSString *)accessibilityLabel {
    NSMutableString *label = [NSMutableString string];
    if (_totalCount > 0) {
        NSString *totalTemplate = NSLocalizedString(@"%d replies", @"Something like '5 replies'");
        [label appendFormat:totalTemplate, _totalCount];
    }
    if (_unreadCount > 0) {
        if (_totalCount) {
            [label appendString:@", "];
        }
        NSString *unreadTemplate = NSLocalizedString(@"%d unread", @"Something like '3 unread'. Refers to unread replies in a discsusion.");
        [label appendFormat:unreadTemplate, _unreadCount];
    }
    return label;
}

- (BOOL)isAccessibilityElement {
    return self.accessibilityLabel.length > 0;
}

@end
