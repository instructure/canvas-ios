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

import Combine
import SwiftUI

class AssignmentReminderDatePickerViewModel: ObservableObject {
    enum Metric: CaseIterable, Identifiable, Hashable {
        case minutes, hours, days, weeks

        var id: String { pickerTitle }
        var pickerTitle: String {
            switch self {
            case .minutes: return String(localized: "Minutes Before")
            case .hours: return String(localized: "Hours Before")
            case .days: return String(localized: "Days Before")
            case .weeks: return String(localized: "Weeks Before")
            }
        }
    }
    struct Interval: CustomStringConvertible, Identifiable {
        let value: Int
        let metric: Metric
        var description: String {
            "\(value) \(metric.pickerTitle)"
        }
        var id: String { description }
    }

    @Published public var customValue: Int = 1
    @Published public var customMetric: Metric = .minutes
    @Published public private(set) var doneButtonActive = false
    @Published public private(set) var selectedButton: String?
    @Published public private(set) var customPickerVisible = false
    public let buttonTitles: [String]
    public let customValues: [Int] = Array(1...59)

    private static let predefinedIntervals = [
        Interval(value: 5, metric: .minutes),
        Interval(value: 15, metric: .minutes),
        Interval(value: 30, metric: .minutes),
        Interval(value: 1, metric: .hours),
        Interval(value: 1, metric: .days),
        Interval(value: 1, metric: .weeks),
    ]
    private let assignmentDate: Date
    private let selectedReminderDateResult: any Subject<Date, Never>

    init(assignmentDate: Date, selectedReminderDate: some Subject<Date, Never>) {
        self.assignmentDate = assignmentDate
        selectedReminderDateResult = selectedReminderDate
        buttonTitles = {
            var result = Self.predefinedIntervals.map { $0.description }
            result.append(String(localized: "Custom"))
            return result
        }()
    }

    public func buttonDidTap(title: String) {
        selectedButton = title

        guard let buttonIndex = buttonTitles.firstIndex(of: title) else { return }
        customPickerVisible = (buttonIndex == (buttonTitles.count - 1))

        doneButtonActive = true
    }

    public func doneButtonDidTap() {
        selectedReminderDateResult.send(.now)
    }
}
