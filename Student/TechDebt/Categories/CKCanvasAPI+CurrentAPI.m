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

#import "CKCanvasAPI+CurrentAPI.h"
@import CanvasKit;

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
