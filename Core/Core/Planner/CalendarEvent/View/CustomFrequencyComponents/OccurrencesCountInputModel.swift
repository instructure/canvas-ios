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

import SwiftUI
import Combine

class OccurrencesCountInputModel: ObservableObject {

    @Published var text: String = ""

    var submittedCount: Binding<Int>

    init(submitted: Binding<Int>) {
        self.submittedCount = submitted
    }

    var isValid: Bool {
        guard let value = text.integerValue else { return false }
        return (1 ... 400).contains(value)
    }

    func update() {
        text = submittedCount.inputFormatted ?? ""
    }

    func submit() {
        guard let value = text.integerValue else { return }
        submittedCount.wrappedValue = min(max(value, 1), 400)
    }
}

// MARK: - Number Evaluation & Formatting

private extension String {

    static let inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        formatter.allowsFloats = false
        return formatter
    }()

    var integerValue: Int? {
        Self.inputFormatter.number(from: self)?.intValue
    }
}

private extension Binding where Value == Int {
    var inputFormatted: String? {
        return String.inputFormatter.string(from: NSNumber(value: wrappedValue))
    }
}
