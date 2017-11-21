//
//  TodayViewController.swift
//  GradesWidget
//
//  Created by Garrett Richards on 11/9/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import NotificationCenter
import Foundation
import ReactiveSwift
import Result
import TechDebt
import CanvasCore
import ReactiveCocoa

fileprivate extension CanvasKeymaster {
    static func multipleClientsAreLoggedIn() -> Bool {
        return CanvasKeymaster.the().numberOfClients > 1
    }
    static func singleUserSession() -> Session? {
        if let client = CanvasKeymaster.the().currentClient, CanvasKeymaster.the().numberOfClients == 1 {
            return client.authSession
        }
        return nil
    }
}

class GradesTodayWidgetViewController: UIViewController, NCWidgetProviding, GradesWidgetErrorProtocol {
    
    fileprivate var session: Session?
    var tableViewController: GradesWidgetTableViewController?
    var errorViewController: ErrorViewController?
    var currentViewController: UIViewController?
    var refresher: Refresher?
    var heightDelegate: GradesWidgetHeightProtocol?
    var loginObserver: AnyObject?
    var logoutObserver: AnyObject?
    
    //  MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setupKeyMasterEvents()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        if (CanvasKeymaster.multipleClientsAreLoggedIn()) {
            let multipleUserError = NSLocalizedString("More than one user is logged into Canvas Student. To view your grades, launch the app.", comment: "")
            showError(errorMessage: multipleUserError)
        }
        else if let session  = CanvasKeymaster.singleUserSession() {
            showGrades(session: session)
            tableViewController?.refresh()
        }
        else {
            showError(errorMessage: NSLocalizedString("Log in with Canvas", comment: ""))
        }
    }
    
    func setupKeyMasterEvents() {
        guard loginObserver == nil else { return }
        loginObserver = CanvasKeymaster.the().signalForLogin.subscribeNext { [weak self] (client) in
            if let session = client?.authSession {
                if(self?.tableViewController == nil) {
                    self?.showGrades(session: session)
                }
            }
        }
    }
    
    fileprivate func showGrades(session: Session) {
        guard tableViewController == nil else { return }
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        if let viewController = viewControllerFromStoryboard(viewControllerIdentifier: String(describing: GradesWidgetTableViewController.self)) {
            tableViewController = viewController as? GradesWidgetTableViewController
            guard let tableViewController = tableViewController else { return }
            tableViewController.errorDelegate = self
            heightDelegate = tableViewController
            embedViewController(viewController: tableViewController)
        }
    }
    
    internal func showError(errorMessage: String) {
        if let errorViewController = viewControllerFromStoryboard(viewControllerIdentifier: String(describing: ErrorViewController.self)) as? ErrorViewController {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
            errorViewController.errorMessage = errorMessage
            embedViewController(viewController: errorViewController)
        }
    }
    
    //  MARK: - util
    
    private func viewControllerFromStoryboard(viewControllerIdentifier: String) -> UIViewController? {
        return UIStoryboard(name: "MainInterface", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: viewControllerIdentifier)
    }
 
    private func embedViewController(viewController: UIViewController) {
        if let current = currentViewController, current != viewController {
            current.willMove(toParentViewController: nil)
            current.view.removeFromSuperview()
            current.removeFromParentViewController()
        }
        
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        addConstraints(viewController.view)
        viewController.didMove(toParentViewController: self)
        currentViewController = viewController
    }
    
    func addConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        view.superview?.addConstraints(horizontalConstraints)
        view.superview?.addConstraints(verticalConstraints)
    }
    
    //  MARK: - widget
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if let heightDelegate = heightDelegate, activeDisplayMode == .expanded  {
            preferredContentSize = heightDelegate.widgetActiveDisplayModeDidChange(activeDisplayMode, withMaximumSize: maxSize)
        }
        else {
            preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
}

class GradeWidgetCell: UITableViewCell {
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
}

protocol GradesWidgetErrorProtocol {
    func showError(errorMessage: String)
}

protocol GradesWidgetHeightProtocol {
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) -> CGSize
}

extension GradesWidgetTableViewController: GradesWidgetHeightProtocol {
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) -> CGSize {
        if activeDisplayMode == .expanded {
            return CGSize(width: 0.0, height: Double(44 * tableView.numberOfRows(inSection: 0)) + 16.0)
        }
        else {
            return maxSize
        }
    }
}

class GradesWidgetTableViewController: TableViewController {
    
    public var errorDelegate: GradesWidgetErrorProtocol?
    private var collection: FetchedCollection<Course>?

    override func viewDidLoad() {
        super.viewDidLoad()
        preparTable()
        self.view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
    }
    
    func refresh() {
        refresher?.refresh(false)
    }
    
    private func preparTable() {
        if let client = CanvasKeymaster.the().currentClient {
            let session = client.authSession
            do {
                collection = try Course.allCoursesCollection(session)
                if let collection = collection {
                    dataSource = CollectionTableViewDataSource(collection: collection) { course -> CourseGradesWidgetCellViewModel in
                        return CourseGradesWidgetCellViewModel(course: course)
                    }
                    refresher = try Course.refresher(session)
                }
            }
            catch {
                errorDelegate?.showError(errorMessage: NSLocalizedString("An error occurred", comment: ""))
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

struct CourseGradesWidgetCellViewModel: TableViewCellViewModel {
    let course: Course
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        let nib = UINib(nibName: String(describing: GradeWidgetCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GradeWidgetCell else  {
            fatalError("Incorrect cell type found; expected: GradeWidgetCell")
        }
        
        cell.courseNameLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.gradeLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        cell.courseNameLabel?.text = course.name
        cell.gradeLabel?.text = parseGrade(course)
        cell.dotView.layer.cornerRadius = cell.dotView.bounds.size.height / 2
        cell.dotView.backgroundColor = course.color.value
        return cell
    }
    
    func parseGrade(_ course: Course) -> String? {
        return course.visibleGrade?.count ?? 0 > 0 ? course.visibleGrade : (course.visibleScore?.count ?? 0 > 0 ? course.visibleScore : "-")
    }
}

class ErrorViewController: UIViewController {
    var errorMessage: String = "" {
        didSet {
            errorMessageLabel?.text = errorMessage
        }
    }
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        errorMessageLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        errorMessageLabel?.textAlignment = .center
        errorMessageLabel?.numberOfLines = 0
        errorMessageLabel?.lineBreakMode = .byWordWrapping
        errorMessageLabel?.text = errorMessage
    }
}
