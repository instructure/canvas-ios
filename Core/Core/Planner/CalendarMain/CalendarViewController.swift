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

protocol CalendarViewControllerDelegate: AnyObject {
    func calendarDidSelectDate(_ date: Date)
    func calendarDidTransitionToDate(_ date: Date)
    func calendarDidResize(height: CGFloat, animated: Bool)
    func calendarWillFilter()
    func getPlannables(from: Date, to: Date) -> GetPlannables
}

class CalendarViewController: ScreenViewTrackableViewController {
    @IBOutlet weak var dropdownView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var daysContainer: UIView!
    let daysPageController = PagesViewController()
    var days: CalendarDaysViewController! {
        daysPageController.currentPage as? CalendarDaysViewController
    }
    @IBOutlet weak var daysHeight: NSLayoutConstraint!
    lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    var panOffset: CGFloat = 0
    @IBOutlet weak var weekdayRow: UIStackView!
    @IBOutlet weak var yearLabel: UILabel!
    weak var delegate: CalendarViewControllerDelegate?
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/calendar"
    )

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
    lazy var monthPageTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()
    lazy var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ccc")
        return formatter
    }()

    static func create(delegate: CalendarViewControllerDelegate?, selectedDate: Date = Clock.now) -> CalendarViewController {
        let controller = loadFromStoryboard()
        controller.delegate = delegate
        controller.selectedDate = selectedDate
        return controller
    }

    var calendar: Calendar {
        Cal.plannerCalendar
    }

    lazy var numberOfDaysInWeek: Int = calendar.maximumRange(of: .weekday)!.count
    var selectedDate = Clock.now
    var isExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(panRecognizer)
        view.backgroundColor = .backgroundLightest

        monthButton.configuration = UIButton.Configuration.plain()
        monthButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = .textDarkest
            outgoing.font = UIFont.scaledNamedFont(.semibold22)
            return outgoing
        }
        monthButton.configuration?.background.backgroundColor = .clear
        // trailing = 8 (text-image spacing) + 20 (image width) + 4 (image right padding)
        monthButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32)
        monthButton.accessibilityLabel = String(localized: "Show a month at a time", bundle: .core)

        filterButton.setTitle(String(localized: "Calendars", bundle: .core), for: .normal)
        filterButton.titleLabel?.font = .scaledNamedFont(.regular16)
        filterButton.accessibilityLabel = String(localized: "Filter events", bundle: .core)

        dropdownView.transform = CGAffineTransform(rotationAngle: 4 * .pi)

        for placeholder in weekdayRow.arrangedSubviews { placeholder.removeFromSuperview() }
        for i in 0..<numberOfDaysInWeek {
            let day = calendar.firstWeekday + i - calendar.component(.weekday, from: selectedDate)
            let date = calendar.date(byAdding: .day, value: day, to: selectedDate)!
            let label = UILabel()
            label.font = .scaledNamedFont(.regular12)
            label.adjustsFontForContentSizeCategory = true
            label.text = weekdayFormatter.string(from: date)
            label.textColor = calendar.isDateInWeekend(date) ? .textDark : .textDarkest
            label.textAlignment = .center
            label.isAccessibilityElement = false
            weekdayRow.addArrangedSubview(label)
        }

        embed(daysPageController, in: daysContainer)
        daysPageController.dataSource = self
        daysPageController.delegate = self
        daysPageController.setCurrentPage(CalendarDaysViewController.create(selectedDate: selectedDate, delegate: delegate))
        updateExpanded()

        updateSelectedDate(selectedDate)
    }

    @objc func didPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panOffset = height
        case .changed:
            let height = max(minHeight, min(maxHeight, panOffset + recognizer.translation(in: view).y))
            setHeight(height)
            delegate?.calendarDidResize(height: height, animated: false)
        case .ended:
            setExpanded(isExpanded)
        default:
            break
        }
    }

    func refresh(force: Bool = false) {
        days.refresh(force: force)
    }

    @IBAction func toggleExpanded() {
        setExpanded(!isExpanded)
    }

    func setExpanded(_ flag: Bool) {
        isExpanded = flag
        monthButton.isSelected = flag
        UIView.animate(withDuration: 0.3, animations: updateExpanded)
    }

    func updateExpanded() {
        daysHeight.constant = isExpanded ? days.expandedHeight : days.collapsedHeight
        dropdownView.transform = CGAffineTransform(rotationAngle: isExpanded ? .pi : 4 * .pi)
        delegate?.calendarDidResize(height: height, animated: true)
    }

    var height: CGFloat { daysContainer.frame.minY + daysHeight.constant }
    var minHeight: CGFloat { daysContainer.frame.minY + days.collapsedHeight }
    var maxHeight: CGFloat { daysContainer.frame.minY + days.expandedHeight }
    func setHeight(_ height: CGFloat) {
        let ratio = (height - minHeight) / (maxHeight - minHeight)
        isExpanded = ratio > 0.5
        daysHeight.constant = height - daysContainer.frame.minY
        dropdownView.transform = CGAffineTransform(rotationAngle: -ratio * .pi)
    }

    @IBAction func filter(_ sender: UIButton) {
        delegate?.calendarWillFilter()
    }

    func calendarDidSelectDate(_ date: Date) {
        delegate?.calendarDidSelectDate(date)
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        yearLabel.text = yearFormatter.string(from: selectedDate)

        let monthTitle = monthFormatter.string(from: selectedDate)
        if monthButton.title(for: .normal) != monthTitle {
            animateMonthTitle(monthTitle)
        }

        if days.hasDate(date, isExpanded: isExpanded) {
            days.updateSelectedDate(date)
        } else {
            showDate(date)
        }
    }

    func showDate(_ date: Date) {
        let isReverse = date < days.selectedDate
        let animated = isExpanded
            ? calendar.compare(date, to: days.selectedDate, toGranularity: .month) != .orderedSame
            : days.hasDate(date, isExpanded: isExpanded) == false
        let page = CalendarDaysViewController.create(selectedDate: date, delegate: delegate)
        daysPageController.setCurrentPage(page, direction: !animated ? nil : isReverse ? .reverse : .forward)
        updateSelectedDate(date)
    }

    func animateMonthTitle(_ title: String) {
        let duration: TimeInterval = 0.185
        UIView.animate(withDuration: duration, animations: {
            self.monthButton.alpha = 0
        }, completion: { _ in
            self.monthButton.setTitle(title, for: .normal)
            UIView.animate(withDuration: duration, animations: {
                self.monthButton.alpha = 1
            })
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Manually trigger a calendar height update upon rotation
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            if #available(iOS 17.0, *) {
                // On iOS 17 embedded VC traits need to be updated first, otherwise the size values from
                // the embedded VC will be outdated in `updateExpanded()`.
                // This would be also needed if we used `registerForTraitChanges()`, unfortunately.
                updateTraitsIfNeeded()
            }
            updateExpanded()
        }
    }
}

