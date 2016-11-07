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

#import "CSGPlaceholderTextView.h"

@interface CSGPlaceholderTextView ()

@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic, strong) NSLayoutConstraint *placeHolderTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *placeHolderLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *placeHolderBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *placeHolderRightConstraint;

@end

@implementation CSGPlaceholderTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupPlaceholderLabelIfNeeded];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupPlaceholderLabelIfNeeded];
}

- (void)setupPlaceholderLabelIfNeeded {
    if (self.placeHolderLabel) {
        return;
    }
    
    self.placeHolderLabel = [[UILabel alloc] init];
    
    self.placeHolderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeHolderLabel.textColor = [UIColor colorWithWhite: 0.70 alpha:1];
    self.placeHolderLabel.font = self.font;
    [self addSubview:self.placeHolderLabel];
    
    
    self.padding = UIEdgeInsetsMake(8, 5, 5, 5);
    
    self.placeHolderTopConstraint = [NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.padding.top];
    self.placeHolderTopConstraint.priority = 1000;
    self.placeHolderLeftConstraint = [NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.padding.left];
    self.placeHolderLeftConstraint.priority = 1000;
    self.placeHolderBottomConstraint = [NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.padding.bottom];
    self.placeHolderBottomConstraint.priority = 1000;
    self.placeHolderRightConstraint = [NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-self.padding.right];
    self.placeHolderRightConstraint.priority = 1000;
    
    [self addConstraints:@[
                           self.placeHolderTopConstraint,
                           self.placeHolderLeftConstraint,
                           self.placeHolderBottomConstraint,
                           self.placeHolderRightConstraint
                           ]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEditingNotification:) name:UITextViewTextDidChangeNotification object:self];
    
    [self layoutIfNeeded];
    
    
}

- (void)changeEditingNotification:(NSNotification *)notification {
    // Handle changes to the text or attributed text
    NSString *realText = self.text;
    if (!realText.length) {
        realText = self.attributedText.string;
    }
    
    [self animatePlaceholderTextIfNeeded:realText];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self animatePlaceholderTextIfNeeded:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    
    [self animatePlaceholderTextIfNeeded:attributedText.string];
}

- (void)animatePlaceholderTextIfNeeded:(NSString *)text {
    // animate placeholder visible if there is no text in the box
    [self animatePlaceholderTextVisible:(!text.length)];
}

- (void)animatePlaceholderTextVisible:(BOOL)visible {
    
    __block CGFloat alpha = 0.0f;
    if (visible) {
        alpha = 1.0f;
        self.placeHolderTopConstraint.constant = self.padding.top;
    } else {
        self.placeHolderTopConstraint.constant = -self.placeHolderLabel.frame.size.height;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.placeHolderLabel.alpha = alpha;
        [self layoutIfNeeded];
    }];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    if (_placeholderText == placeholderText) {
        return;
    }
    
    _placeholderText = placeholderText;
    
    [self setupPlaceholderLabelIfNeeded];
    self.placeHolderLabel.text = _placeholderText;
}

@end
