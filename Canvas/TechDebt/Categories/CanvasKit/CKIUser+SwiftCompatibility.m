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
    
    

//
//  CKIUser+SwiftCompatibility.m
//  
//
//  Created by Nathan Perry on 7/30/15.
//
//

#import "CKIUser+SwiftCompatibility.h"

@implementation CKIUser (SwiftCompatibility)

-(SessionUser *)swiftUser {
    return [[SessionUser alloc] initWithId:self.id name:self.name loginID:self.loginID sortableName:self.sortableName email:self.email avatarURL:self.avatarURL];
}

@end
