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

import SwiftUI

extension HorizonUI {
    struct Buttons {
        struct Storybook: View {
            var body: some View {
                ScrollView {
                    VStack(spacing: 20) {
                        SwiftUI.Group {
                            Text("Regular Buttons")
                                .font(.headline)

                            Button("Black Button") {}
                                .buttonStyle(.black)
                            Button("Inverse Button") {}
                                .buttonStyle(.inverse)
                            Button("AI Button") {}
                                .buttonStyle(.ai)
                            Button("Blue Button") {}
                                .buttonStyle(.blue)
                            Button("Beige Button") {}
                                .buttonStyle(.beige)
                        }

                        SwiftUI.Group {
                            Text("Small Buttons")
                                .font(.headline)

                            Button("Small Black Button") {}
                                .buttonStyle(.blackSmall)
                            Button("Small Inverse Button") {}
                                .buttonStyle(.inverseSmall)
                            Button("Small AI Button") {}
                                .buttonStyle(.aiSmall)
                            Button("Small Blue Button") {}
                                .buttonStyle(.blueSmall)
                            Button("Small Beige Button") {}
                                .buttonStyle(.beigeSmall)
                        }

                        SwiftUI.Group {
                            Text("Disabled Buttons")
                                .font(.headline)

                            Button("Disabled Black Button") {}
                                .buttonStyle(.black)
                                .disabled(true)
                            Button("Disabled Inverse Button") {}
                                .buttonStyle(.inverse)
                                .disabled(true)
                            Button("Disabled AI Button") {}
                                .buttonStyle(.ai)
                                .disabled(true)
                            Button("Disabled Blue Button") {}
                                .buttonStyle(.blue)
                                .disabled(true)
                            Button("Disabled Beige Button") {}
                                .buttonStyle(.beige)
                                .disabled(true)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    HorizonUI.Buttons.Storybook()
}
