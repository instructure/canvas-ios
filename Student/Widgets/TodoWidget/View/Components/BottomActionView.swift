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

import SwiftUI
import AppIntents

protocol BottomActionView: View {
    var isVisible: Bool { get }
}

extension BottomActionView {
    var isVisible: Bool { true }
}

struct RouteActionView: BottomActionView {

    let icon: Image
    let url: URL
    let accessibilityLabel: String?

    var body: some View {
        HStack {
            Spacer()
            Link(destination: url) {
                ActionLabel(icon: icon)
            }
            .accessibilityLabel(accessibilityLabel)
        }
    }
}

struct IntentActionView<Intent: AppIntent>: BottomActionView {

    let icon: Image
    let intent: Intent
    let accessibilityLabel: String?

    var body: some View {
        HStack {
            Spacer()
            Button(intent: intent) {
                ActionLabel(icon: icon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
        }
    }
}

struct NoActionView: BottomActionView {
    var isVisible: Bool { false }
    var body: some View {}
}

// MARK: Label View

private struct ActionLabel: View {

    let icon: Image

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.course2)
                .scaledFrame(width: 32, useIconScale: true)
            icon
                .renderingMode(.template)
                .scaledIcon(size: 18)
                .foregroundStyle(Color.backgroundLightest)
        }
    }
}
