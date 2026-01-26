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
                            Text(verbatim: "Brand Primary")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.pillButtonBrandFilled)

                        Button {} label: {
                            Text(verbatim: "Default Outline")
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
                        Text(verbatim: "Accept")
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))

                    Button {
                    } label: {
                        HStack(spacing: 0) {
                            Text(verbatim: "All Courses")
                            Image.arrowOpenRightSolid
                                .scaledIcon(size: 16)
                        }
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))

                    Button {} label: {
                        Text(verbatim: "Disabled")
                    }
                    .buttonStyle(.pillButtonFilled(color: .textInfo))
                    .disabled(true)
                }

                InstUI.Divider()

                VStack(spacing: 16) {
                    Text(verbatim: "Outlined Style")
                        .font(.headline)

                    Button {} label: {
                        Text(verbatim: "Decline")
                    }
                    .buttonStyle(.pillButtonOutlined(color: .textDanger))

                    Button {
                    } label: {
                        HStack(spacing: 8) {
                            Image.editLine
                                .scaledIcon(size: 16)
                            Text(verbatim: "Customize Dashboard")
                        }
                    }
                    .buttonStyle(.pillButtonOutlined(color: .textInfo))

                    Button {} label: {
                        Text(verbatim: "Disabled")
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
