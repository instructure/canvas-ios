//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

extension String {
    public func UTF8Data() throws -> Data {
        guard let data = data(using: String.Encoding.utf8) else {
            let title = NSLocalizedString("Encoding Error", tableName: "Localizable", bundle: .core, value: "", comment: "Data encoding error title")
            let message = NSLocalizedString("There was a problem encoding UTF8 Data", tableName: "Localizable", bundle: .core, value: "", comment: "Data encoding error message")
            throw NSError(subdomain: "SoLazy", code: 0, title: title, description: message)
        }
        
        return data
    }
}


public func +=(lhs: inout Data, rhs: Data) {
    lhs.append(rhs)
}
