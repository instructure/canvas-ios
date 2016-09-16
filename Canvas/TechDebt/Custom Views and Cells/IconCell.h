//
//  IconCell.h
//  iCanvas
//
//  Created by derrick on 5/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit1/CanvasKit1.h>

@interface IconCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *leftSideContainerView;
@property (nonatomic) IBOutlet CKRemoteImageView *orangeImageView;
@property (nonatomic) IBOutlet CKRemoteImageView *whiteImageView;
@property (nonatomic) CGFloat imageViewWidth;

@property (nonatomic) CGFloat cellPadding;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic) BOOL allWhiteStyle;
@end


@interface IconCell (ModuleItemCell)
@property (nonatomic) BOOL sequentialChecked;
@property (nonatomic) BOOL sequentialUnchecked;
@end


@interface UITableView (IconCell)
- (void)registerIconCellForReuse;
- (IconCell *)dequeueReusableIconCellForIndexPath:(NSIndexPath *)indexPath;
@end