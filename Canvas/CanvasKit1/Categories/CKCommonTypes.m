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
    
    

#include "CKCommonTypes.h"

CKContextType contextTypeFromString(NSString *contextString) {
    contextString = [contextString lowercaseString];
    if ([@"course" isEqualToString:contextString]) {
        return CKContextTypeCourse;
    }
    else if ([@"group" isEqualToString:contextString]) {
        return CKContextTypeGroup;
    }
    else if ([@"user" isEqualToString:contextString]) {
        return CKContextTypeUser;
    }
    else {
        return CKContextTypeNone;
    }
}



// This category isn't actually implemented anywhere; it's just declared here
// so that the compiler will know how to call -ident
@interface NSObject (CKIdentity_Internal)
- (uint64_t)ident;
@end

@implementation NSObject (CKIdentity)

- (BOOL)hasSameIdentityAs:(id)object {

    if ([self respondsToSelector:@selector(ident)] && [object respondsToSelector:@selector(ident)]) {
        return [self ident] == [object ident];
    }
    else {
        return [self isEqual:object];
    }
}

@end