//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct ContextCardGradesView: View {

    let grades: Grade
    let color: Color

    private var grade: String
    private var unpostedGrade: String? = nil
    private var overrideGrade: String? = nil

    private var gradeSelected = false
    private var unpostedSelected = false

    init(grades: Grade, color: Color) {
        self.grades = grades
        self.color = color
        grade = grades.currentGrade ?? "\(Int(grades.currentScore ?? 0))%"

        if grades.unpostedCurrentGrade != nil {
            unpostedGrade = grades.unpostedCurrentGrade
        } else if let unpostedScore = grades.unpostedCurrentScore {
            unpostedGrade = "\(Int(unpostedScore))%"
        }
        if unpostedGrade == grade {
            unpostedGrade = nil
        }

        if grades.overrideGrade != nil {
            overrideGrade = grades.overrideGrade
        } else if let overrideScore = grades.overrideScore {
            overrideGrade = "\(Int(overrideScore))%"
        }

        gradeSelected = unpostedGrade == nil && overrideGrade == nil
        unpostedSelected = unpostedGrade != nil && overrideGrade == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grades")
                .font(.semibold14)
                .foregroundColor(.textDark)
            HStack() {
                ContextCardBoxView(title: grade, subTitle: unpostedGrade != nil ? "Grade before posting" : "Current Grade", selectedColor: gradeSelected ? color : nil)
                if let unpostedGrade = unpostedGrade {
                    ContextCardBoxView(title: unpostedGrade, subTitle: "Grade after posting", selectedColor: unpostedSelected ? color : nil)
                }
                if let overrideGrade = overrideGrade {
                    ContextCardBoxView(title: overrideGrade, subTitle: "Grade Override", selectedColor: color)
                }
            }
        }.padding(.horizontal, 16).padding(.vertical, 8)
    }
}

#if DEBUG
struct ContextCardGradesView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let grade = Grade(context: context)
        grade.currentScore = 11
        grade.overrideScore = 99
        grade.overrideGrade = "C"
        grade.unpostedCurrentScore = 33
        return ContextCardGradesView(grades: grade, color: .blue).previewLayout(.sizeThatFits)
    }
}
#endif
