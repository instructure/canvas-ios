//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension BusinessLogic.AssignmentWeight {

    public struct GroupAssignment {
        public let pointsPossible: Double

        /// Failable initializer that enforces assignment eligibility for grade weight calculations.
        /// Returns `nil` if the assignment is omitted from the final grade or has no positive points possible.
        public init?(
            isOmittedFromFinalGrade: Bool?,
            pointsPossible: Double?
        ) {
            let isOmittedFromFinalGrade = isOmittedFromFinalGrade ?? false
            guard isOmittedFromFinalGrade == false,
                  let pointsPossible, pointsPossible > 0
            else { return nil }

            self.pointsPossible = pointsPossible
        }

#if DEBUG

        private init(pointsPossible: Double) {
            self.pointsPossible = pointsPossible
        }

        static func make(pointsPossible: Double = 100) -> Self {
            .init(pointsPossible: pointsPossible)
        }

#endif
    }
}
