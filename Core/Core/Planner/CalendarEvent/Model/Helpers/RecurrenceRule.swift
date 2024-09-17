//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

// MARK: - RRule Value

private protocol RRuleCodable {
    init?(rruleString: String)
    var rruleString: String { get }
}

extension RRuleCodable where Self: RawRepresentable, Self.RawValue == String {
    init?(rruleString: String) { self.init(rawValue: rruleString) }
    var rruleString: String { rawValue }
}

extension LosslessStringConvertible where Self: RRuleCodable {
    init?(rruleString: String) {
        self.init(rruleString)
    }

    var rruleString: String { self.description }
}

extension Int: RRuleCodable {}
extension String: RRuleCodable {}
extension Date: RRuleCodable {

    init?(rruleString: String) {
        guard let date = Date.parse(rruleDescription: rruleString) else { return nil }
        self = date
    }

    var rruleString: String { rruleFormatted() }
}

extension Array: RRuleCodable where Element: RRuleCodable {

    init?(rruleString: String) {
        let list = rruleString
            .split(separator: ",")
            .compactMap({ Element(rruleString: String($0)) })
        if list.isEmpty { return nil }
        self = list
    }

    var rruleString: String {
        map({ $0.rruleString }).joined(separator: ",")
    }
}

// MARK: - RRule SubRule Key

private enum RRuleKey {

    protocol Key {
        static var string: String { get }
        associatedtype Value: RRuleCodable
        static func validate(_ value: Value) -> Bool
    }

    enum Frequency: Key {
        static let string = "FREQ"
        static func validate(_ value: RecurrenceFrequency) -> Bool { true }
    }

    enum Interval: Key {
        static let string = "INTERVAL"
        static func validate(_ value: Int) -> Bool { value > 0 }
    }

    enum EndDate: Key {
        static let string = "UNTIL"
        static func validate(_ value: Date) -> Bool { true }
    }

    enum OccurrenceCount: Key {
        static let string = "COUNT"
        static func validate(_ value: Int) -> Bool { value > 0 }
    }

    enum DaysOfTheWeek: Key {
        static let string = "BYDAY"
        static func validate(_ value: [RecurrenceRule.DayOfWeek]) -> Bool { value.count > 0 }
    }

    enum DaysOfTheMonth: Key {
        static let string = "BYMONTHDAY"
        static func validate(_ value: [Int]) -> Bool {
            value.count > 0 && value.allSatisfy({ (1 ... 31).contains(abs($0)) })
        }
    }

    enum DaysOfTheYear: Key {
        static let string = "BYYEARDAY"
        static func validate(_ value: [Int]) -> Bool {
            value.count > 0 && value.allSatisfy({ (1 ... 366).contains(abs($0)) })
        }
    }

    enum WeeksOfTheYear: Key {
        static let string = "BYWEEKNO"
        static func validate(_ value: [Int]) -> Bool {
            value.count > 0 && value.allSatisfy({ (1 ... 53).contains(abs($0)) })
        }
    }

    enum MonthsOfTheYear: Key {
        static let string = "BYMONTH"
        static func validate(_ value: [Int]) -> Bool {
            value.count > 0 && value.allSatisfy({ (1 ... 12).contains(abs($0)) })
        }
    }

    enum SetPositions: Key {
        static let string = "BYSETPOS"
        static func validate(_ value: [Int]) -> Bool {
            value.count > 0 && value.allSatisfy({ (1 ... 366).contains(abs($0)) })
        }
    }
}

private extension RRuleKey.Key {

    static func value(in dict: [String: String]) -> Value? {
        guard let rrule = dict[string] else { return nil }
        return parse(rruleValue: rrule)
    }

    static func parse(rruleValue: String) -> Value? {
        guard let val = Value(rruleString: rruleValue) else { return nil }
        if validate(val) { return val }
        return nil
    }

    static func rruleString(for value: Value?) -> String? {
        guard let val = value, validate(val) else {
            return nil
        }
        return "\(string)=\(val.rruleString)"
    }
}

// MARK: - Models

enum RecurrenceFrequency: String, RRuleCodable, CaseIterable {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case yearly = "YEARLY"
}

enum RecurrenceEnd: Equatable {
    case endDate(Date)
    case occurrenceCount(Int)

    var asEndDate: Date? {
        if case .endDate(let date) = self { return date }
        return nil
    }

    var asOccurrenceCount: Int? {
        if case .occurrenceCount(let count) = self { return count }
        return nil
    }
}

enum Weekday: String, RRuleCodable, CaseIterable {

    static var allCases: [Weekday] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }

    static var weekDays: [Weekday] {
        return [
            .monday, .tuesday, .wednesday, .thursday, .friday
        ]
    }

    case sunday = "SU",
         monday = "MO",
         tuesday = "TU",
         wednesday = "WE",
         thursday = "TH",
         friday = "FR",
         saturday = "SA"

    var dateComponent: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }

    var sortOrder: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    init?(component: Int) {
        guard let first = Self
            .allCases
            .first(where: { $0.dateComponent == component })
        else { return nil }
        self = first
    }
}

// MARK: - Rule Impl.

struct RecurrenceRule: Equatable {

    struct DayOfWeek: Equatable, RRuleCodable {

        init?(rruleString: String) {
            guard
                let val = rruleString.split(separator: /\d+/).last,
                let day = Weekday(rawValue: String(val)) else { return nil }

            let num = Int(rruleString: rruleString.replacingOccurrences(of: day.rawValue, with: ""))
            self.init(day, weekNumber: num)
        }

