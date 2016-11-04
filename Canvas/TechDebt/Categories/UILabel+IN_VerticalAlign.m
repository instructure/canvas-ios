
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
    
    

#import "UILabel+IN_VerticalAlign.h"

@implementation UILabel (IN_VerticalAlign)

- (void)alignTop
{
    // Code snippet borrowed from a SO answer on vertial alignment of a UILabel
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:self.font} context:nil];
    CGSize theStringSize = rect.size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

@end
