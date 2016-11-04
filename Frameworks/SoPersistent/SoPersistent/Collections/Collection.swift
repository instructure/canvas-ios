
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

public enum CollectionUpdate<Model>: CustomStringConvertible, Equatable {
    case SectionInserted(Int)
    case SectionDeleted(Int)
    
    case Inserted(NSIndexPath, Model)
    case Updated(NSIndexPath, Model)
    case Moved(NSIndexPath, NSIndexPath, Model)
    case Deleted(NSIndexPath, Model)
    
    case Reload
    
    func map<U>(f: Model throws -> U) rethrows -> CollectionUpdate<U> {
        switch self {
        case .SectionInserted(let s): return .SectionInserted(s)
        case .SectionDeleted(let s): return .SectionDeleted(s)
            
        case let .Inserted(ip, m): return .Inserted(ip, try f(m))
        case let .Updated(ip, m): return .Updated(ip, try f(m))
        case let .Moved(fromIP, toIP, m): return .Moved(fromIP, toIP, try f(m))
        case let .Deleted(ip, m): return .Deleted(ip, try f(m))
            
        case .Reload: return .Reload
        }
    }
    
    public var description: String {
        switch self {
        case .SectionInserted(let i): return "CollectionUpdate: Section Inserted at Index \(i)"
        case .SectionDeleted(let i): return "CollectionUpdate: Section Deleted at Index \(i)"

        case let .Inserted(path, model): return "CollectionUpdate: \(model.dynamicType) Inserted at {\(path.section), \(path.item)}"
        case let .Updated(path, model): return "CollectionUpdate: \(model.dynamicType) Updated at {\(path.section), \(path.item)}"
        case let .Moved(from, to, model): return "CollectionUpdate: \(model.dynamicType) Moved from {\(from.section), \(from.item)} to {\(to.section), \(to.item)}"
        case let .Deleted(path, model): return "CollectionUpdate: \(model.dynamicType) Deleted from {\(path.section), \(path.item)}"
            
        case .Reload: return "CollectionUpdate: Reload"
        }
    }
}

public func ==<M>(lhs: CollectionUpdate<M>, rhs: CollectionUpdate<M>) -> Bool {

    switch (lhs, rhs) {
    case let (.SectionInserted(i0), .SectionInserted(i1)) where i0 == i1: return true
    case let (.SectionDeleted(i0), .SectionDeleted(i1)) where i0 == i1: return true
        
    case let (.Inserted(path0, _), .Inserted(path1, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case let (.Updated(path0, _), .Updated(path1, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case let (.Moved(from0, to0, _), .Moved(from1, to1, _))
        where from0.section == from1.section &&
                 from0.item == from1.item &&
                to0.section == to1.section &&
                   to0.item == to1.item
        : return true
        
    case let (.Deleted(path0, _), .Deleted(path1, _)) where path0.section == path1.section && path0.item == path1.item: return true
        
    case (.Reload, .Reload): return true
        
    default: return false
    }
}

public protocol Collection: class {
    typealias Object
    
    func numberOfSections() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    
    func titleForSection(section: Int) -> String?
    
    subscript(indexPath: NSIndexPath) -> Object { get }

    var collectionUpdated: [CollectionUpdate<Object>] -> () { get set }
}
