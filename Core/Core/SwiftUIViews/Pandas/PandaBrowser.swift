//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct PandaBrowser: View {
    private enum PandaType: String, CaseIterable, Identifiable {
        var id: Self { self }

        case discussions = "Discussions"
        case files = "Files"
        case grades = "Grades"
        case space = "Space"
        case people = "People"
    }
    @State private var selectedPanda: PandaType = PandaType.allCases.last!

    public var body: some View {
        VStack {
            Spacer()
            panda
            Spacer()
            Picker("", selection: $selectedPanda) {
                ForEach(PandaType.allCases) { panda in
                    Text(panda.rawValue)
                }
            }
                .padding()
        }
    }

    @ViewBuilder
    private var panda: some View {
        switch selectedPanda {
        case .discussions:
            InteractivePanda(scene: DiscussionsPanda())
        case .files:
            InteractivePanda(scene: FilesPanda())
        case .grades:
            InteractivePanda(scene: GradesPanda())
        case .space:
            InteractivePanda(scene: SpacePanda())
        case .people:
            InteractivePanda(scene: PeoplePanda())
        }
    }
}

struct PandaBrowser_Previews: PreviewProvider {
    static var previews: some View {
        PandaBrowser()
    }
}
