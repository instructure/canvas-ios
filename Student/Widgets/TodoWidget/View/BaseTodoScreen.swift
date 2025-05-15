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
    }
}

struct TodoItemRow: View {
    var todoItem: TodoItem
    let itemDueOnSameDateAsPrevious: Bool
    var isToday: Bool {
        todoItem.dueDate.dateOnlyString == Date.now.dateOnlyString
    }

    var body: some View {
        HStack(spacing: 5) {
            dayView
            VStack(spacing: 1) {
                courseSection
                titleSection
                timeSection
            }
        }
    }

    private var dayView: some View {
        VStack(spacing: 2) {
            if !itemDueOnSameDateAsPrevious {
                Text(todoItem.dueDate.formatted(.dateTime.weekday()))
                    .font(.regular12)
                    .foregroundStyle(.pink)
                ZStack {
                    if isToday {
                        Circle()
                            .fill(.background)
                            .stroke(.pink, style: .init(lineWidth: 1))
                            .frame(width: 32)
                    }
                    Text(todoItem.dueDate.formatted(.dateTime.day()))
                        .font(.bold12)
                }
            }
        }
        .frame(minWidth: 34)
    }

    private var courseSection: some View {
        HStack(spacing: 0) {
            Text("🧨 | ")
            Text("EXPL 101")
            Spacer()
        }
        .font(.regular12)
        .foregroundStyle(.blue) // course color
    }

    private var titleSection: some View {
        Text(todoItem.name)
            .font(.semibold14)
            .foregroundStyle(todoItem.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(40)
    }

    private var timeSection: some View {
        Text(todoItem.dueDate.formatted(.dateTime.hour().minute()))
            .font(.regular12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .minimumScaleFactor(0.5)
    }
}

public enum WidgetSize {
    case medium
    case large
}
