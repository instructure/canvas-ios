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

public enum DSFeatureFlag: String {
    case newQuiz = "quizzes_next"
}

public struct DSFeatureFlagResponse: Codable {
    public let context_id: String
    public let context_type: String
    public let feature: String
    public let state: String
    public let locked: Bool
}

public struct DSCanvasFeatureFlag {
    let featureFlag: DSFeatureFlag
    let state: DSFeatureFlagState

    public init(featureFlag: DSFeatureFlag, state: DSFeatureFlagState) {
        self.featureFlag = featureFlag
        self.state = state
    }
}
