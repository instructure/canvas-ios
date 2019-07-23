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
import ReactiveSwift
import CanvasCore
import Core

func colorfulToDoViewModel(session: Session, toDoItem: Todo) -> ColorfulViewModel {
    struct DateFormatters {
        static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            let dateFormat = DateFormatter.dateFormat(fromTemplate: "EdMMM", options: 0, locale: Locale.current)
            formatter.dateFormat = dateFormat
            return formatter
        }()

        static var timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }()
    }
    

    func subtitle(forToDoItem toDoItem: Todo) -> String {
        switch toDoItem.type {
        case "grading":
            let gradingCount = toDoItem.needsGradingCount?.intValue ?? 0
            if gradingCount == 1 {
                return String(format: NSLocalizedString("1 needs grading", comment: "Label indicating a submission need grading"))
            } else if gradingCount > 1 {
                return String(format: NSLocalizedString("%@ need grading", comment: "Label indicating multiple submissions need grading"), "\(gradingCount)")
            } else {
                return ""
            }
        case "submitting":
            if let dueDate = toDoItem.assignmentDueDate {
                return String(format: NSLocalizedString("Due: %@ at %@", comment: "Due date label for to do items, first placeholder is date, second is time"), DateFormatters.dateFormatter.string(from: dueDate), DateFormatters.timeFormatter.string(from: dueDate))
            } else {
                return NSLocalizedString("No Due Date", comment: "Label shown for a to do that doesn't have a due date")
            }
        default:
            return ""
        }
    }

    var vm = ColorfulViewModel(features: [.icon, .subtitle, .token])
    vm.titleLineBreakMode = .byWordWrapping
    vm.title.value = toDoItem.assignmentName
    vm.subtitle.value = subtitle(forToDoItem: toDoItem)
    
    let context = session.enrollmentsDataSource.producer(toDoItem.contextID)

    vm.color <~ session.enrollmentsDataSource.color(for: toDoItem.contextID)
    vm.tokenViewText <~ context.map { $0?.shortName ?? "" }

    if toDoItem.todoType == .quiz {
        vm.icon.value = .icon(.quiz)
    } else if toDoItem.todoType == .discussion {
        vm.icon.value = .icon(.discussion)
    } else {
        vm.icon.value = .icon(.assignment)
    }

    return vm
}

class ToDoListViewController: FetchedTableViewController<Todo>, PageViewEventViewControllerLoggingProtocol {

    @objc let session: Session
    @objc let route: (UIViewController, URL)->()

    @objc init(session: Session, route: @escaping (UIViewController, URL)->()) throws {
        self.session = session
        self.route = route
        super.init()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0

        self.emptyView = Bundle.main.loadNibNamed("ToDoEmptyView", owner: self, options: nil)?.first as? UIView
        prepare(try Todo.allTodos(session), refresher: try Todo.refresher(session)) { todo in colorfulToDoViewModel(session: session, toDoItem: todo) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("To Do", comment:"Title of the Todo screen")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/to-do", attributes: ["customPageViewPath": "/"])
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Done", comment: "Button title to mark a to do item as done")) { (action, indexPath) in
            let todo = self.collection[indexPath]
            tableView.setEditing(false, animated: true)
            todo.markAsDone(self.session)
        }
        action.backgroundColor = UIColor.prettyErrorColor()
        return [action]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = collection[indexPath]
        CanvasAnalytics.logEvent("todo_selected")
        if let url = URL(string: todo.routingURL) {
            route(self, url)
        }
    }
}
