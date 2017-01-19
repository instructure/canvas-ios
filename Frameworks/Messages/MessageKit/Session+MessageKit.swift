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
    
    

import TooLegit
import SoPersistent
import CoreData

let messageKitModelName = "MessageKit"
let messageKitSubdomain = "MessageKit"
let messageKitFailedToLoadErrorCode = 10001
let messageKitFailedToLoadErrorDescription = "Failed to load \(messageKitModelName) NSManagedObjectModel"
let messageKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the MessageKit database file.", comment: "MessageKit database load failure message")

extension Session {
    public func messagesManagedObjectContext() throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: messageKitModelName, inBundle: Bundle(for: Conversation.self))!.mutableCopy() as! NSManagedObjectModel
        let storeID = StoreID(storeName: messageKitModelName, model: model, localizedErrorDescription: messageKitDBFailedToLoadErrorDescription)
        return try managedObjectContext(storeID)
    }
}
