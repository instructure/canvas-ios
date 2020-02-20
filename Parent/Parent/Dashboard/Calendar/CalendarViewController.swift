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
import Core

protocol CalendarViewControllerDelegate: class {
    func selectedDateDidChange(_ date: Date)
    func dailyActivityCount(forDate: Date, handler: @escaping (DailyCalendarActivityData?) -> Void)
}

class CalendarViewController: UIViewController, CalendarDaysDelegate {
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

    static func create(studentID: String) -> CalendarViewController {
        return loadFromStoryboard()
    }

    let calendar = Calendar.autoupdatingCurrent
    lazy var numberOfDaysInWeek: Int = calendar.maximumRange(of: .weekday)!.count
    var selectedDate = Clock.now
    var isExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
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
            createCalanderDaysViewController(fromDate: selectedDate, selectedDate: selectedDate),
        ], direction: .forward, animated: false)
        for view in daysPageController.view.subviews {
            if let scroll = view as? UIScrollView {
                scroll.canCancelContentTouches = true
            }
        }

        updatePage()
    }

    @IBAction func toggleExpanded() {
        isExpanded = !isExpanded
        monthButton.isSelected = isExpanded
        UIView.animate(withDuration: 0.3, animations: updateExpanded)
        clearPageCache()
    }

    @IBAction func filter(_ sender: UIButton) {
    }

    func setSelectedDate(_ date: Date) {
        selectedDate = date
        updatePage()
        clearPageCache()
        delegate?.selectedDateDidChange(selectedDate)
    }

    func clearPageCache() {
        daysPageController.dataSource = nil
        daysPageController.dataSource = self
    }

    func updatePage() {
        yearLabel.text = yearFormatter.string(from: selectedDate)
        monthButton.setTitle(monthFormatter.string(from: selectedDate), for: .normal)
        updateExpanded()
    }

    func updateExpanded() {
        daysHeight.constant = isExpanded ? days.maxHeight : days.minHeight
        dropdownView.transform = CGAffineTransform(rotationAngle: isExpanded ? .pi : 0)
        view.superview?.layoutIfNeeded()
    }

    private func createCalanderDaysViewController(fromDate: Date, selectedDate: Date) -> CalendarDaysViewController {
        let vc = CalendarDaysViewController.create(fromDate, selectedDate: selectedDate, delegate: self)
        delegate?.dailyActivityCount(forDate: selectedDate, handler: { data in
            performUIUpdate { vc.placeDailyActivityCounts(data: data) }
        })
        return vc
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
        return createCalanderDaysViewController(fromDate: midDate, selectedDate: selectedDate)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        selectedDate = days.selectedDate
        updatePage()
        delegate?.selectedDateDidChange(selectedDate)
        // clearPageCache() // would cause a crash, so don't
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let days = pendingViewControllers.first as? CalendarDaysViewController, isExpanded else { return }
        daysHeight.constant = max(days.maxHeight, self.days.maxHeight)
    }
}
