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
    
    

#import "CKFolder.h"
#import "NSDictionary+CKAdditions.h"
#import "ISO8601DateFormatter.h"

//{
//   "context_type":"Course",
//   "context_id":1401,
//   "locked":null,
//   "files_count":0,
//   "position":3,
//   "updated_at":"2012-07-06T14:58:50Z",
//   "folders_url":"http://www.example.com/api/v1/folders/2937/folders",
//   "files_url":"http://www.example.com/api/v1/folders/2937/files",
//   "full_name":"course files/11folder",
//   "lock_at":null,
//   "id":2937,
//   "folders_count":0,
//   "name":"11folder",
//   "parent_folder_id":2934,
//   "created_at":"2012-07-06T14:58:50Z",
//   "unlock_at":null
//}

@implementation CKFolder

@synthesize ident = _ident;
@synthesize contextIdent = _contextIdent;
@synthesize contextType = _contextType;
@synthesize locked = _locked;
@synthesize filesCount = _filesCount;
@synthesize foldersCount = _foldersCount;
@synthesize foldersURL = _foldersURL;
@synthesize filesURL = _filesURL;
@synthesize sortingPosition = _sortingPosition;
@synthesize name = _name;
@synthesize fullName = _fullName;
@synthesize parentFolderIdent = _parentFolderIdent;
@synthesize creationDate = _creationDate;
@synthesize unlockAtDate = _unlockAtDate;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        _ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];

        _contextType = _contextTypeForTypeString([info objectForKeyCheckingNull:@"context_type"]);
        _contextIdent = [[info objectForKeyCheckingNull:@"context_id"] stringValue];
        
        _locked = [[info objectForKeyCheckingNull:@"locked"] boolValue];
        _lockedForUser = [[info objectForKeyCheckingNull:@"locked_for_user"] boolValue];
        
        _filesCount = [[info objectForKeyCheckingNull:@"files_count"] unsignedIntValue];
        _foldersCount = [[info objectForKeyCheckingNull:@"folders_count"] unsignedIntValue];
        
        NSString *foldersURLStr = [info objectForKeyCheckingNull:@"folders_url"];
        if (foldersURLStr) {
            _foldersURL = [NSURL URLWithString:foldersURLStr];
        }
        
        NSString *filesURLStr = [info objectForKeyCheckingNull:@"files_url"];
        if (filesURLStr) {
            _filesURL = [NSURL URLWithString:filesURLStr];
        }
        
        _sortingPosition = [[info objectForKeyCheckingNull:@"position"] unsignedIntValue];
        
        _name = [info objectForKeyCheckingNull:@"name"];
        _fullName = [info objectForKeyCheckingNull:@"full_name"];
        
        _parentFolderIdent = [[info objectForKeyCheckingNull:@"parent_folder_id"] unsignedLongLongValue];
        
        ISO8601DateFormatter *dateFormatter = [ISO8601DateFormatter new];
        
        NSString *creationDateStr = [info objectForKeyCheckingNull:@"created_at"];
        if (creationDateStr) {
            _creationDate = [dateFormatter dateFromString:creationDateStr];
        }
        NSString *unlockAtStr = [info objectForKeyCheckingNull:@"unlock_at"];
        if (unlockAtStr) {
            _unlockAtDate = [dateFormatter dateFromString:unlockAtStr];
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CKFolder *copiedFolder = [[[self class] alloc] init];
    
    copiedFolder->_ident = _ident;
    copiedFolder->_contextType = _contextType;
    copiedFolder->_contextIdent = _contextIdent;
    copiedFolder->_locked = _locked;
    copiedFolder->_filesCount = _filesCount;
    copiedFolder->_foldersCount = _foldersCount;
    copiedFolder->_foldersURL = _foldersURL;
    copiedFolder->_filesURL = _filesURL;
    copiedFolder->_sortingPosition = _sortingPosition;
    copiedFolder->_name = _name;
    copiedFolder->_fullName = _fullName;
    copiedFolder->_parentFolderIdent = _parentFolderIdent;
    copiedFolder->_creationDate = _creationDate;
    copiedFolder->_unlockAtDate = _unlockAtDate;

    return copiedFolder;
}

static CKContextType _contextTypeForTypeString(NSString *typeStr) {
    if ([@"Course" isEqualToString:typeStr]) {
        return CKContextTypeCourse;
    }
    else if ([@"Group" isEqualToString:typeStr]) {
        return CKContextTypeGroup;
    }
    else if ([@"User" isEqualToString:typeStr]) {
        return CKContextTypeUser;
    }
    else if (typeStr != nil) {
        NSLog(@"Unexpected context type: %@", typeStr);
    }
    return CKContextTypeNone;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (path = %@)", [super description], _fullName];
}


- (NSUInteger)hash {
    return (NSUInteger)_ident;
}

@end
