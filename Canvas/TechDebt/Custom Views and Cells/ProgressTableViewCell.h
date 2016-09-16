//
//  ProgressTableViewCell.h
//  iCanvas
//
//  Created by Mark Suman on 11/11/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "CNVTableViewCell.h"

@interface ProgressTableViewCell : CNVTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *progressMessage;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

+ (NSString *)cellIdentifier;
+ (UINib *)cellNib;

@end
