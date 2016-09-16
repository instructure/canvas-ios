//
//  UITableView+in_backgroundImage.h
//  iCanvas
//
//  Created by BJ Homer on 11/7/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

// Inserting the '_' in these method names to avoid method name collisions

@interface UITableViewCell (ic_backgroundImage)
@property (nonatomic) UIImage *icBackgroundImage;
@property (nonatomic) UIImage *icBackgroundHighlightedImage;
@end

@interface UITableView (ic_backgroundImage)
@property (nonatomic) UIImage *icBackgroundImage;
@end

@interface UILabel (ic_textColor)
@property (nonatomic) UIColor *icTextColor;
@end
