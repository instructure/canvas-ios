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

protocol CalendarDaysDelegate: class {
    var selectedDate: Date { get set }
    var isExpanded: Bool { get }
    var tintColor: UIColor { get }
}

class CalendarDaysViewController: UIViewController {
    static let calendar = Calendar.autoupdatingCurrent
    static let numberOfDaysInWeek = calendar.maximumRange(of: .weekday)!.count
    var minHeight: CGFloat { weekHeight + 8 }
    var maxHeight: CGFloat { CGFloat(weeksStackView.arrangedSubviews.count) * (weekHeight + 12) + 4 }
    let weekHeight: CGFloat = 39

    var anchorDate = Clock.now
    private var anchorWeekIndex = 0
    var calendar: Calendar { CalendarDaysViewController.calendar }
    weak var delegate: CalendarDaysDelegate?
    let weeksStackView = UIStackView()
    lazy var topOffset = weeksStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

    static func create(anchorDate: Date, delegate: CalendarDaysDelegate?) -> CalendarDaysViewController {
        let controller = CalendarDaysViewController()
        controller.anchorDate = anchorDate
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        weeksStackView.axis = .vertical
        weeksStackView.spacing = 12
        view.addSubview(weeksStackView)
        weeksStackView.pin(inside: view, top: nil, bottom: nil)
        topOffset.isActive = true

        let selectedDate = delegate?.selectedDate ?? Clock.now
        var currentDate = calendar.date(byAdding: .day, value: 1 - calendar.component(.day, from: anchorDate), to: anchorDate)!
        currentDate = calendar.date(byAdding: .day, value: calendar.firstWeekday - calendar.component(.weekday, from: currentDate), to: currentDate)!
        while calendar.compare(currentDate, to: anchorDate, toGranularity: .month) != .orderedDescending {
            let week = UIStackView()
            week.distribution = .fillEqually
            week.heightAnchor.constraint(equalToConstant: weekHeight).isActive = true
            weeksStackView.addArrangedSubview(week)

            for _ in 0..<CalendarDaysViewController.numberOfDaysInWeek {
                let day = CalendarDayButton(type: .custom)
                day.date = currentDate
                day.tag = weeksStackView.arrangedSubviews.count - 1
                day.tintColor = delegate?.tintColor
                day.update(selectedDate: selectedDate, calendar: calendar)
                day.addTarget(self, action: #selector(selectDate(_:)), for: .primaryActionTriggered)
                week.addArrangedSubview(day)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            if currentDate < anchorDate {
                anchorWeekIndex += 1
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let ratio = (view.bounds.height - minHeight) / (maxHeight - minHeight)
        topOffset.constant = -(1 - ratio) * CGFloat(anchorWeekIndex) * (weekHeight + 12)
        for (w, week) in weeksStackView.arrangedSubviews.enumerated() {
            week.alpha = w == anchorWeekIndex ? 1 : ratio
        }
    }

    @objc func selectDate(_ button: CalendarDayButton) {
        let selectedDate = button.date
        anchorWeekIndex = button.tag
        delegate?.selectedDate = selectedDate
        for week in weeksStackView.arrangedSubviews {
            for day in week.subviews {
                (day as? CalendarDayButton)?.update(selectedDate: selectedDate, calendar: calendar)
            }
        }
    }

    func firstDate(isExpanded: Bool) -> Date {
        let week = isExpanded
            ? weeksStackView.arrangedSubviews.first
            : weeksStackView.arrangedSubviews[anchorWeekIndex]
        let button = week?.subviews.first as? CalendarDayButton
        return button!.date
    }

    func monthDate(isExpanded: Bool) -> Date {
        let week = isExpanded
            ? weeksStackView.arrangedSubviews[weeksStackView.arrangedSubviews.count / 2]
            : weeksStackView.arrangedSubviews[anchorWeekIndex]
        let button = week.subviews[week.subviews.count / 2] as? CalendarDayButton
        return button!.date
    }

    func lastDate(isExpanded: Bool) -> Date {
        let week = isExpanded
            ? weeksStackView.arrangedSubviews.last
            : weeksStackView.arrangedSubviews[anchorWeekIndex]
        let button = week?.subviews.last as? CalendarDayButton
        return button!.date
    }
}

class CalendarDayButton: UIButton {
    let circleView = UIView()
    var date = Clock.now
    let label = UILabel()

    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)
        circleView.isUserInteractionEnabled = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 15
        circleView.layer.borderWidth = 1

        addSubview(label)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .scaledNamedFont(.semibold18)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 30),
            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 30),
            bottomAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 9),

            label.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
        ])
    }

    func update(selectedDate: Date, calendar: Calendar) {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        circleView.isHidden = !isToday && !isSelected
        circleView.layer.borderColor = isToday ? UIColor.clear.cgColor : tintColor.cgColor
        circleView.backgroundColor = (
            isToday && isSelected ? tintColor
            : isToday ? UIColor.named(.backgroundDark)
            : nil
        )

        label.textColor = UIColor.named(
            calendar.isDateInToday(date) ? .white
            : calendar.isDateInWeekend(date) ? .textDark
            : .textDarkest
        )
        label.text = CalendarDayButton.dayFormatter.string(from: date)
    }
}
