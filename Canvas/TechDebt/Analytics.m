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
    
    

#import "Analytics.h"
#import <Google/Analytics.h>

@implementation Analytics

+ (void)prepare {
    
    // Some open source clients might not use this at all
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"GoogleServices-Info" withExtension:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    if (!data) {
        return;
    }
    
    // Configure tracker from GoogleService-Info.plist. (included in Canvas Target)
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
}

+ (void)logScreenView:(NSString*)screenName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
@end

