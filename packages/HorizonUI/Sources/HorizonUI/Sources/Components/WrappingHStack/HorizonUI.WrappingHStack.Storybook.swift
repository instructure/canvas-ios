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

extension HorizonUI.WrappingHStack {
    struct Storybook: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    singleLineWithoutSpacersSection
                    singleLineWithSpacersSection
                    wrappingWithoutSpacersSection
                    wrappingWithSpacersIgnoredSection
                    alignmentVariationsSection
                    spacingVariationsSection
                }
                .padding()
            }
            .navigationTitle("HWrappingHStack")
        }

        private var singleLineWithoutSpacersSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Single Line - No Spacers")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fits in one line:")
                    HorizonUI.WrappingHStack {
                        sampleButton("Button 1")
                        sampleButton("Button 2")
                        sampleButton("Button 3")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }
            }
        }

        private var singleLineWithSpacersSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Single Line - With Spacers")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Single spacer (should distribute):")
                    HorizonUI.WrappingHStack {
                        sampleButton("Left")
                        Spacer()
                        sampleButton("Right")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Multiple spacers (should distribute equally):")
                    HorizonUI.WrappingHStack {
                        sampleButton("A")
                        Spacer()
                        sampleButton("B")
                        Spacer()
                        sampleButton("C")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Leading and trailing spacers:")
                    HorizonUI.WrappingHStack {
                        Spacer()
                        sampleButton("Center")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .border(Color.gray, width: 1)
                }
            }
        }

        private var wrappingWithoutSpacersSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Wrapping - No Spacers")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Too wide, should wrap:")
                    HStack {
                        HorizonUI.WrappingHStack {
                            sampleButton("Very Long Button 1")
                            sampleButton("Very Long Button 2")
                            sampleButton("Very Long Button 3")
                            sampleButton("Very Long Button 4")
                        }
                        .border(Color.gray, width: 1)
                        Spacer()
                    }
                }
            }
        }

        private var wrappingWithSpacersIgnoredSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Wrapping - Spacers Ignored")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Spacers ignored when wrapping:")
                    HStack {
                        HorizonUI.WrappingHStack {
                            sampleButton("Very Long Button 1")
                            Spacer()
                            sampleButton("Very Long Button 2")
                            sampleButton("Very Long Button 3")
                            Spacer()
                            sampleButton("Very Long Button 4")
                        }
                        .border(Color.gray, width: 1)
                        Spacer()
                    }
                }
            }
        }

        private var alignmentVariationsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Alignment Variations")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Top alignment:")
                    HorizonUI.WrappingHStack(alignment: .top) {
                        sampleButton("Short", height: 30)
                        sampleButton("Medium Height", height: 50)
                        sampleButton("Tall Button", height: 70)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Center alignment (default):")
                    HorizonUI.WrappingHStack(alignment: .center) {
                        sampleButton("Short", height: 30)
                        sampleButton("Medium Height", height: 50)
                        sampleButton("Tall Button", height: 70)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bottom alignment:")
                    HorizonUI.WrappingHStack(alignment: .bottom) {
                        sampleButton("Short", height: 30)
                        sampleButton("Medium Height", height: 50)
                        sampleButton("Tall Button", height: 70)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }
            }
        }

        private var spacingVariationsSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Spacing Variations")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("No spacing:")
                    HorizonUI.WrappingHStack(spacing: 0) {
                        sampleButton("A")
                        sampleButton("B")
                        sampleButton("C")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Large spacing:")
                    HorizonUI.WrappingHStack(spacing: 20) {
                        sampleButton("A")
                        sampleButton("B")
                        sampleButton("C")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.gray, width: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Large line spacing (wrapping):")
                    HorizonUI.WrappingHStack(spacing: 8, lineSpacing: 20) {
                        sampleButton("Very Long Button 1")
                        sampleButton("Very Long Button 2")
                        sampleButton("Very Long Button 3")
                        sampleButton("Very Long Button 4")
                    }
                    .border(Color.gray, width: 1)
                }
            }
        }

        private func sampleButton(_ text: String, height: CGFloat = 40) -> some View {
            Text(text)
                .padding(.horizontal, 12)
                .frame(height: height)
                .background(Color.blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    HorizonUI.WrappingHStack.Storybook()
}
