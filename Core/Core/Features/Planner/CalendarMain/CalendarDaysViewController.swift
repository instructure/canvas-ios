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

class CalendarDaysViewController: UIViewController {
    static let calendar = Calendar.autoupdatingCurrent
    static let numberOfDaysInWeek = calendar.maximumRange(of: .weekday)!.count

    private struct Spacings {
        // topPadding: set in storypoard
        let collapsedBottomPadding: CGFloat
        let expandedBottomPadding: CGFloat
        let weekGap: CGFloat
    }

    private var spacings: Spacings {
        if traitCollection.verticalSizeClass == .compact {
            Spacings(
                collapsedBottomPadding: 13,
                expandedBottomPadding: 10,
                weekGap: 6
            )
        } else {
            Spacings(
                collapsedBottomPadding: 20,
                expandedBottomPadding: 20,
                weekGap: 16
            )
        }
    }

    private var weekHeight: CGFloat { CalendarDayButton.height }
    private var weekGap: CGFloat { spacings.weekGap }

    var collapsedHeight: CGFloat { weekHeight + spacings.collapsedBottomPadding }
    var expandedHeight: CGFloat {
        let weekCount = CGFloat(weeksStackView.arrangedSubviews.count)
        guard weekCount > 0 else { return spacings.expandedBottomPadding }

        return weekCount * weekHeight
            + (weekCount - 1) * weekGap
            + spacings.expandedBottomPadding
    }

    var calendar: Calendar { CalendarDaysViewController.calendar }
    weak var delegate: CalendarViewControllerDelegate?
    var end = Clock.now // exclusive
    let env = AppEnvironment.shared
    var plannables: Store<GetPlannables>?
    var selectedDate = Clock.now
    var start = Clock.now // inclusive
    private var selectedWeekIndex = 0
    let weeksStackView = UIStackView()
    lazy var topOffset = weeksStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

