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

import Foundation
@testable import Core

enum ReceiptStub {
    static var apiSearchRecipient: [APISearchRecipient] = [
        .make(id: "1", name: "Canvas 1"),
        .make(id: "2", name: "Canvas 2"),
        .make(id: "3", name: "Canvas 3"),
        .make(id: "4", name: "Canvas 4"),
        .make(id: "5", name: "ios Canvas")
    ]

    static var recipients: [Recipient] = [
        .init(id: "1", name: "Canvas 1", avatarURL: nil),
        .init(id: "2", name: "Canvas 2", avatarURL: nil),
        .init(id: "3", name: "Canvas 3", avatarURL: nil),
        .init(id: "4", name: "Canvas 4", avatarURL: nil),
        .init(id: "5", name: "ios Test", avatarURL: nil)
    ]

    static func getRecipientExceedMaxLimit() -> [Recipient] {
        var recipients: [Recipient] = []
        for id in 0...105 {
            recipients.append(.init(id: "\(id)", name: "", avatarURL: nil))
        }

        return  recipients
    }
}
