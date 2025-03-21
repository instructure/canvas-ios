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

public struct APIInboxSettings: Codable, Equatable {
    let data: APIInboxSettings.MyInboxSettings

    struct MyInboxSettings: Codable, Equatable {
        let myInboxSettings: APIInboxSettings.Data
    }

    struct Data: Codable, Equatable {
        let createdAt: Date?
        let outOfOfficeLastDate: Date?
        let outOfOfficeMessage: String?
        let outOfOfficeSubject: String?
        let outOfOfficeFirstDate: Date?
        let signature: String?
        let updatedAt: Date?
        let useOutOfOffice: Bool?
        let useSignature: Bool?
    }
}

#if DEBUG

extension APIInboxSettings {
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
    ) -> APIInboxSettings {
        return APIInboxSettings(
            data: .init(
                myInboxSettings:
                    .init(
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
    }
}

#endif
