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
                        .buttonStyle(.pillDefaultOutlined)
                        .tint(.green) // should be ignored

                        Button {} label: {
                            InstUI.PillContent(
                                title: "Brand Primary",
                                size: .height24,
                                isTextBold: true
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.pillTintFilled)
                        .tint(.textInfo)
                    }
                }

                InstUI.Divider()

                VStack(spacing: 16) {
                    Text(verbatim: "Filled Style (always tinted)")
                        .font(.headline)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Accept",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillTintFilled)
                    .tint(.textInfo)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "All Courses",
                            trailingIcon: .chevronRight,
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillTintFilled)
                    .tint(.textInfo)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Disabled",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillTintFilled)
                    .tint(.textInfo)
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
                    .buttonStyle(.pillTintOutlined)
                    .tint(.textDanger)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Customize Dashboard",
                            leadingIcon: .editLine,
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillTintOutlined)
                    .tint(.textInfo)

                    Button {} label: {
                        InstUI.PillContent(
                            title: "Disabled",
                            size: .height30
                        )
                    }
                    .buttonStyle(.pillTintOutlined)
                    .tint(.textDark)
                    .disabled(true)
                }

                InstUI.Divider()

                VStack(spacing: 16) {
                    Text(verbatim: "Size options")
                        .font(.headline)

                    HStack(alignment: .top) {
                        Button {} label: {
                            InstUI.PillContent(title: "Height 30", trailingIcon: .infoLine, size: .height30)
                        }
                        .buttonStyle(.pillDefaultOutlined)

                        Button {} label: {
                            InstUI.PillContent(title: "Height 24", trailingIcon: .infoLine, size: .height24)
                        }
                        .buttonStyle(.pillDefaultOutlined)

                        Button {} label: {
                            InstUI.PillContent(title: "Height 20", trailingIcon: .infoLine, size: .height20)
                        }
                        .buttonStyle(.pillDefaultOutlined)
                    }

                    HStack(alignment: .top) {
                        Button {} label: {
                            InstUI.PillContent(title: "Height 30", trailingIcon: .infoLine, size: .height30)
                        }
                        .buttonStyle(.pillTintFilled)

                        Button {} label: {
                            InstUI.PillContent(title: "Height 24", trailingIcon: .infoLine, size: .height24)
                        }
                        .buttonStyle(.pillTintFilled)

                        Button {} label: {
                            InstUI.PillContent(title: "Height 20", trailingIcon: .infoLine, size: .height20)
                        }
                        .buttonStyle(.pillTintFilled)
                    }
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
