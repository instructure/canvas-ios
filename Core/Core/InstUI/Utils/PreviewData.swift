//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

#if DEBUG

import Foundation

extension InstUI {

    enum PreviewData {
        static let loremIpsumShort = "Lorem ipsum dolor sit amet"
        static let loremIpsumMedium = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus"
        static let loremIpsumLong = """
                         Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus\
                         rutrum. Donec tempus vulputate posuere. Aenean blandit nunc vitae tempus sodales.\
                         In vehicula venenatis tempus. In pharetra aliquet neque, non viverra massa sodales eget.\
                         Etiam hendrerit tincidunt placerat. Suspendisse et lacus a metus tempor gravida.
                         New line!
                         """

        static func loremIpsumLong(_ multiplier: Int) -> String {
            guard multiplier > 0 else { return loremIpsumLong }

            return Array(repeating: loremIpsumLong, count: multiplier)
                .joined(separator: "\n")
        }
    }
}

#endif