        var rruleString: String {
            var val = ""
            if let weekNumber {
                val += weekNumber.rruleString
            }
            val += weekday.rawValue
            return val
        }

        let weekday: Weekday
        let weekNumber: Int?

        init(_ weekday: Weekday, weekNumber: Int? = nil) {
            self.weekday = weekday
            self.weekNumber = weekNumber
        }
    }

    public init(recurrenceWith type: RecurrenceFrequency,
                interval: Int,
                daysOfTheWeek weekDays: [DayOfWeek]? = nil,
                daysOfTheMonth monthDays: [Int]? = nil,
                daysOfTheYear yearDays: [Int]? = nil,
                weeksOfTheYear yearWeeks: [Int]? = nil,
                monthsOfTheYear yearMonths: [Int]? = nil,
                setPositions: [Int]? = nil,
                end: RecurrenceEnd? = nil) {

        self.frequency = type
        self.interval = interval
        self.daysOfTheWeek = weekDays
        self.daysOfTheMonth = monthDays
        self.daysOfTheYear = yearDays
        self.weeksOfTheYear = yearWeeks
        self.monthsOfTheYear = yearMonths
        self.setPositions = setPositions
        self.recurrenceEnd = end
    }

    var frequency: RecurrenceFrequency
    var interval: Int
    var recurrenceEnd: RecurrenceEnd?

    var daysOfTheWeek: [DayOfWeek]?
    var daysOfTheMonth: [Int]?
    var daysOfTheYear: [Int]?
    var weeksOfTheYear: [Int]?
    var monthsOfTheYear: [Int]?
    var setPositions: [Int]?
}

extension RecurrenceRule {
    private typealias RRK = RRuleKey

    init?(rruleDescription: String) {
        let rules = rruleDescription.asRRuleSubRules

        guard
            let frequency = RRK.Frequency.value(in: rules),
            let interval = RRK.Interval.value(in: rules)
        else { return nil }

        self.frequency = frequency
        self.interval = interval

        if [.weekly, .monthly, .yearly].contains(frequency) {
            self.daysOfTheWeek = RRK.DaysOfTheWeek.value(in: rules)
        }

        if [.monthly, .yearly].contains(frequency) {
            self.daysOfTheMonth = RRK.DaysOfTheMonth.value(in: rules)
        }

        if case .yearly = frequency {
            self.daysOfTheYear = RRK.DaysOfTheYear.value(in: rules)
            self.weeksOfTheYear = RRK.WeeksOfTheYear.value(in: rules)
            self.monthsOfTheYear = RRK.MonthsOfTheYear.value(in: rules)
        }

        self.setPositions = RRK.SetPositions.value(in: rules)
        self.recurrenceEnd = RRK.EndDate.value(in: rules).flatMap { .endDate($0) }
            ?? RRK.OccurrenceCount.value(in: rules).flatMap { .occurrenceCount($0) }
    }

    var rruleDescription: String {

        var subRules: [String?] = [
            RRK.Frequency.rruleString(for: frequency),
            RRK.Interval.rruleString(for: interval)
        ]

        if case .yearly = frequency {
            subRules.append(contentsOf: [
                RRK.MonthsOfTheYear.rruleString(for: monthsOfTheYear),
                RRK.WeeksOfTheYear.rruleString(for: weeksOfTheYear),
                RRK.DaysOfTheYear.rruleString(for: daysOfTheYear)
            ])
        }

        if [.monthly, .yearly].contains(frequency) {
            subRules.append(
                RRK.DaysOfTheMonth.rruleString(for: daysOfTheMonth)
            )
        }

        if [.weekly, .monthly, .yearly].contains(frequency) {
            subRules.append(
                RRK.DaysOfTheWeek.rruleString(for: daysOfTheWeek)
            )
        }

        subRules.append(contentsOf: [
            RRK.SetPositions.rruleString(for: setPositions),
            RRK.EndDate.rruleString(for: recurrenceEnd?.asEndDate),
            RRK.OccurrenceCount.rruleString(for: recurrenceEnd?.asOccurrenceCount)
        ])

        return "RRULE:" + subRules.compactMap({ $0 }).joined(separator: ";")
    }
}

// MARK: - Codable Conformance

enum RecurrenceError: Error {
    case decoding
    case encoding
}

extension RecurrenceRule: Codable {

    init(from decoder: any Decoder) throws {
        let rruleString = try decoder.singleValueContainer().decode(String.self)

        guard let rule = Self.init(rruleDescription: rruleString)
        else { throw RecurrenceError.decoding }

        self = rule
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rruleDescription)
    }
}

// MARK: - Helpers

private extension Date {

    private static let rruleFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter
    }()

    func rruleFormatted() -> String {
        return Self.rruleFormatter.string(from: self)
    }

    static func parse(rruleDescription: String) -> Date? {
        return Self.rruleFormatter.date(from: rruleDescription)
    }
}

private extension String {

    var asRRuleSubRules: [String: String] {
        return self
            .replacingOccurrences(of: "RRULE:", with: "")
            .trimmed()
            .split(separator: ";")
            .map(String.init)
            .compactMap({ $0.asKeyValuePair })
            .reduce(into: [:]) { partialResult, pair in
                partialResult[pair.key] = pair.value
            }
    }

    var asKeyValuePair: (key: String, value: String)? {
        let pair = split(separator: "=").map { String($0).trimmingCharacters(in: .whitespaces) }

        if pair.count >= 2 {
            return (pair[0], pair[1])
        }

        return nil
    }
}
