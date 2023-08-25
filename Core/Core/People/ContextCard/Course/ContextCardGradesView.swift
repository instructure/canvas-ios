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
    private let grades: Grade
    private let color: Color

    private var grade: String?
    private var unpostedGrade: String?
    private var overrideGrade: String?
    private var gradeSelected = false
    private var unpostedSelected = false

    init(grades: Grade, color: Color, gradingScheme: [GradingSchemeEntry], hideQunatitativeData: Bool) {
        self.grades = grades
        self.color = color

        guard grades.currentGrade != nil || grades.currentScore != nil else { return }

        grade = {
            if hideQunatitativeData {
                return grades.currentGrade ?? grades.enrollment?.convertedLetterGrade(gradingPeriodID: grades.gradingPeriodID,
                                                                                      gradingScheme: gradingScheme)
            } else {
                return grades.currentGrade ?? "\(grades.currentScore ?? 0)%"
            }
        }()

        if grades.unpostedCurrentGrade != nil {
            unpostedGrade = grades.unpostedCurrentGrade
        } else if let unpostedScore = grades.unpostedCurrentScore {
            if hideQunatitativeData {
                unpostedGrade = grades.enrollment?.convertedLetterGrade(scorePercentage: unpostedScore,
                                                                        gradingScheme: gradingScheme)
            } else {
                unpostedGrade = "\(unpostedScore)%"
            }
        }
        if unpostedGrade == grade {
            unpostedGrade = nil
        }

        if grades.overrideGrade != nil {
            overrideGrade = grades.overrideGrade
        } else if let overrideScore = grades.overrideScore {
            if hideQunatitativeData {
                overrideGrade = grades.enrollment?.convertedLetterGrade(scorePercentage: overrideScore,
                                                                        gradingScheme: gradingScheme)
            } else {
                overrideGrade = "\(Int(overrideScore))%"
            }
        }

        gradeSelected = unpostedGrade == nil && overrideGrade == nil
        unpostedSelected = unpostedGrade != nil && overrideGrade == nil
    }

    var body: some View {
        if let grade = grade {
            VStack(alignment: .leading, spacing: 10) {
                Text("Grades")
                    .font(.semibold14)
                    .foregroundColor(.textDark)
                HStack {
                    let subTitle = unpostedGrade != nil ? Text("Grade before posting") : Text("Current Grade")
                    ContextCardBoxView(title: Text(grade), subTitle: subTitle, selectedColor: gradeSelected ? color : nil)
                        .accessibility(label: Text("\(subTitle.key ?? "") \(grade)", bundle: .core))
                        .identifier("ContextCard.currentGradeLabel")
                    if let unpostedGrade = unpostedGrade {
                        let subTitle = Text("Grade after posting")
                        ContextCardBoxView(title: Text(unpostedGrade), subTitle: subTitle, selectedColor: unpostedSelected ? color : nil)
                            .accessibility(label: Text("\(subTitle.key ?? "") \(unpostedGrade)", bundle: .core))
                            .identifier("ContextCard.unpostedGradeLabel")
                    }
                    if let overrideGrade = overrideGrade {
                        let subTitle = Text("Grade Override")

                        ContextCardBoxView(title: Text(overrideGrade), subTitle: subTitle, selectedColor: color)
                            .accessibility(label: Text("\(subTitle.key ?? "") \(overrideGrade)", bundle: .core))
                            .identifier("ContextCard.overrideGradeLabel")
                    }
                }
            }.padding(.horizontal, 16).padding(.vertical, 8)
        }
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
        return SwiftUI.Group {
            ContextCardGradesView(grades: grade, color: .blue, gradingScheme: [], hideQunatitativeData: false)
                .previewLayout(.sizeThatFits)
            ContextCardGradesView(grades: grade, color: .blue, gradingScheme: [], hideQunatitativeData: false)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
