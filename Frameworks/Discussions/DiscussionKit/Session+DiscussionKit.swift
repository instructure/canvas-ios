//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import FileKit

let discussionKitModelName = "DiscussionKit"
let discussionKitSubdomain = "DiscussionKit"
let discussionKitFailedToLoadErrorCode = 10001
let discussionKitFailedToLoadErrorDescription = NSLocalizedString("Failed to load \(discussionKitModelName) NSManagedObjectModel", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.DiscussionKit")!, value: "", comment: "Error Message when the app can't load an object model from the database")
let discussionKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the DiscussionKit database file.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.DiscussionKit")!, value: "", comment: "DiscussionKit Database Load Failure Message")

extension Session {
    public func discussionsManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: discussionKitModelName, inBundle: Bundle(for: DiscussionTopic.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: discussionKitSubdomain, code: discussionKitFailedToLoadErrorCode, title: discussionKitFailedToLoadErrorDescription, description: discussionKitFailedToLoadErrorDescription)
        }
        let withFiles = model.loadingFileEntity()

        let storeName = scope == nil ? discussionKitModelName : "\(discussionKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: withFiles,
                              localizedErrorDescription: discussionKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

