//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Foundation
import CoreData
import CanvasCore

let discussionKitModelName = "DiscussionKit"
let discussionKitSubdomain = "DiscussionKit"
let discussionKitFailedToLoadErrorCode = 10001
let discussionKitFailedToLoadErrorDescription = NSLocalizedString("Failed to load \(discussionKitModelName) NSManagedObjectModel",
    tableName: "Localizable",
    bundle: .core,
    value: "",
    comment: "Error Message when the app can't load an object model from the database")
let discussionKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the DiscussionKit database file.",
                                                                    tableName: "Localizable",
                                                                    bundle: .core,
                                                                    value: "",
                                                                    comment: "DiscussionKit Database Load Failure Message")

extension Session {
    @objc public func discussionsManagedObjectContext(_ scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: discussionKitModelName, inBundle: Bundle(for: DiscussionTopic.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: discussionKitSubdomain,
                          code: discussionKitFailedToLoadErrorCode,
                          title: discussionKitFailedToLoadErrorDescription,
                          description: discussionKitFailedToLoadErrorDescription)
        }
        let storeName = scope == nil ? discussionKitModelName : "\(discussionKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: model,
                              localizedErrorDescription: discussionKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}
