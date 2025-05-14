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

class AssignmentReminderTimeFormatter: DateComponentsFormatter, @unchecked Sendable {

    override init() {
        super.init()
        unitsStyle = .full
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(from components: DateComponents) -> String? {
        guard let formatted = super.string(from: components) else {
            return nil
        }

        return String(localized: "\(formatted) before", bundle: .student, comment: "10 minutes before")
    }
}
