//
// Copyright (C) 2016-present Instructure, Inc.
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

#import "CKIModel.h"

@interface CKIAttachment : CKIModel
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic) NSUInteger size;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *unlockAt;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL hiddenForUser;
@property (nonatomic) BOOL lockedForUser;
@property (nonatomic, copy) NSURL *thumbnailURL;
@end
