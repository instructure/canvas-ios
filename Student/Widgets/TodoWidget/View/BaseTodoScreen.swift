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

import WidgetKit
import SwiftUI
import Core

protocol BaseTodoScreen: View {
    var model: TodoModel { get }
    var widgetSize: WidgetSize { get }
}

extension BaseTodoScreen {
    var canvasLogo: some View {
        HStack {
            Spacer()
            Link(destination: viewFullListRoute) {
                ZStack {
                    Circle()
                        .fill(Color.backgroundDanger)
                        .frame(width: 32)
                    Image("student-logomark")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.backgroundLightest)
                        .frame(width: 18, height: 18)
                }
            }
        }
    }

    var addButton: some View {
        ZStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 32)
            Image.addLine
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.backgroundLightest)
                .frame(width: 18, height: 18)
        }
        .frame(minHeight: 32)
    }

    var bottomSection: some View {
        VStack {
            Spacer()
            ZStack(alignment: .center) {
                if model.items.count > widgetSize.rawValue {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .backgroundLightest]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    Link(destination: viewFullListRoute) {
                        Text("View Full List")
                            .font(.regular16)
                            .foregroundStyle(Color.purple)
                    }
                }
                HStack {
                    Spacer()
                    Link(destination: addTodoRoute) {
                        addButton
                    }
                }
            }
        }
        .frame(maxHeight: 32)
    }
}

public enum WidgetSize: Int {
    case medium = 2
    case large = 5
}
