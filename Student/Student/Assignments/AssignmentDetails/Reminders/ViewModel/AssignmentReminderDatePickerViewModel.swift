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
import Core
import SwiftUI

class AssignmentReminderDatePickerViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var doneButtonActive = false
    @Published public private(set) var selectedButton: String?
    @Published public private(set) var customPickerVisible = false
    public let buttonTitles: [String]
    public let customValues: [Int] = Array(1...59)

    // MARK: - Inputs
    @Published public var customValue: Int = 1
    @Published public var customMetric: AssignmentReminderTimeMetric = .minutes

    private static let predefinedIntervals: [DateComponents] = [
        .init(minute: 5),
        .init(minute: 15),
        .init(minute: 30),
        .init(hour: 1),
        .init(day: 1),
        .init(weekOfMonth: 1)
    ]
    private let selectedTimeInterval: any Subject<DateComponents, Never>

    init(selectedTimeInterval: some Subject<DateComponents, Never>) {
        self.selectedTimeInterval = selectedTimeInterval
        buttonTitles = {
            let formatter = AssignmentReminderTimeFormatter()
            var result = Self.predefinedIntervals.map { formatter.string(from: $0)?.capitalized ?? "" }
            result.append(String(localized: "Custom", bundle: .student))
            return result
        }()
    }

    public func buttonDidTap(title: String) {
        selectedButton = title

        guard let buttonIndex = buttonTitles.firstIndex(of: title) else { return }
        customPickerVisible = (buttonIndex == (buttonTitles.count - 1))

        doneButtonActive = true
    }

    public func doneButtonDidTap(host: UIViewController) {
        guard let selectedButton else { return }

        let selectedInterval = {
            if let selectedIndex = buttonTitles.firstIndex(of: selectedButton),
               let selectedInterval = Self.predefinedIntervals[safeIndex: selectedIndex] {
                return selectedInterval
            } else {
                var customInterval = DateComponents()
                switch customMetric {
                case .minutes:
                    customInterval.minute = customValue
                case .hours:
                    customInterval.hour = customValue
                case .days:
                    customInterval.day = customValue
                case .weeks:
                    customInterval.weekOfMonth = customValue
                }
                return customInterval
            }
        }()

        selectedTimeInterval.send(selectedInterval)
    }
}
