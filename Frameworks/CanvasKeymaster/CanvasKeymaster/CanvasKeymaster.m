//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import "CanvasKeymaster.h"
#import <objc/runtime.h>
#import "FXKeychain+CKMKeyChain.h"
@import ReactiveObjC;

@interface CanvasKeymaster ()

@end

@implementation CanvasKeymaster {
    RACSubject *_subjectForClientLogout, *_subjectForClientLogin, *_subjectForClientCannotLogInAutomatically;
    CKIClient *_currentClient;
    dispatch_once_t _once;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

+ (instancetype)theKeymaster
{
    static CanvasKeymaster *keymaster;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keymaster = [CanvasKeymaster new];
    });
    return keymaster;
}

#pragma mark - Creating/Loading Clients

- (void)setupWithClient:(CKIClient *)client {
    [self setCurrentClient:client];
    [[FXKeychain sharedKeychain] clearKeychain];
    [self->_subjectForClientLogin sendNext:client];
}

#pragma mark - Client Management

- (nullable CKIClient *)currentClient
{
    return _currentClient;
}

- (void)setCurrentClient:(CKIClient *)client
{
    @synchronized(self) {
        [_currentClient invalidateSessionCancelingTasks:YES];
        _currentClient = client;
    }
}

- (NSInteger)numberOfClients
{
    return [[FXKeychain sharedKeychain] clients].count;
}

@end


@implementation CKIClient (CanvasKeymaster)
+ (instancetype)currentClient
{
    return TheKeymaster.currentClient;
}
@end
