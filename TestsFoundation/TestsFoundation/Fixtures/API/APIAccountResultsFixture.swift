//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core

extension APIAccountResult {
    public static func make(
        name: String = "Crazy Go Nuts University",
        domain: String = "cgnuonline-eniversity.edu",
        authentication_provider: String? = nil
    ) -> APIAccountResult {
        return APIAccountResult(
            name: name,
            domain: domain,
            authentication_provider: authentication_provider
        )
    }
}
