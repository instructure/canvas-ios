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
        HStack {
            ZStack {
                if model.todoItems.count > 2 {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .backgroundLightest]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    Text("View Full List")
                        .font(.regular16)
                        .foregroundStyle(Color.purple)
                }
                HStack {
                    Spacer()
                    addButton
                }
            }
        }
        .frame(maxHeight: 32)
    }
}

struct TodoItemDate: View {
    var todoItem: TodoItem
    let itemDueOnSameDateAsPrevious: Bool
    var isToday: Bool {
        todoItem.date.dateOnlyString == Date.now.dateOnlyString
    }

    var body: some View {
        VStack(spacing: 2) {
            if !itemDueOnSameDateAsPrevious {
                Text(todoItem.date.formatted(.dateTime.weekday()))
                    .font(.regular12)
                    .foregroundStyle(isToday ? .pink : .textDark)
                ZStack {
                    if isToday {
                        Circle()
                            .fill(.background)
                            .stroke(.pink, style: .init(lineWidth: 1))
                            .frame(width: 32, height: 32)
                    }
                    Text(todoItem.date.formatted(.dateTime.day()))
                        .font(.bold12)
                        .foregroundStyle(isToday ? .pink : .textDark)
                }
            }
        }
        .frame(minWidth: 34)
    }
}

struct TodoItemDetail: View {
    var todoItem: TodoItem
    let itemDueOnSameDateAsNext: Bool
    var isToday: Bool {
        todoItem.date.dateOnlyString == Date.now.dateOnlyString
    }

    var body: some View {
        VStack(spacing: 2) {
            contextSection
            titleSection
            timeSection
            if itemDueOnSameDateAsNext {
                InstUI.Divider()
                    .padding(.top, 3)
            }
        }
    }

    private var contextSection: some View {
        HStack(spacing: 0) {
            Text(todoItem.contextName ?? "ASD")
            Spacer()
        }
        .font(.regular12)
        .foregroundStyle(.blue) // course color
    }

    private var titleSection: some View {
        Text(todoItem.name)
            .font(.semibold14)
            .foregroundStyle(Color.textDarkest)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(40)
    }

    private var timeSection: some View {
        Text(todoItem.date.formatted(.dateTime.hour().minute()))
            .font(.regular12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public enum WidgetSize {
    case medium
    case large
}
