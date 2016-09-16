//
//  UIWebView+LinkProcessing.m
//  iCanvas
//
//  Created by Nathan Lambson on 7/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "UIWebView+LinkProcessing.h"

@implementation UIWebView (LinkProcessing)
- (void)replaceYoutubeLinksWithInlineVideo
{
    NSString *htmlString = [self stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    // Check to see if there is an embedded calendar in the page. If there is the YouTube embed link javascript will cause a crash.
    // For now a YouTube link won't be embedded in the page if there is also a google calendar on the page but it will prevent the crash
    if ([htmlString rangeOfString:@"www.google.com/calendar/embed"].location == NSNotFound) {
        [self stringByEvaluatingJavaScriptFromString:@"$('body').html(function(i, html) {return html.replace(/(?:<a.+)?(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com|youtu\\.be)\\/(?:watch\\?v=)?([\\w\\-]{10,12})(?:&feature=related)?(?:[\\w\\-]{0})?(?:.+(<\\/a>))?/g, '<iframe webkit-playsinline width=\"356\" height=\"200\" src=\"http://www.youtube.com/embed/$1?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>');});"];
    }
}
@end
