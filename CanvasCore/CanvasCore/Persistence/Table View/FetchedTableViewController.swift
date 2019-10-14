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
import Core

open class FetchedTableViewController<M: NSManagedObject>: TableViewController {
    
    fileprivate (set) open var collection: FetchedCollection<M>!
    
    public override init() {
        super.init()
    }

    @objc public override init(style: UITableView.Style) {
        super.init(style: style)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func prepare<VM: TableViewCellViewModel>(_ collection: FetchedCollection<M>, refresher: Refresher? = nil, viewModelFactory: @escaping (M)->VM) {
        self.collection = collection
        self.refresher = refresher
        self.dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .named(tableView.style == .grouped ? .backgroundGrouped : .backgroundLightest)
        tableView.separatorInset = .zero
        tableView.separatorColor = .named(.borderMedium)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
}
