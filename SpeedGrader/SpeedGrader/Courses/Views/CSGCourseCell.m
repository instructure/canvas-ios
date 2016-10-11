//
// CSGCourseCell.m
// Created by Jason Larsen on 4/30/14.
//

#import "CSGCourseCell.h"

#import "CSGColorPickerView.h"
#import "CSGBadgeView.h"

#import "CSGUserPrefsKeys.h"

#import "UIImage+Color.h"

static NSTimeInterval const CSGCourseCellColorPickerAnimationDuration = 0.35;

static CGFloat const CSGCourseCellColorPickerTopConstraintHiddenValue = -120;
static CGFloat const CSGCourseCellColorPickerTopConstraintShowingValue = 15;
static CGFloat const CSGCourseCellToggleFavoriteButtonBottomConstraintHiddenValue = -32;
static CGFloat const CSGCourseCellToggleFavoriteButtonBottomConstraintShowingValue = 8;

@interface CSGCourseCell () <CSGColorPickerViewDelegate>

@property (nonatomic) BOOL colorPickerShowing;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toggleFavoriteButtonBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *colorPickerViewTopConstraint;
@property (nonatomic, weak) IBOutlet UIButton *toggleFavoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *toggleColorPickerButton;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet CSGColorPickerView *colorPickerView;

@end

@implementation CSGCourseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.layer.cornerRadius = 6.0f;
    self.contentView.layer.cornerRadius = 6.0f;
    self.contentContainerView.layer.borderColor = [RGB(241, 243, 246) CGColor];
    self.contentContainerView.layer.borderWidth = 1.0f;
    self.contentContainerView.layer.cornerRadius = 6.0f;
    self.contentContainerView.clipsToBounds = YES;

    self.needsGradingBadgeView.borderWidth = 3.0f;
    self.needsGradingBadgeView.borderColor = [UIColor whiteColor];
    self.needsGradingBadgeView.backgroundView.backgroundColor = [UIColor redColor];
    
    NSString *helveticaNeue = @"HelveticaNeue";
    NSString *helveticaNeueBold = @"HelveticaNeue-Bold";
    
    self.courseCodeLabel.font = [UIFont fontWithName:helveticaNeueBold size:14.0f];
    self.courseCodeLabel.textColor = [UIColor whiteColor];
    
    self.courseNameLabel.font = [UIFont fontWithName:helveticaNeue size:30.0f];
    self.courseNameLabel.textColor = [UIColor blackColor];
    
    [self.toggleColorPickerButton setImage:[[UIImage imageNamed:@"icon_arrow_up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]  forState:UIControlStateNormal];
    
    self.colorPickerView.alpha = 0.0;
    self.colorPickerView.delegate = self;
    
    // TODO: Enable this for favoriting.
    self.toggleFavoriteButton.alpha = 0.0f;
    [self animateColorPickerShowing:NO animated:NO];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.colorPickerShowing = NO;
    [self animateColorPickerShowing:NO animated:NO];
}

- (IBAction)toggleColorPickerButtonPressed:(id)sender {
    self.colorPickerShowing = !self.colorPickerShowing;
    [self animateColorPickerShowing:self.colorPickerShowing animated:YES];
}

- (void)animateColorPickerShowing:(BOOL)visible animated:(BOOL)animated {
    NSTimeInterval animationDuration = animated ? CSGCourseCellColorPickerAnimationDuration : 0.0f;
    
    self.toggleColorPickerButton.userInteractionEnabled = NO;
    self.colorPickerViewTopConstraint.constant = visible ? CSGCourseCellColorPickerTopConstraintShowingValue : CSGCourseCellColorPickerTopConstraintHiddenValue;
    self.toggleFavoriteButtonBottomConstraint.constant = visible ? CSGCourseCellToggleFavoriteButtonBottomConstraintShowingValue : CSGCourseCellToggleFavoriteButtonBottomConstraintHiddenValue;
    
    [UIView animateWithDuration:animationDuration delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:0 animations:^{
        self.toggleColorPickerButton.transform = visible ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        self.courseNameLabel.alpha = !visible;
        self.colorPickerView.alpha = visible;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.toggleColorPickerButton.userInteractionEnabled = YES;
    }];
}

- (IBAction)favoriteButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
}

- (void)setCourse:(CKICourse *)course {
    _course = course;
    self.courseNameLabel.text = course.name;
    self.courseCodeLabel.text = course.courseCode;
    [self reloadCourseColor];
    [self reloadBadgeView];
}

- (void)reloadCourseColor {
    UIColor *courseColor = [CSGUserPrefsKeys colorForCourseID:self.course.id];
    if (!courseColor) {
        NSArray *courseColors = [UIColor csg_courseColors];
        NSInteger colorIndex = arc4random() % [courseColors count];
        courseColor = courseColors[colorIndex];
        [self didPickColor:courseColor];
    }
    
    self.tintColor = courseColor;
    
    [self.colorPickerView setSelectedColor:courseColor];
}

- (void)reloadBadgeView {
    NSInteger needsGradingCount = self.course.needsGradingCount;
    if (needsGradingCount == 0) {
        self.needsGradingBadgeView.hidden = YES;
        return;
    }
    
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    self.needsGradingBadgeView.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)needsGradingCount];
    self.needsGradingBadgeView.hidden = NO;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    self.courseColorView.backgroundColor = self.tintColor;
    self.toggleColorPickerButton.tintColor = self.tintColor;
}

- (void)didPickColor:(UIColor *)color {
    [CSGUserPrefsKeys saveColor:color forCourseID:self.course.id sendToAPI:YES];
    self.tintColor = color;
}

@end