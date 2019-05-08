//
// Copyright (C) 2017-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
