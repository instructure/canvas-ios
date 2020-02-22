//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import UIKit

protocol CalendarViewControllerDelegate: class {
    func calendarDidSelectDate(_ date: Date)
    func calendarDidResize(height: CGFloat, animated: Bool)
}

class CalendarViewController: UIViewController {
    @IBOutlet weak var dropdownView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var daysContainer: UIView!
    let daysPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    var days: CalendarDaysViewController! {
        daysPageController.viewControllers?.first as? CalendarDaysViewController
    }
    @IBOutlet weak var daysHeight: NSLayoutConstraint!
    @IBOutlet weak var weekdayRow: UIStackView!
    @IBOutlet weak var yearLabel: UILabel!
    weak var delegate: CalendarViewControllerDelegate?

    lazy var yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter
    }()
    lazy var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }()
    lazy var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ccc")
        return formatter
    }()

    static func create(studentID: String, delegate: CalendarViewControllerDelegate?) -> CalendarViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        return controller
    }

    let calendar = Calendar.autoupdatingCurrent
    var canClearCache = true
    lazy var numberOfDaysInWeek: Int = calendar.maximumRange(of: .weekday)!.count
    var selectedDate = Clock.now
    var isExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        let isRTL = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        monthButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: isRTL ? 28 : 0, bottom: 0, right: isRTL ? 0 : 28)
        monthButton.accessibilityLabel = NSLocalizedString("Show a month at a time", comment: "")

        filterButton.setTitle(NSLocalizedString("Calendar", comment: ""), for: .normal)
        filterButton.accessibilityLabel = NSLocalizedString("Filter events", comment: "")

        for placeholder in weekdayRow.arrangedSubviews { placeholder.removeFromSuperview() }
        for i in 0..<numberOfDaysInWeek {
            let day = calendar.firstWeekday + i - calendar.component(.weekday, from: selectedDate)
            let date = calendar.date(byAdding: .day, value: day, to: selectedDate)!
            let label = UILabel()
            label.font = .scaledNamedFont(.semibold12)
            label.text = weekdayFormatter.string(from: date)
            label.textColor = .named(calendar.isDateInWeekend(date) ? .textDark : .textDarkest)
            label.textAlignment = .center
            label.isAccessibilityElement = false
            weekdayRow.addArrangedSubview(label)
        }

        embed(daysPageController, in: daysContainer)
        daysPageController.dataSource = self
        daysPageController.delegate = self
        daysPageController.setViewControllers([
            CalendarDaysViewController.create(selectedDate, selectedDate: selectedDate, delegate: delegate),
        ], direction: .forward, animated: false)
        for view in daysPageController.view.subviews {
            if let scroll = view as? UIScrollView {
                scroll.canCancelContentTouches = true
            }
        }

        updateSelectedDate(selectedDate)
    }

    @IBAction func toggleExpanded() {
        setExpanded(!isExpanded)
    }

    func setExpanded(_ flag: Bool) {
        isExpanded = flag
        monthButton.isSelected = flag
        UIView.animate(withDuration: 0.3, animations: updateExpanded)
        clearPageCache()
    }

    func updateExpanded() {
        daysHeight.constant = isExpanded ? days.maxHeight : days.minHeight
        dropdownView.transform = CGAffineTransform(rotationAngle: isExpanded ? -.pi : 0)
        delegate?.calendarDidResize(height: daysContainer.frame.minY + daysHeight.constant, animated: true)
    }

    var minHeight: CGFloat { daysContainer.frame.minY + days.minHeight }
    var maxHeight: CGFloat { daysContainer.frame.minY + days.maxHeight }
    func setHeight(_ height: CGFloat) {
        let ratio = (height - minHeight) / (maxHeight - minHeight)
        isExpanded = ratio > 0.5
        daysHeight.constant = height - daysContainer.frame.minY
        dropdownView.transform = CGAffineTransform(rotationAngle: -ratio * .pi)
        clearPageCache()
    }

    @IBAction func filter(_ sender: UIButton) {
    }

    func calendarDidSelectDate(_ date: Date) {
        delegate?.calendarDidSelectDate(date)
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        yearLabel.text = yearFormatter.string(from: selectedDate)
        monthButton.setTitle(monthFormatter.string(from: selectedDate), for: .normal)
        clearPageCache()
        if days.hasDate(date, isExpanded: isExpanded) {
            days.updateSelectedDate(date)
        } else {
            let isReverse = date < days.selectedDate
            // Assumes selected date can't be more than 1 page away
            let page = daysPageDelta(isReverse ? -1 : 1, from: days)
            page.loadViewIfNeeded()
            page.updateSelectedDate(date)
            daysPageController.setViewControllers([ page ], direction: isReverse ? .reverse : .forward, animated: true)
        }
    }

    func clearPageCache() {
        guard canClearCache else { return }
        daysPageController.dataSource = nil
        daysPageController.dataSource = self
    }
}

extension CalendarViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return daysPageDelta(-1, from: (viewController as? CalendarDaysViewController)!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return daysPageDelta(1, from: (viewController as? CalendarDaysViewController)!)
    }

    func daysPageDelta(_ delta: Int, from days: CalendarDaysViewController) -> CalendarDaysViewController {
        var midDate = days.midDate(isExpanded: isExpanded)
        var selectedDate = days.selectedDate
        if isExpanded {
            midDate = calendar.date(byAdding: .month, value: 1 * delta, to: midDate)!
            if calendar.compare(selectedDate, to: midDate, toGranularity: .month) != .orderedSame {
                selectedDate = calendar.date(byAdding: .month, value: 1 * delta, to: selectedDate)!
            }
        } else {
            midDate = calendar.date(byAdding: .day, value: numberOfDaysInWeek * delta, to: midDate)!
            selectedDate = calendar.date(byAdding: .day, value: numberOfDaysInWeek  * delta, to: selectedDate)!
        }
        return CalendarDaysViewController.create(midDate, selectedDate: selectedDate, delegate: delegate)

    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        canClearCache = false
        delegate?.calendarDidSelectDate(days.selectedDate)
        canClearCache = true
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let days = pendingViewControllers.first as? CalendarDaysViewController, isExpanded else { return }
        daysHeight.constant = max(days.maxHeight, self.days.maxHeight)
        delegate?.calendarDidResize(height: daysContainer.frame.minY + daysHeight.constant, animated: false)
    }
}
