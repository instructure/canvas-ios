//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKIClient.h"

@class CKICourse;
@class CKIFolder;
@class RACSignal;

@interface CKIClient (CKIFolder)

/**
 Fetch a folder with a specific ID.
 
 @param folderID the ID of the folder to fetch
 */
- (RACSignal *)fetchFolder:(NSString *)folderID;

/**
 This method fetches the root folder for a given context 
 if it exists. If a root folder is returned it can be used
 to fetch the entire file tree.
 
 @param context the context to fetch the root folder for
 (course, group, etc)
 */

- (RACSignal *)fetchRootFolderForContext:(id <CKIContext>)context;

/**
 Fetch the folders inside the given folder.
 
 @param folder the folder to fetch folders from
 */
- (RACSignal *)fetchFoldersForFolder:(CKIFolder *)folder;

/**
 Fetch the files in the given folder.
 
 @param folder the folder to fetch files from
 */
- (RACSignal *)fetchFilesForFolder:(CKIFolder *)folder;


- (RACSignal *)fetchFolder:(NSString *)folderID withContext:(id<CKIContext>)context;

/**
 Delete the folder
 
 @param folder the folder you want to delete
 */
- (RACSignal *)deleteFolder:(CKIFolder *)folder;

/**
 Creates a folder in the given parent folder
 
 @param folder the folder to create
 @prarm parentFolder the folder the new folder will be created in
 */
- (RACSignal *)createFolder:(CKIFolder *)folder InFolder:(CKIFolder *)parentFolder;

@end
