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

//
// CKIMediaComment.h
// Created by Jason Larsen on 5/8/14.
//

#import <Foundation/Foundation.h>
#import "CKIModel.h"

extern NSString * const CKIMediaCommentMediaTypeAudio;
extern NSString * const CKIMediaCommentMediaTypeVideo;

@interface CKIMediaComment : CKIModel

/**
* The ID of this piece of media. Identical to the id property,
* it's just that the JSON media comment object doesn't have an ID
* property, and only has a mediaID property, so this is here for
* a little API consistency.
*/
@property (nonatomic, copy) NSString *mediaID;

/**
* The type of content, example: "audio/mp4" or "video/mp4".
*/
@property (nonatomic, copy) NSString *contentType;

/**
* The type of media: "audio" or "video".
*/
@property (nonatomic, copy) NSString *mediaType;

/**
* The name to display for the media comment.
*/
@property (nonatomic, copy) NSString *displayName;

/**
* The URL to download the media comment file, whether it
* be an image, video, or audio.
*/
@property (nonatomic, strong) NSURL *url;

@end