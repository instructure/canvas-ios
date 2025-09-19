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

extension Bundle {
    public class var testBundle: Bundle {
        return Bundle(for: TestBundleToken.self)
    }
}

private final class TestBundleToken {}

// MARK: - helpers

func loadJSON<T: Decodable>(bundle: Bundle, jsonName: String) -> T? {
    guard let path = bundle.path(forResource: jsonName, ofType: "json") else {
        fatalError("Could not retrieve file \(jsonName).json")
    }

    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        print("Decoding error for \(jsonName).json:", error)
        return nil
    }
}