    static func create(selectedDate: Date, delegate: CalendarViewControllerDelegate?) -> CalendarDaysViewController {
        let controller = CalendarDaysViewController()
        controller.delegate = delegate
        controller.selectedDate = selectedDate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        weeksStackView.axis = .vertical
        weeksStackView.spacing = weekGap
        view.addSubview(weeksStackView)
        weeksStackView.pin(inside: view, top: nil, bottom: nil)
        topOffset.isActive = true

        var currentDate = selectedDate.startOfMonth().startOfWeek()
        start = currentDate
        while calendar.compare(currentDate, to: selectedDate, toGranularity: .month) != .orderedDescending {
            let week = UIStackView()
            week.distribution = .fillEqually
            weeksStackView.addArrangedSubview(week)

            for _ in 0..<CalendarDaysViewController.numberOfDaysInWeek {
                let day = CalendarDayButton(date: currentDate, selectedDate: selectedDate, calendar: calendar)
                day.addTarget(self, action: #selector(selectDate(_:)), for: .primaryActionTriggered)
                week.addArrangedSubview(day)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            if currentDate <= selectedDate {
                selectedWeekIndex += 1
            }
            end = currentDate
        }
        refresh()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let ratio = min(1, (view.bounds.height - collapsedHeight) / (expandedHeight - collapsedHeight))
        topOffset.constant = -(1 - ratio) * CGFloat(selectedWeekIndex) * (weekHeight + weekGap)
        for (w, week) in weeksStackView.arrangedSubviews.enumerated() {
            week.alpha = w == selectedWeekIndex ? 1 : ratio
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Manually refresh the spacing upon rotation
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            weeksStackView.spacing = weekGap
        }
    }

    func refresh(force: Bool = false) {
        plannables = delegate.flatMap { env.subscribe($0.getPlannables(from: start, to: end)) { [weak self] in
            self?.updateDots()
        } }
        plannables?.exhaust(force: force)
    }

    func updateDots() {
        let list: [Date] = plannables?.all.compactMap({ $0.date }).sorted() ?? []
        var i = 0
        for week in weeksStackView.arrangedSubviews {
            for day in week.subviews.compactMap({ $0 as? CalendarDayButton }) {
                while i < list.count, list[i] < day.date { i += 1 }
                let startIndex = i
                while i < list.count, calendar.isDate(list[i], inSameDayAs: day.date) { i += 1 }
                day.activityDotCount = i - startIndex
            }
        }
    }

    @objc func selectDate(_ button: CalendarDayButton) {
        delegate?.calendarDidSelectDate(button.date)
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        for (w, week) in weeksStackView.arrangedSubviews.enumerated() {
            for day in week.subviews.compactMap({ $0 as? CalendarDayButton }) {
                day.isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
                if day.isSelected { selectedWeekIndex = w }
            }
        }
    }

    func midDate(isExpanded: Bool) -> Date {
        let week = isExpanded
            ? weeksStackView.arrangedSubviews[weeksStackView.arrangedSubviews.count / 2]
            : weeksStackView.arrangedSubviews[selectedWeekIndex]
        let button = week.subviews[week.subviews.count / 2] as? CalendarDayButton
        return button!.date
    }

    func hasDate(_ date: Date, isExpanded: Bool) -> Bool {
        if isExpanded { return start <= date && date < end }
        let first = weeksStackView.arrangedSubviews[selectedWeekIndex].subviews.first as? CalendarDayButton
        let last = weeksStackView.arrangedSubviews[selectedWeekIndex].subviews.last as? CalendarDayButton
        return first!.date <= date && date < last!.date.addDays(1)
    }
}

class CalendarDayButton: UIButton {
    let circleView = UIView()
    let label = UILabel()
    let dotContainer = UIStackView()
    var activityDotCount = 0 {
        didSet {
            for (d, dot) in dotContainer.arrangedSubviews.enumerated() {
                dot.isHidden = d >= activityDotCount
            }
            accessibilityLabel = String.localizedStringWithFormat(
                String(localized: "date_d_events", bundle: .core),
                DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none),
                activityDotCount
            )
        }
    }

    let date: Date
    private let isToday: Bool
    private let isWeekend: Bool
    private let isOtherMonth: Bool
    override var isSelected: Bool {
        didSet { tintColorDidChange() }
    }

    private static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    private static let circleHeight: CGFloat = 32
    private static let dotHeight: CGFloat = 4
    static var height: CGFloat { circleHeight }

    private var dotSpacing: CGFloat {
        let isVerticallyShrinked = traitCollection.verticalSizeClass == .compact
        return isVerticallyShrinked ? 2 : 0
    }
    private weak var dotSpacingConstraint: NSLayoutConstraint?

    required init?(coder: NSCoder) { return nil }

    init(date: Date, selectedDate: Date, calendar: Calendar) {
        self.date = date
        isToday = calendar.isDateInToday(date)
        isWeekend = calendar.isDateInWeekend(date)
        isOtherMonth = calendar.compare(date, to: selectedDate, toGranularity: .month) != .orderedSame
        super.init(frame: .zero)
        isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        backgroundColor = .backgroundLightest

        let year = String(calendar.component(.year, from: date))
        let month = String(calendar.component(.month, from: date))
        let day = String(calendar.component(.day, from: date))
        accessibilityIdentifier = "PlannerCalendar.dayButton.\(year)-\(month)-\(day)"
        accessibilityLabel = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)
        circleView.isUserInteractionEnabled = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = CalendarDayButton.circleHeight / 2
        circleView.layer.borderWidth = 2

        addSubview(label)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .scaledNamedFont(.regular16)
        label.text = CalendarDayButton.dayFormatter.string(from: date)

        addSubview(dotContainer)
        dotContainer.spacing = 4
        dotContainer.isUserInteractionEnabled = false
        dotContainer.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<3 {
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: Self.dotHeight, height: Self.dotHeight))
            dot.isHidden = true
            dot.layer.cornerRadius = Self.dotHeight / 2
            dot.widthAnchor.constraint(equalToConstant: Self.dotHeight).isActive = true
            dot.heightAnchor.constraint(equalToConstant: Self.dotHeight).isActive = true
            dotContainer.addArrangedSubview(dot)
        }

        let dotSpacingConstraint = bottomAnchor.constraint(equalTo: dotContainer.bottomAnchor, constant: dotSpacing)
        self.dotSpacingConstraint = dotSpacingConstraint
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: Self.circleHeight),
            circleView.heightAnchor.constraint(equalToConstant: Self.circleHeight),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dotContainer.centerXAnchor.constraint(equalTo: centerXAnchor),

            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dotSpacingConstraint
        ])

        tintColorDidChange()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        circleView.layer.borderColor = UIColor.clear.cgColor
        circleView.backgroundColor = isSelected ? tintColor : nil
        label.textColor = (
            isSelected ? UIColor.textLightest :
            isToday ? tintColor :
            isWeekend || isOtherMonth ? UIColor.textDark :
            UIColor.textDarkest
        )
        for dot in dotContainer.arrangedSubviews {
            dot.backgroundColor = tintColor
        }
        dotContainer.isHidden = isSelected
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Manually refresh constraint upon rotation
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            dotSpacingConstraint?.constant = dotSpacing
        }
    }
}
