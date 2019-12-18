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
import CanvasCore
import ReactiveSwift
import ReactiveCocoa
import Core

class CalendarEventWeekPageViewController: UIViewController {
    var env = AppEnvironment.shared

    @objc static var headerDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var prevWeekButton: UIButton!
    @objc var pageViewController: UIPageViewController?

    @objc var session: Session!
    @objc var studentID: String!
    @objc var initialReferenceDate: Date!
    @objc var currentStartDate: Date?
    @objc var contextCodes: [String] = []

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    static func create(env: AppEnvironment = .shared, session: Session, studentID: String, courseID: String? = nil, initialReferenceDate: Date = Date()) -> CalendarEventWeekPageViewController {
        let controller = loadFromStoryboard()
        controller.session = session
        controller.studentID = studentID
        controller.initialReferenceDate = initialReferenceDate
        controller.currentStartDate = controller.initialReferenceDate

        if let courseID = courseID {
            controller.contextCodes = [ ContextID(id: courseID, context: .course).canvasContextID ]

            // Only add syllabus if the course has a syllabus
            session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .course)).observe(on: UIScheduler()).startWithValues { next in
                guard let course = next as? CanvasCore.Course else { return }

                controller.title = course.name

                guard course.syllabusBody != nil else { return }

                let image = UIImage(named: "icon_document_fill")?.imageScaledByPercentage(0.75)
                let syllabusButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
                syllabusButton.accessibilityLabel = NSLocalizedString("Syllabus", comment: "Syllabus Button Title")
                syllabusButton.accessibilityIdentifier = "syllabus_button"
                let syllabus = Action<(), (), Never> { _ in
                    env.router.route(to: .syllabus(courseID: courseID), from: controller, options: nil)
                    return .empty
                }
                syllabusButton.reactive.pressed = CocoaAction(syllabus)
                syllabusButton.tintColor = .white
                controller.navigationItem.rightBarButtonItem = syllabusButton
            }
        }

        return controller
    }

    // ---------------------------------------------
    // MARK: - ViewController Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        let nextImage = UIImage.RTLImage("icon_forward", renderingMode: .alwaysTemplate)
        let prevImage = UIImage.RTLImage("icon_back", renderingMode: .alwaysTemplate)

        nextWeekButton.tintColor = UIColor.white
        nextWeekButton.setImage(nextImage, for: .normal)
        nextWeekButton.accessibilityIdentifier = "next_week_button"
        nextWeekButton.accessibilityLabel = NSLocalizedString("Next Week", comment: "Next Week Button Accessibility Label")

        prevWeekButton.tintColor = UIColor.white
        prevWeekButton.setImage(prevImage, for: .normal)
        prevWeekButton.accessibilityIdentifier = "last_week_button"
        prevWeekButton.accessibilityLabel = NSLocalizedString("Last Week", comment: "Last Week Button Accessibility Label")

        updateHeaderTitle()
        view.backgroundColor = .named(.backgroundDark)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let color = ColorScheme.observee(studentID).color
        navigationController?.navigationBar.useContextColor(color)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageVC = segue.destination as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }

            pageVC.delegate = self
            pageVC.dataSource = self
            pageVC.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
            let startDate = initialReferenceDate.dateOnSundayAtTheBeginningOfTheWeek
            let endDate = startDate + Calendar.current.numberOfDaysInWeek.daysComponents
            //  swiftlint:disable:next force_try
            let initialViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
            pageVC.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)

            currentStartDate = startDate
            pageViewController = pageVC
        }
    }

    // ---------------------------------------------
    // MARK: - Update View
    // ---------------------------------------------
    @objc func updateHeaderTitle() {
        guard let viewController = pageViewController?.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let formatter = CalendarEventWeekPageViewController.headerDateFormatter
        let startFormatted = formatter.string(from: viewController.startDate)
        let endFormatted = formatter.string(from: viewController.endDate - 1.secondsComponents)
        headerLabel.text = "\(startFormatted) - \(endFormatted)"
        headerLabel.accessibilityIdentifier = "week_header_label"
        headerLabel.accessibilityLabel = String(format: NSLocalizedString("%@ to %@", comment: ""), startFormatted, endFormatted)
        headerLabel.accessibilityTraits = UIAccessibilityTraits.header
        headerLabel.textColor = UIColor.white
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func scrollToNextWeek(_ sender: UIButton) {
        guard let pageViewController = pageViewController, let viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: { [unowned self] finished in
            if (finished) {
                self.updateHeaderTitle()
            }
        })
    }

    @IBAction func scrollToPrevWeek(_ sender: UIButton) {
        guard let pageViewController = pageViewController, let viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .reverse, animated: true, completion: { [unowned self] finished in
            if finished {
                self.updateHeaderTitle()
            }
        })
    }

    @objc func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - Helper Functions
    // ---------------------------------------------
    @objc func eventListController(_ startDate: Date) -> CalendarEventListViewController {
        currentStartDate = startDate
        let endDate = startDate + Calendar.current.numberOfDaysInWeek.daysComponents

        // Failing on purpose here.  If this is broken it's programmer error
        //  swiftlint:disable:next force_try
        let eventListViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        return eventListViewController
    }
}

// ---------------------------------------------
// MARK: - UIPageViewControllerDataSource
// ---------------------------------------------
extension CalendarEventWeekPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        return eventListController(startDate)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        return eventListController(startDate)
    }
}

// ---------------------------------------------
// MARK: - UIPageViewControllerDelegate
// ---------------------------------------------
extension CalendarEventWeekPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            updateHeaderTitle()
        }
    }
}
