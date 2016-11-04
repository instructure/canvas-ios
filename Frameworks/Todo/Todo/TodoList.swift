
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
    
    

import UIKit

import TodoKit
import SoPersistent
import TooLegit

struct TodoViewModel: TableViewCellViewModel {
    let name: String
    let subtitle: String

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "TodoCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "TodoCell")
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TodoCell", forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }

    init(todo: Todo) {
        name = todo.assignmentName
        subtitle = todo.assignmentDueDate.flatMap({ NSDateFormatter.MediumStyleDateTimeFormatter.stringFromDate($0)}) ?? "No Due Date"
    }
}

class TodoList: Todo.TableViewController {

    let session: Session

    init(session: Session) throws {
        self.session = session
        super.init()

        let collection = try Todo.allTodos(session)
        let refresher = try Todo.refresher(session)
        prepare(collection, refresher: refresher, viewModelFactory: TodoViewModel.init)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = collection[indexPath]
        print(todo.routingURL)
    }
}
