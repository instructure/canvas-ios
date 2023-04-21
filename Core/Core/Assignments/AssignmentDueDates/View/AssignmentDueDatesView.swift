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

public struct AssignmentDueDatesView: View {
    @ObservedObject private var model: AssignmentDueDatesViewModel

    init(model: AssignmentDueDatesViewModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            switch model.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            case .data:
                VStack(spacing: 0) {
                    ForEach(model.dueDates) { dueDate in
                        AssignmentDueDateItemView(model: dueDate)
                    }
                }
            case .empty, .error:
                Text("Something went wrong", bundle: .core)
                    .font(.regular16).foregroundColor(.textDanger)
                    .multilineTextAlignment(.center)
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
    }
}

#if DEBUG

struct AssignmentDueDateView_Previews: PreviewProvider {

    private static let context = PreviewEnvironment().globalDatabase.viewContext

    static var previews: some View {
        let dueDates = [AssignmentDate.save(.make(), assignmentID: "1", in: context)]
        AssignmentDueDatesAssembly.makePreview(dueDates: dueDates)
            .previewLayout(.sizeThatFits)
    }
}

#endif
