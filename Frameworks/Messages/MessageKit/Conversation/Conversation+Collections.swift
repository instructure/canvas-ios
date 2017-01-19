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
import ReactiveSwift
import CoreData

extension Conversation {
    public static func collection(_ session: Session) throws -> FetchedCollection<Conversation> {
        let context = try session.messagesManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(nil, sortDescriptors: ["workflowState".descending, "date".descending])
        )
    }

    public static func syncSignalProducer(_ session: Session) throws -> SignalProducer<Void, NSError> {
        let context = try session.messagesManagedObjectContext()
        let remote = try getConversations(session)
        return syncSignalProducer(inContext: context, fetchRemote: remote).map { _ in () }
    }

    public static func refresher(_ session: Session) throws -> Refresher {
        let context = try session.messagesManagedObjectContext()
        let sync = try syncSignalProducer(session)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: cacheKey(context))
    }

    open class TableViewController: FetchedTableViewController<Conversation> {
        open override func viewDidLoad() {
            super.viewDidLoad()
            tableView.estimatedRowHeight = 44
        }
    }
}
