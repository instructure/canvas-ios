
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
    
    

#import "UIWebView+LinkProcessing.h"

@implementation UIWebView (LinkProcessing)
- (void)replaceYoutubeLinksWithInlineVideo
{
    NSString *htmlString = [self stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    // Check to see if there is an embedded calendar in the page. If there is the YouTube embed link javascript will cause a crash.
    // For now a YouTube link won't be embedded in the page if there is also a google calendar on the page but it will prevent the crash
    if ([htmlString rangeOfString:@"www.google.com/calendar/embed"].location == NSNotFound) {
        NSString *jsReplaceLinkCode =
        @"var body = document.body;"
        @"body.innerHTML = body.innerHTML.replace("
        @"/(?:<a.+)?(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com|youtu\\.be)\\/(?:watch\\?v=)?([\\w\\-]{10,12})(?:&feature=related)?(?:[\\w\\-]{0})?(?:.+(<\\/a>))?/g, "
        @"'<iframe webkit-playsinline width=\"356\" height=\"200\" src=\"https://www.youtube.com/embed/$1?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>'"
        @");";
        
        [self stringByEvaluatingJavaScriptFromString:jsReplaceLinkCode];
    }
}
@end
