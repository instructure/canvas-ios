//
//  CKCanvasAPI+CurrentAPI.m
//  Canvas
//
//  Created by Derrick Hathaway on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "CKCanvasAPI+CurrentAPI.h"
@import CanvasKeymaster;

static CKCanvasAPI *_currentAPI;

@implementation CKCanvasAPI (CurrentAPI)

+ (CKCanvasAPI *)currentAPI {
    return _currentAPI;
}

+ (void)updateCurrentAPI {
    if (_currentAPI) {
        [CKCanvasURLConnection abortAllConnections];
    }
    CKIClient *client = [CKIClient currentClient];
    
    _currentAPI = [[CKCanvasAPI alloc] init];
    _currentAPI.hostname = client.baseURL.host;
    _currentAPI.apiProtocol = @"https";
    _currentAPI.accessToken = client.accessToken;
    _currentAPI.actAsId = client.actAsUserID;
    
    CKUser *legacyUser = [[CKUser alloc] initWithInfo:[client.currentUser JSONDictionary]];
    _currentAPI.user = legacyUser;
    
    // Populate the media server information after we are up and running
    [_currentAPI getMediaServerConfigurationWithBlock:^(NSError *error, BOOL done) {
        if (error) {
            NSLog(@"There was an error getting the media server configuration: %@",error);
        }
    }];
}

@end