extension CalendarViewController: PagesViewControllerDataSource, PagesViewControllerDelegate {
    func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        return daysPageDelta(-1, from: (page as? CalendarDaysViewController)!)
    }

    func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        return daysPageDelta(1, from: (page as? CalendarDaysViewController)!)
    }

    func daysPageDelta(_ delta: Int, from days: CalendarDaysViewController) -> CalendarDaysViewController {
        var selectedDate = days.selectedDate
        if isExpanded {
            let midDate = calendar.date(byAdding: .month, value: 1 * delta, to: days.midDate(isExpanded: isExpanded))!
            if calendar.compare(selectedDate, to: midDate, toGranularity: .month) != .orderedSame {
                selectedDate = calendar.date(byAdding: .month, value: 1 * delta, to: selectedDate)!
            }
        } else {
            selectedDate = calendar.date(byAdding: .day, value: numberOfDaysInWeek  * delta, to: selectedDate)!
        }
        let days = CalendarDaysViewController.create(selectedDate: selectedDate, delegate: delegate)
        // Announced with accessibilityScroll
        days.title = isExpanded ? monthPageTitleFormatter.string(from: selectedDate)
            : String.localizedStringWithFormat(
                String(localized: "Week of %@", bundle: .core),
                DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none)
            )
        return days
    }

    func pagesViewController(_ pages: PagesViewController, isShowing list: [UIViewController]) {
        guard isExpanded, let list = list as? [CalendarDaysViewController] else { return }
        daysHeight.constant = list.reduce(days.expandedHeight) { height, page in
            max(height, page.expandedHeight)
        }
        delegate?.calendarDidResize(height: height, animated: false)
    }

    func pagesViewController(_ pages: PagesViewController, didTransitionTo page: UIViewController) {
        delegate?.calendarDidTransitionToDate(days.selectedDate)
        UIAccessibility.post(notification: .layoutChanged, argument: page.view)
    }
}
