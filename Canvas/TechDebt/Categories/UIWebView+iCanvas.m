//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "UIWebView+iCanvas.h"

@implementation UIWebView (iCanvas)

- (CGRect)rectForElementInWebviewWithId:(NSString *)domID {
    NSString *buttonCoordinates = [self stringByEvaluatingJavaScriptFromString:
                                   [NSString stringWithFormat:
                                    @"var button = document.getElementById('%@');"
                                    @"var rect = button.getBoundingClientRect();"
                                    @"'' + rect.left + ',' + rect.top + ',' + rect.width + ',' + rect.height",
                                    domID]];
    
    if (!buttonCoordinates || [buttonCoordinates isEqualToString:@""]) {
        return CGRectNull;
    }
    
    NSArray *comps = [buttonCoordinates componentsSeparatedByString:@","];
    CGFloat left = [comps[0] floatValue];
    CGFloat top = [comps[1] floatValue];
    CGFloat width = [comps[2] floatValue];
    CGFloat height = [comps[3] floatValue];
    
    return CGRectMake(left, top, width, height);
}

- (void)scalePageToFit
{
    NSInteger docWidth = [[self stringByEvaluatingJavaScriptFromString:@"$(document).width()"] integerValue];
    
    if (docWidth == 0) {
        return;
    }
    
    CGFloat scale = self.bounds.size.width / docWidth;
    
    // fix scale
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
                                                  @"metaElement = document.querySelector('meta[name=viewport]');"
                                                  @"if (metaElement == null) { metaElement = document.createElement('meta'); }"
                                                  @"metaElement.name = \"viewport\";"
                                                  @"metaElement.content = \"minimum-scale=%.2f, initial-scale=%.2f, maximum-scale=1.0, user-scalable=yes\";"
                                                  @"var head = document.getElementsByTagName('head')[0];"
                                                  @"head.appendChild(metaElement);", scale, scale]];
}

- (void)scaleiFrameToFit
{
    
}

- (BOOL)allowsInlineMediaPlayback { return YES; }

@end
