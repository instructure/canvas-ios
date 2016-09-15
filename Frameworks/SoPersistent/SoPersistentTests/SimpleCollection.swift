//
//  SimpleCollection.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

class SimpleCollection: Collection {
    struct CollectionItem {}

    typealias Object = CollectionItem

    var collectionUpdated: [CollectionUpdate<CollectionItem>] -> () = { _ in }

    init() {}

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfItemsInSection(section: Int) -> Int {
        return 0
    }

    func titleForSection(section: Int) -> String? {
        return nil
    }

    subscript(indexPath: NSIndexPath) -> CollectionItem {
        return CollectionItem()
    }
}
