//
//  TodoList.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
