//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum Panda: String, CaseIterable {
    case AtLaptop, Blindfold, Blocks, Book, FilePicker, Grades, InboxZero, Locked
    case NoAlerts, NoComments, NoDiscussions, NoEvents, NoImportantDates, NoResults, NoRubric
    case Papers, Sleeping, Space, Teacher, Welcome, Unsupported

    public var name: String { "Panda\(rawValue)" }
}

public struct EmptyPanda: View {
    public let panda: Panda
    public let title: Text?
    public let message: Text?

    public init(_ panda: Panda, title: Text? = nil, message: Text? = nil) {
        self.panda = panda
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(panda.name, bundle: .core).accessibilityHidden(true)
            title?
                .font(.bold20)
                .multilineTextAlignment(.center)
                .identifier("EmptyPanda.titleText")
                .padding(.top, 64)
            message?
                .font(.regular16)
                .multilineTextAlignment(.center)
                .identifier("EmptyPanda.messageText")
                .padding(.top, 8)
            Spacer()
        }
        .foregroundColor(.textDarkest)
        .accessibilityElement(children: .combine)
    }
}
