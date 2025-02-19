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

import Core
import SwiftUI

struct StudentHeaderView: View {
    @ObservedObject private var viewModel: StudentHeaderViewModel
    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isVerticallyCompact: Bool {
        verticalSizeClass == .compact
    }
    private var avatarSize: CGFloat { isVerticallyCompact ? 32 : 48 }
    private var navBarHeight: CGFloat { isVerticallyCompact ? 42 : 91 }

    init(viewModel: StudentHeaderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        studentView
            .frame(minHeight: navBarHeight, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(nil, value: viewModel.backgroundColor)
            .background(viewModel.backgroundColor)
            .animation(.default, value: viewModel.backgroundColor)
            .overlay(alignment: isVerticallyCompact ? .leading : .topLeading) {
                menuButton
            }
            .foregroundStyle(Color.textLightest)
    }

    private var studentView: some View {
        Button {
            viewModel.didTapStudentView.send(())
        } label: {
            VStack {
                viewBody
                    .id(viewModel.state)
                    .transition(.push(from: .bottom))
                    .accessibilityElement()
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(viewModel.accessibilityLabel)
                    .accessibilityValue(viewModel.accessibilityValue)
                    .accessibilityHint(viewModel.accessibilityHint)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Match the animation we use for the student carousel appearance
            .animation(.easeOut(duration: 0.3), value: viewModel.state)
            .clipped()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var viewBody: some View {
        if isVerticallyCompact {
            HStack(spacing: 8) {
                icon
                label
            }
        } else {
            VStack(spacing: 8) {
                icon
                label
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch viewModel.state {
        case .addStudent:
            Circle()
                .frame(width: avatarSize, height: avatarSize)
                .overlay {
                    Image.addLine
                        .size(avatarSize / 2)
                        .foregroundStyle(viewModel.backgroundColor)
                }
                .dropShadow()
        case .student(let name, let avatarURL):
            Avatar(name: name, url: avatarURL, size: avatarSize)
                .dropShadow()
        }
    }

    @ViewBuilder
    private var label: some View {
        switch viewModel.state {
        case .addStudent:
            addStudentLabel
        case .student(let name, _):
            studentNameWithDropDown(name: name)
        }
    }

    private func studentNameWithDropDown(name: String) -> some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.semibold16)
            Image.dropdown
                .rotationEffect(.degrees(viewModel.isDropdownClosed ? 0 : -180))
        }
    }

    private var addStudentLabel: some View {
        Text("Add Student", bundle: .parent)
            .font(.semibold16)
    }

    private var menuButton: some View {
        Button {
            viewModel.didTapMenuButton.send(controller.value)
        } label: {
            Image.hamburgerSolid
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.textLightest)
                .instBadge(viewModel.badgeCount)
        }
        .padding(.leading, 16)
        .padding(.top, isVerticallyCompact ? 0 : 20)
        .identifier("Dashboard.profileButton")
        .accessibilityLabel(Text("Settings", bundle: .parent))
        .accessibilityValue(String(localized: "Closed", bundle: .core))
        .accessibilityHint(viewModel.menuAccessibilityHint)
    }
}

private extension View {

    func dropShadow() -> some View {
        shadow(
            color: .black.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    StudentHeaderView(viewModel: StudentHeaderViewModel())
        .frame(maxHeight: .infinity, alignment: .top)
}
