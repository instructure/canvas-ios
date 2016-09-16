//
//  CBITabCell.h
//  iCanvas
//
//  Created by derrick on 10/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBIColorfulViewModel;
@interface CBIColorfulCell : UITableViewCell
@property (nonatomic) CBIColorfulViewModel *viewModel;
@property (nonatomic, getter=isIconRound) BOOL roundIcon;

@property IBOutlet UIImageView *customIcon;
@property IBOutlet UILabel *customTitleLabel;
@property IBOutlet UILabel *customDetailLabel;

// called on tap and to reflect selection override as needed
// to reflect highlighted/selected state
- (void)updateHighlight;

@property (nonatomic) UIView *highlightedAccessoryView;
@property (nonatomic) UIView *nonHighlightedAccessoryView;

@end
