//
//  SimpleTableViewDataSource.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

class SimpleTableViewDataSource: NSObject, TableViewDataSource {
    var viewDidLoadWasCalled = false
    var collectionDidChange: (Void)->Void = { }
    
    func viewDidLoad(controller: UITableViewController) {
        viewDidLoadWasCalled = true
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func isEmpty() -> Bool {
        return true
    }
}
