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

public struct GradingSchemeEntry: Codable, Equatable {
    public let name: String
    public let value: Double
    public let calculatedValue: Double?

    init(name: String, value: Double, calculatedValue: Double? = nil) {
        self.name = name
        self.value = value
        self.calculatedValue = calculatedValue
    }

    init?(_ courseGradingScheme: [TypeSafeCodable<String, Double>]) {
        guard courseGradingScheme.count == 2,
              let name = courseGradingScheme[0].value1,
              let value = courseGradingScheme[1].value2
        else { return nil }
        self.name = name
        self.value = value
        self.calculatedValue = nil
    }

    init(_ apiGradingScheme: APIGradingSchemeEntry) {
        self.name = apiGradingScheme.name
        self.value = apiGradingScheme.value
        self.calculatedValue = apiGradingScheme.calculated_value
    }
}
