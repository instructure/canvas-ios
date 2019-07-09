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