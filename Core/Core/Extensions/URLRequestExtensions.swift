//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension URLRequest {

    /** Returns the form boundary property from the `Content-Type` http header field. */
    public var boundary: String? {
        guard let contentType = value(forHTTPHeaderField: HttpHeader.contentType),
              let boundaryKeyRange = contentType.range(of: "boundary=\"")
        else { return nil }

        let boundaryValueStart = contentType[boundaryKeyRange.upperBound...]
        guard let boundaryCloseQuoteIndex =  boundaryValueStart.firstIndex(of: "\"") else { return nil }
        return String(boundaryValueStart[..<boundaryCloseQuoteIndex])
    }
}
