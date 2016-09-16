//
//  CKCollectionItem.h
//  CanvasKit
//
//  Created by Joshua Dutton on 6/7/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKUser;

typedef enum {
    CKCollectionItemTypeURL = 0
} CKCollectionItemType;

@interface CKCollectionItem : CKModelObject

@property (nonatomic) uint64_t ident;
@property (nonatomic) uint64_t collectionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) CKUser *author;
@property (nonatomic) CKCollectionItemType itemType;
@property (nonatomic, copy) NSDate *dateCreated;
@property (nonatomic, copy) NSURL *linkURL;
@property (nonatomic) int postCount;
@property (nonatomic) int upvoteCount;
@property (nonatomic) BOOL hasUpvoteByUser;
@property (nonatomic) uint64_t rootItemId;
@property (nonatomic) BOOL isImagePending;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *htmlPreview;
@property (nonatomic, copy) NSString *authorComment;
@property (nonatomic, copy) NSURL *URL;

@property (nonatomic, readonly) NSString *timeSinceCreation;
@property (nonatomic, strong) NSArray *comments;

// Set in DEBUG only - for unit testing
@property (nonatomic, strong) NSDictionary *rawInfo;

- (id)initWithInfo:(NSDictionary *)info;
- (void)updateWithInfo:(NSDictionary *)info; 

@end
