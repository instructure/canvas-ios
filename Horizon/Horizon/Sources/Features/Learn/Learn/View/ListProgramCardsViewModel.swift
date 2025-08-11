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

import Observation

@Observable
final class ListProgramCardsViewModel {
    private(set) var points: [ListProgramCards.ProgramCardPoint] = []

    var sortedPoints: [ListProgramCards.ProgramCardPoint] {
        points.sorted { $0.point.y < $1.point.y }
    }

    func append(point: ListProgramCards.ProgramCardPoint) {
        points.append(point)
    }

    var firstPoint: ListProgramCards.ProgramCardPoint? { sortedPoints.first }

    var lastPoint: ListProgramCards.ProgramCardPoint? { sortedPoints.last }

    var lastCompletedPoint: ListProgramCards.ProgramCardPoint? {
        guard let lastCompletedIndex = sortedPoints.lastIndex(where: { $0.isCompleted }) else { return nil }

        let nextIndex = lastCompletedIndex + 1
        if nextIndex < sortedPoints.count {
            return sortedPoints[safe: nextIndex]
        } else {
            return sortedPoints[safe: lastCompletedIndex]
        }
    }
}
