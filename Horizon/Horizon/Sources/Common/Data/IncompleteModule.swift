//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

<<<<<<<< HEAD:Horizon/Horizon/Sources/Common/Data/IncompleteModule.swift
struct IncompleteModule {
    let moduleId: String
    let moduleItemId: String

    init?(
        moduleId: String?,
        moduleItemId: String?
    ) {
        guard let moduleId, let moduleItemId else {
            return nil
        }
        self.moduleId = moduleId
        self.moduleItemId = moduleItemId
========
enum SpeedGraderUserIdNormalization {

    /// Helper function to help normalize user ids coming from webview urls
    static func normalizeUserId(_ userId: String?) -> String {
        if let userId, userId.containsOnlyNumbers {
            return userId
        }

        return SpeedGraderAllUsersUserId
>>>>>>>> master:Teacher/Teacher/SpeedGrader/SpeedGraderScreen/Model/SpeedGraderUserIdNormalization.swift
    }
}
