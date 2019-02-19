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
