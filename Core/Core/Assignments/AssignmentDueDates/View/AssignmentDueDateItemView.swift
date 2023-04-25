//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct AssignmentDueDateItemView: View {
    private var model: AssignmentDueDateItemViewModel

    public init(model: AssignmentDueDateItemViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.title)
                .font(.heavy24).foregroundColor(.textDarkest)
                .padding(16)
            Section(
                label: Text("For", bundle: .core),
                content: { Text(model.assignee) }
            )
            Section(
                label: Text("Available From", bundle: .core),
                content: {
                    if let fromEmptyAccessibility = model.fromEmptyAccessibility {
                        Text(model.from).accessibilityLabel(fromEmptyAccessibility)
                    } else {
                        Text(model.from)
                    }
                }
            )
            Section(
                label: Text("Available Until", bundle: .core),
                content: {
                    if let untilEmptyAccessibility = model.untilEmptyAccessibility {
                        Text(model.until).accessibilityLabel(untilEmptyAccessibility)
                    } else {
                        Text(model.until)
                    }
                }
            )
        }
    }

    struct Section<Label: View, Content: View>: View {
        let content: Content
        let label: Label

        init(label: Label, @ViewBuilder content: () -> Content) {
            self.content = content()
            self.label = label
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                label
                    .font(.semibold16).foregroundColor(.textDark)
                    .padding(.bottom, 4)
                content
            }
            .padding(16)
            .accessibilityElement(children: .combine)
            Divider().padding(.horizontal, 16)
        }
    }
}

#if DEBUG

struct AssignmentDueDateItemView_Previews: PreviewProvider {
    private static let context = PreviewEnvironment().globalDatabase.viewContext

    static var previews: some View {
        let dueDate = AssignmentDate.save(.make(), assignmentID: "1", in: context)
        let model = AssignmentDueDateItemViewModel(item: dueDate)
        AssignmentDueDateItemView(model: model)
            .previewLayout(.sizeThatFits)
    }
}

#endif
