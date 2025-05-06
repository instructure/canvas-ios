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

import Foundation
import Core

struct HScoresAssignment: Equatable, Identifiable {
    let id: String
    let name: String
    let commentsCount: Int
    let dueAt: Date?
    let htmlUrl: URL?
    let pointsPossible: Double
    let score: Double?
    let state: String?
    let isRead: Bool
    let isExcused: Bool
    let isLate: Bool
    let isMissing: Bool
    let submittedAt: Date?

    init(
        id: String,
        name: String,
        commentsCount: Int,
        dueAt: Date?,
        htmlUrl: URL?,
        pointsPossible: Double,
        score: Double?,
        state: String?,
        isRead: Bool,
        isExcused: Bool,
        isLate: Bool,
        isMissing: Bool,
        submittedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.commentsCount = commentsCount
        self.dueAt = dueAt
        self.htmlUrl = htmlUrl
        self.pointsPossible = pointsPossible
        self.score = score
        self.state = state
        self.isRead = isRead
        self.isExcused = isExcused
        self.isLate = isLate
        self.isMissing = isMissing
        self.submittedAt = submittedAt
    }

    init(from entity: CDScoresAssignment) {
        self.id = entity.id
        self.name = entity.name ?? ""
        self.commentsCount = Int(truncating: entity.commentsCount ?? 0)
        self.dueAt = entity.dueAt
        self.htmlUrl = entity.htmlUrl
        self.pointsPossible = entity.pointsPossible
        self.score = if let score = entity.score { Double(truncating: score) } else { nil }
        self.state = entity.state
        self.isLate = entity.isLate
        self.isRead = entity.isRead
        self.isExcused = entity.isExcused
        self.isMissing = entity.isMissing
        self.submittedAt = entity.submittedAt
    }

    public var dueAtString: String? {
        dueAt?.formatted(format: "dd/MM/yyyy")
    }

    var status: HScoresAssignment.Status {
        if state == "submitted"
            || state == "pending_review"
            || (state == "graded" && score != nil) {
            return .submitted
        }

        if isLate { return .late }
        if isMissing { return .missing }
        if submittedAt != nil { return .submitted }
        if isExcused { return .excused }
        return .notSubmitted
    }

    var pointsResult: String {
        let noData = "-"
        let scoreFormat = if let score {
            GradeFormatter.numberFormatter.string(from: NSNumber(value: score)) ?? noData
        } else {
            noData
        }
        return "\(scoreFormat)/\(pointsPossible.trimmedString)"
    }
}

extension HScoresAssignment {
    enum Status {
        case late
        case missing
        case submitted
        case notSubmitted
        case excused

        var text: String {
            switch self {
            case .late:
                return String(localized: "Late", bundle: .horizon)
            case .missing:
                return String(localized: "Missing", bundle: .horizon)
            case .submitted:
                return String(localized: "Submitted", bundle: .horizon)
            case .notSubmitted:
                return String(localized: "Not Submitted", bundle: .horizon)
            case .excused:
                return String(localized: "Excused", bundle: .horizon)
            }
        }
    }
}
