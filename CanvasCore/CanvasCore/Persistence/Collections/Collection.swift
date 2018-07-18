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
import ReactiveSwift
import Result

public enum CollectionUpdate<Model>: CustomStringConvertible, Equatable {
    case sectionInserted(Int)
    case sectionDeleted(Int)
    
    case inserted(IndexPath, Model, animated: Bool)
    case updated(IndexPath, Model, animated: Bool)
    case moved(IndexPath, IndexPath, Model, animated: Bool)
    case deleted(IndexPath, Model, animated: Bool)
    
    case reload
    
    func map<U>(_ f: (Model) throws -> U) rethrows -> CollectionUpdate<U> {
        switch self {
        case .sectionInserted(let s): return .sectionInserted(s)
        case .sectionDeleted(let s): return .sectionDeleted(s)
            
        case let .inserted(ip, m, animated): return .inserted(ip, try f(m), animated: animated)
        case let .updated(ip, m, animated): return .updated(ip, try f(m), animated: animated)
        case let .moved(fromIP, toIP, m, animated): return .moved(fromIP, toIP, try f(m), animated: animated)
        case let .deleted(ip, m, animated): return .deleted(ip, try f(m), animated: animated)
            
        case .reload: return .reload
        }
    }
    
    public var description: String {
        switch self {
        case .sectionInserted(let i): return "CollectionUpdate: Section Inserted at Index \(i)"
        case .sectionDeleted(let i): return "CollectionUpdate: Section Deleted at Index \(i)"

        case let .inserted(path, model, _): return "CollectionUpdate: \(type(of: model)) Inserted at {\(path.section), \(path.item)}"
        case let .updated(path, model, _): return "CollectionUpdate: \(type(of: model)) Updated at {\(path.section), \(path.item)}"
        case let .moved(from, to, model, _): return "CollectionUpdate: \(type(of: model)) Moved from {\(from.section), \(from.item)} to {\(to.section), \(to.item)}"
        case let .deleted(path, model, _): return "CollectionUpdate: \(type(of: model)) Deleted from {\(path.section), \(path.item)}"
            
        case .reload: return "CollectionUpdate: Reload"
        }
    }
}

public func ==<M>(lhs: CollectionUpdate<M>, rhs: CollectionUpdate<M>) -> Bool {

    switch (lhs, rhs) {
    case let (.sectionInserted(i0), .sectionInserted(i1)) where i0 == i1: return true
    case let (.sectionDeleted(i0), .sectionDeleted(i1)) where i0 == i1: return true
        
    case let (.inserted(path0, _, _), .inserted(path1, _, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case let (.updated(path0, _, _), .updated(path1, _, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case let (.moved(from0, to0, _, _), .moved(from1, to1, _, _))
        where from0.section == from1.section &&
                 from0.item == from1.item &&
                to0.section == to1.section &&
                   to0.item == to1.item
        : return true

    case let (.deleted(path0, _, _), .deleted(path1, _, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case (.reload, .reload): return true
        
    default: return false
    }
}

public protocol Collection: class {
    associatedtype Object
    
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    
    func titleForSection(_ section: Int) -> String?

    subscript(indexPath: IndexPath) -> Object { get }
    
    var collectionUpdates: Signal<[CollectionUpdate<Object>], NoError> { get }
}
