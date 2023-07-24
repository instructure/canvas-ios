//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct QuizSubmissionListItemViewModel: Identifiable, Equatable {
    public let id: String
    public let displayName: String
    public let name: String
    public let status: String
    public let statusColor: Color
    public let score: String?
    public let profileImageURL: URL?
    public let a11yLabel: String

    public init(item: QuizSubmissionListItem) {
        self.id = item.id
        self.displayName = item.displayName
        self.name = item.name
        if item.status == .untaken {
            self.status = NSLocalizedString("Not Submitted", comment: "")
            self.statusColor = .textDarkest
        } else {
            self.status = NSLocalizedString("Submitted", comment: "")
            self.statusColor = .textSuccess

        }
        self.score = item.score
        self.profileImageURL = item.avatarURL
        self.a11yLabel = displayName + " " + status + " " + (score ?? "")
    }
}
