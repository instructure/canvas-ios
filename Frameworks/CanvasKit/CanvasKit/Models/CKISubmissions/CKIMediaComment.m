//
// CKIMediaComment.m
// Created by Jason Larsen on 5/8/14.
//

#import "CKIMediaComment.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

NSString * const CKIMediaCommentMediaTypeAudio = @"audio";
NSString * const CKIMediaCommentMediaTypeVideo = @"video";

@interface CKIMediaComment ()

@end

@implementation CKIMediaComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
            @"id": @"media_id",
            @"mediaID" : @"media_id",
            @"displayName" : @"display_name",
            @"contentType" : @"content-type", // watch the - !
            @"mediaType" : @"media_type",
            @"url" : @"url"
    };
    NSDictionary *superPaths = [super JSONKeyPathsByPropertyKey];
    return [superPaths dictionaryByAddingObjectsFromDictionary:keyPaths];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

// override the CKIModel version because mediaID is already a string
+ (NSValueTransformer *)idJSONTransformer {
    return nil;
}

@end