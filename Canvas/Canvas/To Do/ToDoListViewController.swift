//
//  ToDoListViewController.swift
//  iCanvas
//
//  Created by Brandon Pluim on 4/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import TodoKit
import SoPersistent
import SoPretty
import ReactiveCocoa
import SoLazy

func colorfulToDoViewModel(session session: Session, toDoItem: Todo) -> ColorfulViewModel {
    struct DateFormatters {
        static var dateFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            let dateFormat = NSDateFormatter.dateFormatFromTemplate("EdMMM", options: 0, locale: NSLocale.currentLocale())
            formatter.dateFormat = dateFormat
            return formatter
        }()

        static var timeFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .NoStyle
            formatter.timeStyle = .ShortStyle
            return formatter
        }()
    }

    func subtitle(forToDoItem toDoItem: Todo) -> String {
        switch toDoItem.type {
        case "grading":
            let gradingCount = toDoItem.needsGradingCount?.integerValue ?? 0
            if gradingCount == 1 {
                return String(format: NSLocalizedString("1 needs grading", comment: "Label indicating a submission need grading"))
            } else if gradingCount > 1 {
                return String(format: NSLocalizedString("%@ need grading", comment: "Label indicating multiple submissions need grading"), "\(gradingCount)")
            } else {
                return ""
            }
        case "submitting":
            if let dueDate = toDoItem.assignmentDueDate {
                return String(format: NSLocalizedString("Due: %@ at %@", comment: "Due date label for to do items, first placeholder is date, second is time"), DateFormatters.dateFormatter.stringFromDate(dueDate), DateFormatters.timeFormatter.stringFromDate(dueDate))
            } else {
                return NSLocalizedString("No Due Date", comment: "Label shown for a to do that doesn't have a due date")
            }
        default:
            return ""
        }
    }

    let vm = ColorfulViewModel(style: .Subtitle)
    vm.title.value = toDoItem.assignmentName
    vm.detail.value = subtitle(forToDoItem: toDoItem)
    vm.color <~ session.enrollmentsDataSource.producer(toDoItem.contextID).map { $0?.color ?? .prettyGray() }

    if toDoItem.submissionTypes.contains(.Quiz) {
        vm.icon.value = UIImage.techDebtImageNamed("icon_quizzes").imageWithRenderingMode(.AlwaysTemplate)
    } else if toDoItem.submissionTypes.contains(.DiscussionTopic) {
        vm.icon.value = UIImage.techDebtImageNamed("icon_discussions").imageWithRenderingMode(.AlwaysTemplate)
    } else {
        vm.icon.value = UIImage.techDebtImageNamed("icon_assignments").imageWithRenderingMode(.AlwaysTemplate)
    }

    return vm
}

class ToDoListViewController: Todo.TableViewController {

    let session: Session
    let route: (UIViewController, NSURL)->()

    init(session: Session, route: (UIViewController, NSURL)->()) throws {
        self.session = session
        self.route = route
        super.init()

        prepare(try Todo.allTodos(session), refresher: try Todo.refresher(session)) { todo in colorfulToDoViewModel(session: session, toDoItem: todo) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("To Do", comment:"Title of to do screen")
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Normal, title: NSLocalizedString("Done", comment: "Button title to mark a to do item as done")) { (action, indexPath) in
            let todo = self.collection[indexPath]
            tableView.setEditing(false, animated: true)
            todo.markAsDone(self.session)
        }
        action.backgroundColor = UIColor.prettyErrorColor()
        return [action]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = collection[indexPath]
        if let url = NSURL(string: todo.routingURL) {
            route(self, url)
        }
    }
}
