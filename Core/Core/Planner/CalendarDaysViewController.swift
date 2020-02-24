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

protocol CalendarDaysDelegate: class {
    func setSelectedDate(_ date: Date)
}

class CalendarDaysViewController: UIViewController {
    static let calendar = Calendar.autoupdatingCurrent
    static let numberOfDaysInWeek = calendar.maximumRange(of: .weekday)!.count
    var minHeight: CGFloat { weekHeight + 8 }
    var maxHeight: CGFloat { CGFloat(weeksStackView.arrangedSubviews.count) * (weekHeight + weekGap) + 4 }
    let weekHeight: CGFloat = 40
    let weekGap: CGFloat = 12

    var calendar: Calendar { CalendarDaysViewController.calendar }
    weak var delegate: CalendarDaysDelegate?
    var fromDate = Clock.now
    var selectedDate = Clock.now
    private var selectedWeekIndex = 0
    let weeksStackView = UIStackView()
    lazy var topOffset = weeksStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

    static func create(_ fromDate: Date, selectedDate: Date, delegate: CalendarDaysDelegate?) -> CalendarDaysViewController {
        let controller = CalendarDaysViewController()
        controller.delegate = delegate
        controller.fromDate = fromDate
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

        var currentDate = calendar.date(byAdding: .day, value: 1 - calendar.component(.day, from: fromDate), to: fromDate)!
        currentDate = calendar.date(byAdding: .day, value: calendar.firstWeekday - calendar.component(.weekday, from: currentDate), to: currentDate)!
        while calendar.compare(currentDate, to: fromDate, toGranularity: .month) != .orderedDescending {
            let week = UIStackView()
            week.distribution = .fillEqually
            weeksStackView.addArrangedSubview(week)

            for _ in 0..<CalendarDaysViewController.numberOfDaysInWeek {
                let day = CalendarDayButton(date: currentDate, selectedDate: selectedDate, calendar: calendar)
                day.tag = weeksStackView.arrangedSubviews.count - 1
                day.addTarget(self, action: #selector(selectDate(_:)), for: .primaryActionTriggered)
                week.addArrangedSubview(day)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            if currentDate < selectedDate {
                selectedWeekIndex += 1
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let ratio = min(1, (view.bounds.height - minHeight) / (maxHeight - minHeight))
        topOffset.constant = -(1 - ratio) * CGFloat(selectedWeekIndex) * (weekHeight + weekGap)
        for (w, week) in weeksStackView.arrangedSubviews.enumerated() {
            week.alpha = w == selectedWeekIndex ? 1 : ratio
        }
    }

    @objc func selectDate(_ button: CalendarDayButton) {
        selectedDate = button.date
        selectedWeekIndex = button.tag
        delegate?.setSelectedDate(selectedDate)
        for week in weeksStackView.arrangedSubviews {
            for day in week.subviews.compactMap({ $0 as? CalendarDayButton }) {
                day.isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
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

    public func placeDailyActivityCounts(data: DailyCalendarActivityData?) {
        for svs in weeksStackView.arrangedSubviews {
            if let week = svs as? UIStackView {
                for button in week.arrangedSubviews {
                    if let b = button as? CalendarDayButton, let count = data?[DateFormatter.localizedString(from: b.date, dateStyle: .short, timeStyle: .none)] {
                        b.activityDotCount = count
                    }
                }
            }
        }
    }
}

class CalendarDayButton: UIButton {
    let circleView = UIView()
    let label = UILabel()
    let dotContainer: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .equalSpacing
        s.alignment = .center
        s.spacing = 4
        return s
    }()
    private let max = 3
    var activityDotCount = 0 {
        didSet {
            if activityDotCount > max { activityDotCount = max }
            for _ in 0..<activityDotCount { addActivityDot() }
        }
    }

    let date: Date
    let isToday: Bool
    let isWeekend: Bool
    override var isSelected: Bool {
        didSet { tintColorDidChange() }
    }

    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    required init?(coder: NSCoder) { return nil }

    init(date: Date, selectedDate: Date, calendar: Calendar) {
        self.date = date
        isToday = calendar.isDateInToday(date)
        isWeekend = calendar.isDateInWeekend(date)
        super.init(frame: .zero)
        isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        accessibilityLabel = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)
        circleView.isUserInteractionEnabled = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 16
        circleView.layer.borderWidth = 2

        addSubview(label)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .scaledNamedFont(.semibold18)
        label.text = CalendarDayButton.dayFormatter.string(from: date)

        addSubview(dotContainer)
        dotContainer.isUserInteractionEnabled = false
        dotContainer.translatesAutoresizingMaskIntoConstraints = false
        dotContainer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dotContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 4).isActive = true

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 32),
            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 32),
            bottomAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 8),

            label.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            dotContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
            dotContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        tintColorDidChange()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        circleView.layer.borderColor = isSelected && !isToday ? tintColor.cgColor : UIColor.clear.cgColor
        circleView.backgroundColor = isToday ? tintColor : nil
        label.textColor = (
            isToday ? UIColor.named(.white) :
            isSelected ? tintColor :
            isWeekend ? UIColor.named(.textDark) :
            UIColor.named(.textDarkest)
        )

        for dot in dotContainer.arrangedSubviews {
            dot.backgroundColor = tintColor
        }
    }

    func addActivityDot() {
        let size: CGFloat = 4
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        circle.backgroundColor = tintColor
        circle.layer.cornerRadius = size / 2
        circle.layer.masksToBounds = true
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: size).isActive = true
        circle.heightAnchor.constraint(equalToConstant: size).isActive = true
        circle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        dotContainer.addArrangedSubview(circle)
    }
}
