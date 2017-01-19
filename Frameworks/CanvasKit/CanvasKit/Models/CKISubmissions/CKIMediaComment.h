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