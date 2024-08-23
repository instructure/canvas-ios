extension RecurrenceFrequency {

    var everyTime: String {
        switch self {
        case .daily: String(localized: "Daily")
        case .weekly: String(localized: "Weekly")
        case .monthly: String(localized: "Monthly")
        case .yearly: String(localized: "Yearly")
        }
    }

    var everyOther: String {
        switch self {
        case .daily: String(localized: "Every other day")
        case .weekly: String(localized: "Every other week")
        case .monthly: String(localized: "Every other month")
        case .yearly: String(localized: "Every other year")
        }
    }

    var everyMultipleFormat: String {
        switch self {
        case .daily: String(localized: "Every %@ day")
        case .weekly: String(localized: "Every %@ week")
        case .monthly: String(localized: "Every %@ month")
        case .yearly: String(localized: "Every %@ year")
        }
    }
}

extension Weekday {

    var text: String {
        return Calendar.autoupdatingCurrent.standaloneWeekdaySymbols[dateComponent - 1]
    }

    var shortText: String {
        return Calendar.autoupdatingCurrent.shortStandaloneWeekdaySymbols[dateComponent - 1]
    }

    var pluralText: String {
        switch self {
        case .sunday:
            String(localized: "Sundays")
        case .monday:
            String(localized: "Mondays")
        case .tuesday:
            String(localized: "Tuesdays")
        case .wednesday:
            String(localized: "Wednesdays")
        case .thursday:
            String(localized: "Thursdays")
        case .friday:
            String(localized: "Fridays")
        case .saturday:
            String(localized: "Saturdays")
        }
    }
}

extension WeekNumber {
    var text: String {
        switch self {
        case .first:
            String(localized: "First")
        case .second:
            String(localized: "Second")
        case .third:
            String(localized: "Third")
        case .fourth:
            String(localized: "Fourth")
        case .fifth:
            String(localized: "Fifth")
        case .last:
            String(localized: "Last")
        }
    }
}

extension DayOfWeek {

    var shortText: String {
        var txt: [String] = []
        if let weekNumber { txt.append(weekNumber.text) }
        txt.append(dayOfTheWeek.shortText)
        return txt.joined(separator: " ")
    }

    var fullText: String {
        var txt: [String] = []
        if let weekNumber { txt.append(weekNumber.text) }
        txt.append(dayOfTheWeek.text)
        return txt.joined(separator: " ")
    }

    var selectionText: String {
        var txt: [String] = []
        if let weekNumber {
            txt.append(weekNumber.text)
            txt.append(dayOfTheWeek.text)
        } else {
            txt.append(dayOfTheWeek.pluralText)
        }
        return txt.joined(separator: " ")
    }
}

extension Array where Element == DayOfWeek {

    var hasWeekdays: Bool {
        Weekday
            .weekDays
            .allSatisfy({ wd in
                contains(where: { d in
                    d.dayOfTheWeek == wd && d.weekNumber == nil
                })
            })
    }

    var nonWeekdays: Self {
        filter({ Weekday.weekDays.contains($0.dayOfTheWeek) == false })
    }

    var selectionTexts: [String] {
        var tags = [String]()

        if hasWeekdays {
            tags.append(String(localized: "Weekdays"))
        }

        if let nonWeekDays = nonWeekdays.nonEmpty() {

            let long = tags.isEmpty ? nonWeekDays.count <= 2 : false
            for wday in nonWeekDays {
                tags.append(long ? wday.selectionText : wday.shortText)
            }
        }

        return tags
    }

}

extension Int {

    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func asInterval(for frequency: RecurrenceFrequency) -> String {
        if self == 0 { return "" }
        if self == 1 { return frequency.everyTime }
        if self == 2 { return frequency.everyOther }
        return String(format: frequency.everyMultipleFormat, ordinal)
    }

    var asDay: String {
        String(format: String(localized: "Day %i"), self)
    }

    var asWeek: String {
        String(format: String(localized: "Week %i"), self)
    }

    var asMonth: String {
        Calendar.autoupdatingCurrent.standaloneMonthSymbols[self - 1]
    }
}

extension Array where Element == Int {

    var asDays: [String] {
        map { $0.asDay }
    }

    var asWeeks: [String] {
        map { $0.asDay }
    }

    var asMonths: [String] {
        map { $0.asMonth }
    }
}

extension RecurrenceRule {

    var text: String {
        var words: [String] = []

        if frequency != .daily {

            if let days = daysOfTheWeek {

                if days.hasWeekdays, case .weekly = frequency, interval == 1 {
                    words.append(String(localized: "Every Weekday", bundle: .core))
                } else {
                    words.append(interval.asInterval(for: frequency))
                    words.append(" on ")
                    words.append(days.map({ $0.fullText }).joined(separator: ", "))
                }

            } else {
                words.append(interval.asInterval(for: frequency))
            }
        } else {
            words.append(interval.asInterval(for: frequency))
            return words.joined()
        }

        func seperator() {
            words.append(words.count == 1 ? " on " : ", ")
        }

        if let weeks = weeksOfTheYear {
            seperator()

            words.append(weeks.map({ $0.asWeek }).joined(separator: ", "))
        }

        if let months = monthsOfTheYear, months.count == 1,
           let days = daysOfTheMonth, days.count == 1,
            let month = months.first,
            let day = days.first {

            seperator()
            words.append(month.asMonth)
            words.append(" ")
            words.append(day.formatted(.number))
        } else {

            if let months = monthsOfTheYear {
                seperator()
                words.append(months.map({ $0.asMonth }).joined(separator: ", "))
            }

            if let days = daysOfTheMonth {
                seperator()
                words.append(days.map({ $0.asDay }).joined(separator: ", "))
            }
        }

        return words.joined()
    }
}
