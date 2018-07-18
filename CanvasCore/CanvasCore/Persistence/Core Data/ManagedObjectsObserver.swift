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

import Foundation
import CoreData
import ReactiveSwift
import Result

/** Allows you to track and lookup a set of objects from a FetchedCollection
 by some uniqueID
 */
open class ManagedObjectsObserver<M: NSManagedObject, ID: Hashable> {
    open let collection: FetchedCollection<M>
    fileprivate let idFunction: (M)->ID
    fileprivate var propertiesByID: [ID: MutableProperty<M?>] = [:]
    fileprivate let scheduler: ManagedObjectContextScheduler
    
    fileprivate var collectionUpdatesDisposable: Disposable?
    
    public init(context: NSManagedObjectContext, collection: FetchedCollection<M>, idFunction: @escaping (M)->ID) {
        self.collection = collection
        self.idFunction = idFunction
        self.scheduler = ManagedObjectContextScheduler(context: context)
        for m in collection {
            propertiesByID[idFunction(m)] = MutableProperty(m)
        }
        
        collectionUpdatesDisposable = collection
            .collectionUpdates
            .observe(on:    scheduler)
            .observeValues { [weak self] updates in
                self?.processUpdates(updates)
            }.map(ScopedDisposable.init)
    }
    
    fileprivate func sendUpdate(for model: M?, withID id: ID) {
        if let property = propertiesByID[id] {
            property.value = model
        } else {
            let property = MutableProperty(model)
            propertiesByID[id] = property
        }
    }
    
    fileprivate func processUpdates(_ updates: [CollectionUpdate<M>]) {
        for update in updates {
            switch update {
            case .updated(_, let m, _):
                sendUpdate(for: m, withID: idFunction(m))
            case .inserted(_, let m, _):
                sendUpdate(for: m, withID: idFunction(m))
            case .deleted(_, let m, _):
                sendUpdate(for: nil, withID: idFunction(m))
            default: break
            }
        }
        countProperty.value = collection.count
    }
    
    open func producer(_ id: ID) -> SignalProducer<M?, NoError> {
        return SignalProducer<ID, NoError>(value: id)
            .observe(on: scheduler)
            .flatMap(.latest) { [weak self] (id: ID) -> SignalProducer<M?, NoError> in
                guard let me = self else { return .empty }
                if let property = me.propertiesByID[id] {
                    return property.producer
                } else {
                    let property = MutableProperty<M?>(nil)
                    me.propertiesByID[id] = property
                    return property.producer
                }
        }
    }
    
    open subscript(id: ID) -> M? {
        return propertiesByID[id]?.value
    }
    
    fileprivate let countProperty = MutableProperty<Int>(0)
    
    open var count: SignalProducer<Int, NoError> {
        return countProperty.producer.uniqueValues()
    }
}
