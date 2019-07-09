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


open class FetchedCollectionViewController<M: NSManagedObject>: CollectionViewController {
    
    fileprivate (set) open var collection: FetchedCollection<M>!
    
    public override init() {
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func prepare<VM: CollectionViewCellViewModel>(_ collection: FetchedCollection<M>, refresher: Refresher? = nil, viewModelFactory: @escaping (M)->VM) {
        self.collection = collection
        self.refresher = refresher
        dataSource = CollectionCollectionViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
    }
}
