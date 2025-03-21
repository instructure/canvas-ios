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

public struct APIUpdateInboxSettings: Codable, Equatable {
    let data: UpdateMyInboxSettings

    struct UpdateMyInboxSettings: Codable, Equatable {
        let updateMyInboxSettings: APIInboxSettings.MyInboxSettings
    }
}

#if DEBUG

extension APIUpdateInboxSettings {
    public static func make(
        createdAt: Date? = nil,
        outOfOfficeLastDate: Date? = nil,
        outOfOfficeMessage: String? = nil,
        outOfOfficeSubject: String? = nil,
        outOfOfficeFirstDate: Date? = nil,
        signature: String? = nil,
        updatedAt: Date? = nil,
        useOutOfOffice: Bool? = nil,
        useSignature: Bool? = nil
    ) -> APIUpdateInboxSettings {
        return APIUpdateInboxSettings(
            data: .init(
                updateMyInboxSettings: .init(
                    myInboxSettings: .init(
                        createdAt: createdAt,
                        outOfOfficeLastDate: outOfOfficeLastDate,
                        outOfOfficeMessage: outOfOfficeMessage,
                        outOfOfficeSubject: outOfOfficeSubject,
                        outOfOfficeFirstDate: outOfOfficeFirstDate,
                        signature: signature,
                        updatedAt: updatedAt,
                        useOutOfOffice: useOutOfOffice,
                        useSignature: useSignature
                    )
                )
           )
        )
    }
}

#endif
