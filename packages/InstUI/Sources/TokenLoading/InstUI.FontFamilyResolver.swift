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

extension InstUI {
    struct FontFamilyResolver {
        private let primitivesByName: [TokenKey: String]

        init() {
            primitivesByName = Dictionary(
                InstUI.Primitives.FontFamilies.all.map { ($0.name, $0.family) },
                uniquingKeysWith: { first, _ in first }
            )
        }

        func resolve(_ raw: String) throws -> String {
            guard raw.hasPrefix("{") else {
                throw InstUI.TokenLoadError.unknownPrimitive(raw)
            }
            let inner = String(raw.dropFirst().dropLast())
            guard let family = primitivesByName[inner] else {
                throw InstUI.TokenLoadError.unknownPrimitive(inner)
            }
            return family
        }
    }
}
