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

open class FetchedDetailsCollection<M, DVM>: Collection where M: NSManagedObject, DVM: Equatable {
    public typealias Object = DVM

    var disposable: Disposable?
    let observer: ManagedObjectObserver<M>
    let detailsFactory: (M)->[DVM]
    var details: [DVM] = []
    open let collectionUpdates: Signal<[CollectionUpdate<DVM>], NoError>
    fileprivate let updatesObserver: Observer<[CollectionUpdate<DVM>], NoError>
    
    public init(observer: ManagedObjectObserver<M>, detailsFactory: @escaping (M)->[DVM]) {
        self.observer = observer
        self.detailsFactory = detailsFactory
        
        (collectionUpdates, updatesObserver) = Signal.pipe()
        
        details = self.observer.object.map(detailsFactory) ?? []
        disposable = observer.signal
            .map { $0.1 }
            .observe(on: UIScheduler())
            .map { $0.map(detailsFactory) ?? [] }
            .observeValues { [weak self] deets in
                if let me = self {
                    me.details = deets
                    me.updatesObserver.send(value: [.reload])
                }
            }
    }
    
    // keeping it simple... 1 section
    open func numberOfSections() -> Int {
        return 1
    }
    
    open func titleForSection(_ section: Int) -> String? {
        return nil
    }
    
    open func numberOfItemsInSection(_ section: Int) -> Int {
        return details.count
    }
    
    open subscript(indexPath: IndexPath) -> DVM {
        return details[indexPath.row]
    }
}

