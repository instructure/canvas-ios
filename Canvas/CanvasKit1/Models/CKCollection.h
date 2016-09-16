//
//  CKCollection.h
//  CanvasKit
//
//  Created by Stephen Lottermoser on 5/31/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKCollectionVisibilityPublic = 1,
    CKCollectionVisibilityPrivate = 2
} CKCollectionVisibility;

@interface CKCollection : CKModelObject

@property (nonatomic) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CKCollectionVisibility visibility;
@property (nonatomic) BOOL isFollowedByUser;
@property (nonatomic) int followersCount;
@property (nonatomic) int itemsCount;

@property (nonatomic, strong) NSArray *collectionItems;

// Set in DEBUG only - for unit testing
@property (nonatomic, strong) NSDictionary *rawInfo;

- (id)initWithInfo:(NSDictionary *)info;

@end
