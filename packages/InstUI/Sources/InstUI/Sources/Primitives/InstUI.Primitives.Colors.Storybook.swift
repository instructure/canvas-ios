//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public extension InstUI.Primitives.Colors {
    
    struct Storybook: View {
        private let colors: [ColorEntry] = Mirror(reflecting: InstUI.Primitives.Colors())
            .children
            .compactMap { child in
                guard
                    let name = child.label,
                    let color = child.value as? Color
                else { return nil }

                return ColorEntry(name: name, color: color)
            }

        public var body: some View {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 60), alignment: .top)],
                    alignment: .leading,
                    spacing: 16
                ) {
                    ForEach(colors) { entry in
                        VStack(spacing: 4) {
                            Circle()
                                .foregroundStyle(entry.color)
                                .background {
                                    if entry.hasAlpha {
                                        Self.checkeredTexture
                                            .resizable(resizingMode: .tile)
                                            .clipShape(Circle())
                                    }
                                }
                                .overlay(Circle().strokeBorder(.gray, lineWidth: 1))
                            Text(entry.name)
                        }
                    }
                }
                .padding(.all, 16)
            }
            .font(.system(size: 10))
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle(Text(verbatim: "Primitive Colors"))
            .navigationBarTitleDisplayMode(.large)
        }

        private static let checkeredTexture: Image = {
            let tileSize: CGFloat = 6
            let size = CGSize(width: tileSize * 2, height: tileSize * 2)
            let uiImage = UIGraphicsImageRenderer(size: size).image { _ in
                UIColor.white.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))
                UIRectFill(CGRect(x: tileSize, y: tileSize, width: tileSize, height: tileSize))
                UIColor(white: 0.88, alpha: 1).setFill()
                UIRectFill(CGRect(x: tileSize, y: 0, width: tileSize, height: tileSize))
                UIRectFill(CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize))
            }
            return Image(uiImage: uiImage)
        }()
    }

    struct ColorEntry: Identifiable {
        let name: String
        let color: Color
        let hasAlpha: Bool
        public var id: String { name }

        init(name: String, color: Color) {
            self.name = name
            self.color = color
            self.hasAlpha = UIColor(color).cgColor.alpha < 1
        }
    }
}

#Preview {
    NavigationStack {
        InstUI.Primitives.Colors.Storybook()
    }
}
