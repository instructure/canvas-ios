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

import Core
import SwiftUI

struct LearnerDashboardAllWidgetsTurnedOffView: View {

    var body: some View {
        InteractivePanda(
            scene: SpacePanda(),
            title: String(localized: "All widgets are turned off", bundle: .student),
            subtitle: String(localized: "Add widgets using Customize Dashboard or Dashboard Settings.", bundle: .student)
        )
        .paddingStyle(.top, .standard)
        .paddingStyle(.top, .standard)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG

#Preview {
    LearnerDashboardAllWidgetsTurnedOffView()
        .padding()
}

#endif
