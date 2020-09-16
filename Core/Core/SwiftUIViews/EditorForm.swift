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

public struct EditorForm<Content: View>: View {
    public let content: Content
    public let isSpinning: Bool

    public init(isSpinning: Bool, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSpinning = isSpinning
    }

    public var body: some View {
        ZStack {
            ScrollView { VStack(alignment: .leading, spacing: 0) {
                content
            } }
                .disabled(isSpinning)
            if isSpinning {
                CircleProgress().size()
            }
        }
            .avoidKeyboardArea()
            .background(Color.backgroundGrouped)
            .navBarStyle(.modal)
    }
}

public struct EditorSection<Content: View>: View {
    public let content: Content
    public let label: Text

    public init(label: Text = Text(verbatim: ""), @ViewBuilder content: () -> Content) {
        self.content = content()
        self.label = label
    }

    public var body: some View { SwiftUI.Group {
        label
            .font(.semibold14).foregroundColor(.textDark)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
        Divider()
        content.background(Color.backgroundLightest)
        Divider()
    } }
}

public struct TextFieldRow: View {
    public let label: Text
    public let placeholder: String
    @Binding public var text: String

    public init(label: Text, placeholder: String, text: Binding<String>) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack {
            label
                .font(.semibold16).foregroundColor(.textDarkest)
                .accessibility(hidden: true)
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(label: label)
        }
            .padding(16)
    }
}
