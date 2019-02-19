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

@interface CKUser : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *loginId;
@property (nonatomic, strong) NSString *primaryEmail;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *sortableName;
@property (nonatomic, strong) NSString *sisLoginId;
@property (nonatomic, strong) NSString *sisUserId;
@property (nonatomic, strong) NSURL *avatarURL;

@property (strong) NSURL *calendarURL;
@property (nonatomic, strong) NSArray *collections;

@property BOOL loggedIn;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

@end
