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

public struct DashboardFeedbackAlert: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let onSubmit: (DashboardFeedbackReason) -> Void
    let onSkip: () -> Void
    let onLetUsKnow: () -> Void

    @State private var selectedReason: DashboardFeedbackReason?

    public init(
        onSubmit: @escaping (DashboardFeedbackReason) -> Void,
        onSkip: @escaping () -> Void,
        onLetUsKnow: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onSkip = onSkip
        self.onLetUsKnow = onLetUsKnow
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    InstUI.Divider(.full)
                    radioButtonsSection
                    InstUI.Divider(.full)
                    feedbackSection
                    InstUI.Divider(.full)
                    actionButtons
                }
                .background(Color.backgroundLightest)
                .cornerRadius(8)
            }
            .frame(width: min(350, geometry.size.width * 0.9))
            .frame(maxHeight: min(500, geometry.size.height * 0.7))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Switched back?", bundle: .core)
                .textStyle(.heading)

            Text("Thanks for trying the new dashboard! Could you tell us why you switched back?", bundle: .core)
                .textStyle(.headingInfo)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .paddingStyle(.horizontal, .standard)
        .paddingStyle(.top, .paragraphTop)
        .paddingStyle(.bottom, .standard)
    }

    private var radioButtonsSection: some View {
        VStack(spacing: 0) {
            ForEach(DashboardFeedbackReason.allCases, id: \.self) { reason in
                InstUI.RadioButtonCell(
                    title: reason.title,
                    value: reason,
                    selectedValue: $selectedReason,
                    dividerStyle: reason == DashboardFeedbackReason.allCases.last ? .hidden : .padded
                )
            }
        }
    }

    private var feedbackSection: some View {
        VStack(spacing: 12) {
            Text("What do you think of the new dashboard?", bundle: .core)
                .textStyle(.infoDescription)

            Button {
                onLetUsKnow()
            } label: {
                HStack(spacing: 4) {
                    Text("Let us know!", bundle: .core)
                    Image.externalLinkLine
                        .scaledIcon(size: 16)
                }
            }
            .buttonStyle(.pillButtonOutlined(color: .brandPrimary))
            .accessibilityAddTraits(.isLink)
        }
        .paddingStyle(.horizontal, .standard)
        .paddingStyle(.vertical, .standard)
    }

    private var actionButtons: some View {
        HStack(spacing: 0) {
            Button {
                onSkip()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Skip", bundle: .core)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundColor(.brandPrimary)
                    .frame(maxWidth: .infinity)
                    .paddingStyle(.vertical, .standard)
            }

            InstUI.Divider(.full)

            Button {
                if let reason = selectedReason {
                    onSubmit(reason)
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Submit", bundle: .core)
                    .font(.regular16, lineHeight: .fit)
                    .foregroundColor(selectedReason == nil ? .textDark : .brandPrimary)
                    .frame(maxWidth: .infinity)
                    .paddingStyle(.vertical, .standard)
            }
            .disabled(selectedReason == nil)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

public enum DashboardFeedbackReason: CaseIterable, Hashable {
    case hardToFind
    case preferOldLayout
    case somethingBroken

    var title: String {
        switch self {
        case .hardToFind: String(localized: "Hard to find things", bundle: .core)
        case .preferOldLayout: String(localized: "Prefer the old layout", bundle: .core)
        case .somethingBroken: String(localized: "Something didn't work right", bundle: .core)
        }
    }

    var analyticsValue: String {
        switch self {
        case .hardToFind: "hard_to_find"
        case .preferOldLayout: "prefer_old_layout"
        case .somethingBroken: "something_broken"
        }
    }
}

#if DEBUG
#Preview {
    DashboardFeedbackAlert(
        onSubmit: { _ in },
        onSkip: {},
        onLetUsKnow: {}
    )
}
#endif
