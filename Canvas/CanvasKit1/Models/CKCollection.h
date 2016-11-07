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
