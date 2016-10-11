//
// CSGCourseCell.h
// Created by Jason Larsen on 4/30/14.
//

#import <Foundation/Foundation.h>

@class CSGBadgeView;

@interface CSGCourseCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *courseNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *courseCodeLabel;
@property (nonatomic, weak) IBOutlet CSGBadgeView *needsGradingBadgeView;
@property (nonatomic, weak) IBOutlet UIView *courseColorView;
@property (nonatomic, weak) IBOutlet UIView *contentContainerView;

@property (nonatomic, strong) CKICourse *course;

- (void)didPickColor:(UIColor *)color;

@end