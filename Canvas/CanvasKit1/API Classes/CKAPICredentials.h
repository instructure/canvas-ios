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
#import "CKCanvasAPI.h"

@interface CKAPICredentials : NSObject

@property (copy) NSString *userName;
@property (assign) uint64_t userIdent;
@property (copy) NSString *hostname;
@property (copy) NSString *apiProtocol;
@property (copy) NSString *accessToken;
@property (copy) NSString *actAsId;

+ (CKAPICredentials *)apiCredentialsFromKeychain;
+ (void)deleteCredentialsFromKeychain;
- (void)saveToKeychain;

// YES if all of the above properties are set (except actAsId), else NO;
- (BOOL)isValid;

- (BOOL)isEqual:(id)object;

@end
