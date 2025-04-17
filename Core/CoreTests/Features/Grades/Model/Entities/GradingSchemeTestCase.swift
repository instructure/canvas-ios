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

@testable import Core
import XCTest

class GradingSchemeTestCase: CoreTestCase {

    func scoreConversionEntries() -> [GradingSchemeEntry] {
        let entryA: GradingSchemeEntry = databaseClient.insert()
        entryA.name = "A"
        entryA.value = 0.9
        let entryB: GradingSchemeEntry = databaseClient.insert()
        entryB.name = "B"
        entryB.value = 0.3
        let entryF: GradingSchemeEntry = databaseClient.insert()
        entryF.name = "F"
        entryF.value = 0
        return [entryA, entryB, entryF]
    }

    func invalidConversionEntries() -> [GradingSchemeEntry] {
        let entry: GradingSchemeEntry = databaseClient.insert()
        entry.name = "A"
        entry.value = 90
        return [entry]
    }
}
