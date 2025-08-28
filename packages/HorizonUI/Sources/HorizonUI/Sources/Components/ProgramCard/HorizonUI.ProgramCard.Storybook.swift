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

extension HorizonUI.ProgramCard {
    struct StoryBook: View {
        @State private var isLoading: Bool = false

        var body: some View {
            VStack {
                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: true,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "ENROLLED",
                    completionPercent: 0.3

                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: false,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "ENROLLED",
                    completionPercent: 1
                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: false,
                    isRequired: false,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "ENROLLED",
                    completionPercent: 0
                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: true,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "NOT_ENROLLED",
                    completionPercent: 0
                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: true,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "NOT_ENROLLED",
                    completionPercent: 0
                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: true,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "BLOCKED",
                    completionPercent: 0
                ) { isLoading.toggle() }

                HorizonUI.ProgramCard(
                    courseName: "Course Name Dolor Sit Amet",
                    isSelfEnrolled: true,
                    isRequired: true,
                    isLoading: $isLoading,
                    estimatedTime: "10 Hours",
                    courseStatus: "BLOCKED",
                    completionPercent: 0
                ) { isLoading.toggle() }
            }
        }
    }
}

#Preview {
    HorizonUI.ProgramCard.StoryBook()
}
