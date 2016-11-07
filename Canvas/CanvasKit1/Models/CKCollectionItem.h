//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
