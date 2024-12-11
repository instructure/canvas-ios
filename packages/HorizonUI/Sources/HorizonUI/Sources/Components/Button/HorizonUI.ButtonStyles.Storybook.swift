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

extension HorizonUI.ButtonStyles {
    struct Storybook: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Button("AI Button Title") {
                        print("did tap ai")
                    }
                    .buttonStyle(
                        HorizonUI.ButtonStyles.ai(
                            isSmall: true,
                            fillsWidth: true
                        )
                    )

                    Button("Beige Button Title") {
                        print("did tap beige")
                    }
                    .buttonStyle(HorizonUI.ButtonStyles.beige())

                    /*
                     // MARK: - Custom view would look like:

                     HorizonUI.Button(
                         "AI Button Title",
                         .ai,
                         isSmall: true,
                         fillsWidth: true
                     ) {
                         print("did tap ai")
                     }

                     HorizonUI.Button(
                         "Beige Button Title",
                         .beige
                     ) {
                         print("did tap beige")
                     }

                     */

                    // MARK: - Previous version

//                        SwiftUI.Group {
//                            Text("Regular Buttons")
//                                .font(.headline)
//
//                            Button("Black Button") {}
//                                .buttonStyle(HorizonButtonStyle.black(leading: Text("*")))
//                            Button("White Button") {}
//                                .buttonStyle(HorizonButtonStyle.white(trailing: Text("!")))
//                            Button("AI Button") {}
//                                .buttonStyle(HorizonButtonStyle.ai)
//                            Button("Blue Button") {}
//                                .buttonStyle(HorizonButtonStyle.blue)
//                            Button("Beige Button") {}
//                                .buttonStyle(HorizonButtonStyle.beige)
//                        }
//
//                        SwiftUI.Group {
//                            Text("Small Buttons")
//                                .font(.headline)
//
//                            Button("Small Black Button") {}
//                                .buttonStyle(HorizonButtonStyle.blackSmall(width: .none))
//                            Button("Small White Button") {}
//                                .buttonStyle(HorizonButtonStyle.whiteSmall(width: .none))
//                            Button("Small AI Button") {}
//                                .buttonStyle(HorizonButtonStyle.aiSmall(width: .none))
//                            Button("Small Blue Button") {}
//                                .buttonStyle(HorizonButtonStyle.blueSmall(width: .none))
//                            Button("Small Beige Button") {}
//                                .buttonStyle(HorizonButtonStyle.beigeSmall(width: .none))
//                        }
//
//                        SwiftUI.Group {
//                            Text("Disabled Buttons")
//                                .font(.headline)
//
//                            Button("Disabled Black Button") {}
//                                .buttonStyle(HorizonButtonStyle.black)
//                                .disabled(true)
//                            Button("Disabled White Button") {}
//                                .buttonStyle(HorizonButtonStyle.white)
//                                .disabled(true)
//                            Button("Disabled AI Button") {}
//                                .buttonStyle(HorizonButtonStyle.ai)
//                                .disabled(true)
//                            Button("Disabled Blue Button") {}
//                                .buttonStyle(HorizonButtonStyle.blue)
//                                .disabled(true)
//                            Button("Disabled Beige Button") {}
//                                .buttonStyle(HorizonButtonStyle.beige)
//                                .disabled(true)
//                        }
                }
                .padding()
            }.background(
                Color(red: 226 / 255,
                      green: 226 / 255,
                      blue: 226 / 255)
            )
        }
    }
}

#Preview {
    HorizonUI.ButtonStyles.Storybook()
}
