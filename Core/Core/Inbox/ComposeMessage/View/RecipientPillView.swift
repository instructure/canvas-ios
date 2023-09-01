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

import SwiftUI

public struct RecipientPillView: View {

    private let recipient: SearchRecipient

    public init(recipient: SearchRecipient) {
        self.recipient = recipient
    }

    public var body: some View {
        HStack(spacing: 0) {
            Avatar(name: recipient.name, url: recipient.avatarURL)
            Text(recipient.name)
        }
        .overlay(
               RoundedRectangle(cornerRadius: 16)
                   .stroke(.blue, lineWidth: 4)
           )    }
}
