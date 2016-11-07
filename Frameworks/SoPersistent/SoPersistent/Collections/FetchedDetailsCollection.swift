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
import CoreData
import ReactiveCocoa
import Result

public class FetchedDetailsCollection<M, DVM where M: NSManagedObject, DVM: Equatable>: Collection {
    public typealias Object = DVM

    var disposable: Disposable?
    let observer: ManagedObjectObserver<M>
    let detailsFactory: M->[DVM]
    var details: [DVM] = []
    public let collectionUpdates: Signal<[CollectionUpdate<DVM>], NoError>
    private let updatesObserver: Observer<[CollectionUpdate<DVM>], NoError>
    
    public init(observer: ManagedObjectObserver<M>, detailsFactory: M->[DVM]) {
        self.observer = observer
        self.detailsFactory = detailsFactory
        
        (collectionUpdates, updatesObserver) = Signal.pipe()
        
        details = self.observer.object.map(detailsFactory) ?? []
        disposable = observer.signal
            .map { $0.1 }
            .observeOn(UIScheduler())
            .map { $0.map(detailsFactory) ?? [] }
            .observeNext { [weak self] deets in
                if let me = self {
                    let edits = me.details.distanceTo(deets)
                    me.details = deets
                    let updates: [CollectionUpdate<DVM>] = edits.map { edit in
                        switch edit {
                        case .Insert(let item, let index):
                            return .Inserted(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Replace(let item, let index):
                            return .Updated(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Delete(let item, let index):
                            return .Deleted(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Move(let item, let fromIndex, let toIndex):
                            return .Moved(NSIndexPath(forRow: fromIndex, inSection: 0), NSIndexPath(forRow: toIndex, inSection: 0), item)
                        }
                    }
                    me.updatesObserver.sendNext(updates)
                }
            }
    }
    
    // keeping it simple... 1 section
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func titleForSection(section: Int) -> String? {
        return nil
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return details.count
    }
    
    public subscript(indexPath: NSIndexPath) -> DVM {
        return details[indexPath.row]
    }
}

