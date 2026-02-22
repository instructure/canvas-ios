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

struct PillButtonStorybook: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(verbatim: "Default Styles")
                        .font(.headline)

                    HStack {
                        Button {} label: {
                            InstUI.PillContent(
                                title: "Default Outline",
                                size: .height24
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.pillButtonBrandFilled)

                        Button {} label: {
                            InstUI.PillContent(
                                title: "Brand Primary",
                                size: .height24,
                                isTextBold: true
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.pillButtonDefaultOutlined)
                    }
                }

                InstUI.Divider()

                VStack(spacing: 16) {
                    Text(verbatim: "Filled Style")
                        .font(.headline)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Accept",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))

                    Button {} label: {
                        InstUI.PillContent(
                            title: "All Courses",
                            trailingIcon: .chevronRight,
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Disabled",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))
                    .disabled(true)
                }

                InstUI.Divider()

                VStack(spacing: 16) {
                    Text(verbatim: "Outlined Style")
                        .font(.headline)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Decline",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonOutlined(color: .textDanger))

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Customize Dashboard",
                            leadingIcon: .editLine,
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonOutlined(color: .textInfo))

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Disabled",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillButtonOutlined(color: .textDark))
                    .disabled(true)
                }
            }
            .padding()
        }
        .navigationTitle(Text(verbatim: "Pill Button"))
        .navigationBarTitleDisplayMode(.large)
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        PillButtonStorybook()
    }
}

#endif
