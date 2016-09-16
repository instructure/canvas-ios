//
//  ProgressTableViewCell.m
//  iCanvas
//
//  Created by Mark Suman on 11/11/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "ProgressTableViewCell.h"

@implementation ProgressTableViewCell

@synthesize progressMessage, activityIndicator;

+ (NSString *)cellIdentifier {
    return @"ProgressCell";
}

+ (UINib *)cellNib {
    static UINib *cellNib;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellNib = [UINib nibWithNibName:@"LoadingCell" bundle:[NSBundle bundleForClass:self]];
    });
    return cellNib;
}



- (id)init {
    self = [[[self class] cellNib] instantiateWithOwner:nil options:nil][0];
    return self;
}

@end
