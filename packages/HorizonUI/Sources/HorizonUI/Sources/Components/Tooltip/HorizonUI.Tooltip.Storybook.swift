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

extension HorizonUI.Tooltip {
    struct Storybook: View {
        @State private var isVisible: Bool = false

        @State private var visible: [Edge: [HorizonUI.Tooltip.Style: Bool]] = {
            var map = [Edge: [HorizonUI.Tooltip.Style: Bool]]()
            for edge in Edge.allCases {
                var styleMap = [HorizonUI.Tooltip.Style: Bool]()
                for style in HorizonUI.Tooltip.Style.allCases {
                    styleMap[style] = false
                }
                map[edge] = styleMap
            }
            return map
        }()

        var body: some View {
            VStack(spacing: 8) {
                ForEach(Edge.allCases, id: \.self) { edge in
                    Text(edge.label)
                    HStack {
                        Spacer()
                        ForEach(HorizonUI.Tooltip.Style.allCases, id: \.self) { style in
                            Button(style.rawValue) {
                                visible[edge]?[style] = true
                            }
                            .tooltip(
                                isPresented: Binding(
                                    get: { visible[edge]?[style] ?? false },
                                    set: { newValue in visible[edge]?[style] = newValue }
                                ),
                                arrowEdge: edge,
                                style: style
                            ) {
                                Text("A Tooltip")
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

extension Edge {
    var label: String {
        switch self {
        case .bottom: "Bottom"
        case .leading: "Leading"
        case .top: "Top"
        case .trailing: "Trailing"
        }
    }
}

#Preview {
    HorizonUI.Tooltip.Storybook()
}
