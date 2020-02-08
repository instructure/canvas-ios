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

class CalendarMonthView: UIView {
    @IBOutlet weak var dropdownView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var weekdayRow: UIStackView!
    @IBOutlet weak var weekRows: UIStackView!
    @IBOutlet weak var yearLabel: UILabel!

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateSelectedDate()
    }

    static var yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter
    }()
    static var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }()
    static var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ccc")
        return formatter
    }()

    let calendar = Calendar.autoupdatingCurrent
    var numberOfDaysInWeek: Int { calendar.maximumRange(of: .weekday)!.count }
    var selectedDate = Clock.now {
        didSet { updateSelectedDate() }
    }
    var isExpanded = false {
        didSet { updateExpanded() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
        awakeFromNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false

        monthButton.addTarget(self, action: #selector(toggleExpanded), for: .primaryActionTriggered)

        filterButton.setTitle(NSLocalizedString("Calendar", comment: ""), for: .normal)

        for placeholder in weekdayRow.arrangedSubviews { placeholder.removeFromSuperview() }
        for i in 0..<numberOfDaysInWeek {
            let day = calendar.firstWeekday + i - calendar.component(.weekday, from: selectedDate)
            let date = calendar.date(byAdding: .day, value: day, to: selectedDate)!
            let label = UILabel()
            label.font = .scaledNamedFont(.semibold12)
            label.text = CalendarMonthView.weekdayFormatter.string(from: date)
            label.textColor = .named(calendar.isDateInWeekend(date) ? .textDark : .textDarkest)
            label.textAlignment = .center
            weekdayRow.addArrangedSubview(label)
        }

        var currentDate = calendar.date(byAdding: .day, value: 1 - calendar.component(.day, from: selectedDate), to: selectedDate)!
        currentDate = calendar.date(byAdding: .day, value: calendar.firstWeekday - calendar.component(.weekday, from: currentDate), to: currentDate)!
        while calendar.compare(currentDate, to: selectedDate, toGranularity: .month) != .orderedDescending {
            let weekRow = UIStackView()
            weekRow.distribution = .fillEqually
            weekRows.addArrangedSubview(weekRow)
            for _ in 0..<numberOfDaysInWeek {
                let day = CalendarMonthDayButton(type: .custom)
                day.date = currentDate
                day.addTarget(self, action: #selector(selectDate(_:)), for: .primaryActionTriggered)
                weekRow.addArrangedSubview(day)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }

        updateSelectedDate()
        updateExpanded()
    }

    @objc func selectDate(_ button: CalendarMonthDayButton) {
        selectedDate = button.date
    }

    func updateSelectedDate() {
        yearLabel.text = CalendarMonthView.yearFormatter.string(from: selectedDate)
        monthButton.setTitle(CalendarMonthView.monthFormatter.string(from: selectedDate), for: .normal)

        for week in weekRows.arrangedSubviews {
            for day in week.subviews {
                (day as? CalendarMonthDayButton)?.update(selectedDate: selectedDate, calendar: calendar)
            }
        }
    }

    @objc func toggleExpanded() {
        UIView.animate(withDuration: 0.3, animations: {
            self.isExpanded = !self.isExpanded
            self.dropdownView.transform = CGAffineTransform(rotationAngle: self.isExpanded ? .pi : 0)
        })
    }

    func updateExpanded() {
        for week in weekRows.arrangedSubviews {
            guard let date = (week.subviews.first as? CalendarMonthDayButton)?.date else { return }
            week.isHidden = !(isExpanded || calendar.compare(date, to: selectedDate, toGranularity: .weekOfMonth) == .orderedSame)
        }
    }
}

class CalendarMonthDayButton: UIButton {
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
        label.text = CalendarMonthDayButton.dayFormatter.string(from: date)
    }
}
