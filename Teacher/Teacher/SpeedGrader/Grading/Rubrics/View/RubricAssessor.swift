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

import Core
import SwiftUI

struct RubricAssessor: View {
    let assignment: Assignment
    let submission: Submission
    let currentScore: Double
    let containerFrameInGlobal: CGRect
    @Binding var comment: String
    @Binding var commentID: String?
    @Binding var assessments: APIRubricAssessmentMap

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State private var isSaving = false
    @State private var assessmentsChangedDuringUpload = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Rubric", bundle: .teacher)
                    .font(.heavy24).foregroundColor(.textDarkest)
                    .accessibilityAddTraits(.isHeader)
                Text("\(currentScore, specifier: "%g") out of \(assignment.rubricPointsPossible ?? 0, specifier: "%g")", bundle: .teacher)
                    .font(.medium14).foregroundColor(.textDark)
            }
            Spacer()

            if isSaving {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle(size: 24))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)

        VStack(spacing: 12) {
            ForEach(assignment.rubric ?? [], id: \.id) { criteria in
                RubricCriteriaAssessor(criteria: criteria)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 16)
        .onChange(of: assessments) { _ in
            rubricAssessmentDidChange()
        }
    }

    private func RubricCriteriaAssessor(criteria: Rubric) -> some View { VStack(alignment: .leading, spacing: 0) {
        let assessment = assessments[criteria.id] ?? submission.rubricAssessments?[criteria.id].map {
            APIRubricAssessment(comments: $0.comments, points: $0.points, rating_id: $0.ratingID)
        }

        HStack { Spacer() }
        Text(criteria.desc)
            .font(.semibold16).foregroundColor(.textDarkest)
        if criteria.ignoreForScoring {
            Text("This criterion will not impact the score.", bundle: .teacher)
                .font(.regular12).foregroundColor(.textDark)
                .padding(.top, 2)
        }

        FlowStack(spacing: UIOffset(horizontal: 8, vertical: 8)) { leading, top in
            if !assignment.freeFormCriterionCommentsOnRubric, let ratings = criteria.ratings {
                ForEach(ratings.reversed(), id: \.id) { rating in
                    let isSelected = assessment?.rating_id == rating.id
                    let value = Text((isSelected ? assessment?.points : nil) ?? rating.points)
                    let tooltip = rating.desc + (rating.longDesc.isEmpty ? "" : "\n" + rating.longDesc)

                    RubricCircle(isOn: Binding(get: { isSelected }, set: { newValue in
                        assessments[criteria.id] = newValue ? APIRubricAssessment(
                            comments: assessment?.comments,
                            points: rating.points,
                            rating_id: rating.id
                        ) : APIRubricAssessment(comments: assessment?.comments)
                    }), tooltip: tooltip, containerFrame: containerFrameInGlobal) {
                        value
                    }
                    .accessibility(value: value)
                    .accessibility(label: rating.desc.isEmpty ? value : Text(rating.desc))
                    .alignmentGuide(.leading, computeValue: leading)
                    .alignmentGuide(.top, computeValue: top)
                }
            }
            customGradeToggle(
                criteria: criteria,
                assessment: assessment,
                leading: leading,
                top: top
            )
        }
        .padding(.top, 8)

        let showAdd = assignment.freeFormCriterionCommentsOnRubric && assessment?.comments?.isEmpty != false
        let showLong = criteria.longDesc.isEmpty == false
        if showAdd || showLong {
            addButtons(
                criteria: criteria,
                assessment: assessment,
                showAdd: showAdd,
                showLong: showLong
            )
        }
    }
    }

    private func customGradeToggle(
        criteria: Rubric,
        assessment: APIRubricAssessment?,
        leading: @escaping (ViewDimensions) -> CGFloat,
        top: @escaping (ViewDimensions) -> CGFloat
    ) -> some View {
        let customGrade = (
            assignment.freeFormCriterionCommentsOnRubric ||
                assessment?.rating_id == nil ||
                assessment?.rating_id == ""
        )
            ? assessment?.points : nil

        let binding = Binding(
            get: { customGrade != nil },
            set: { newValue in
                if newValue {
                    promptCustomGrade(criteria, assessment: assessment)
                } else {
                    assessments[criteria.id] = APIRubricAssessment(comments: assessment?.comments)
                }
            }
        )

        return RubricCircle(isOn: binding) {
            if let grade = customGrade {
                Text(grade)
            } else {
                Image.addSolid
            }
        }
        .accessibilityLabel(Text("Add custom grade", bundle: .teacher))
        .accessibilityRemoveTraits(.isImage)
        .alignmentGuide(.leading, computeValue: leading)
        .alignmentGuide(.top, computeValue: top)
    }

    private func addButtons(
        criteria: Rubric,
        assessment: APIRubricAssessment?,
        showAdd: Bool,
        showLong: Bool
    ) -> some View {
        HStack(spacing: 6) {
            if showAdd {
                Button(
                    action: {
                        withAnimation(.default) {
                            comment = ""
                            commentID = criteria.id
                        }
                    },
                    label: {
                        Text("Add Comment", bundle: .teacher)
                            .font(.medium14)
                            .foregroundColor(.accentColor)
                    }
                )
                .identifier("SpeedGrader.Rubric.\(criteria.id).addCommentButton")
            }
            if showAdd, showLong {
                Text(verbatim: "•")
                    .font(.regular12)
                    .foregroundColor(.textDark)
            }
            if showLong {
                Button(
                    action: {
                        let web = CoreWebViewController()
                        web.title = criteria.desc
                        web.webView.loadHTMLString(criteria.longDesc)
                        web.addDoneButton(side: .right)
                        env.router.show(web, from: controller, options: .modal(embedInNav: true))
                    },
                    label: {
                        Text("View Long Description", bundle: .teacher)
                            .font(.medium14)
                            .foregroundColor(.accentColor)
                    }
                )
            }
        }
        .padding(.top, 8)
    }

    private func freeFormRubricCommentBubbleWithEditButton(_ comment: String, criteriaID: String) -> some View {
        HStack {
            Text(comment)
                .font(.regular14)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(CommentBackground()
                    .fill(Color.backgroundLight)
                )
            Spacer()
            Button(action: { withAnimation(.default) {
                self.comment = comment
                commentID = criteriaID
            } }, label: {
                Text("Edit", bundle: .teacher)
                    .font(.medium14).foregroundColor(.accentColor)
            })
        }
        .padding(.top, 8)
    }

    private func promptCustomGrade(_ criteria: Rubric, assessment: APIRubricAssessment?) {
        let format = String(localized: "out_of_g_pts", bundle: .core)
        let message = String.localizedStringWithFormat(format, criteria.points)
        let prompt = UIAlertController(title: String(localized: "Customize Grade", bundle: .teacher), message: message, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = ""
            field.returnKeyType = .done
            field.addTarget(prompt, action: #selector(UIAlertController.performOKAlertAction), for: .editingDidEndOnExit)
            field.accessibilityLabel = String(localized: "Grade", bundle: .teacher)
        }
        prompt.addAction(AlertAction(String(localized: "OK", bundle: .teacher)) { _ in
            let text = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            assessments[criteria.id] = APIRubricAssessment(
                comments: assessment?.comments,
                points: DoubleFieldRow.formatter.number(from: text)?.doubleValue
            )
        })
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        env.router.show(prompt, from: controller, options: .modal())
    }

    private func rubricAssessmentDidChange() {
        if isSaving {
            assessmentsChangedDuringUpload = true
        } else {
            uploadRubricAssessments()
        }
    }

    private func uploadRubricAssessments() {
        if assessments.isEmpty {
            isSaving = false
            return
        }

        isSaving = true
        let prevAssessments = submission.rubricAssessments // create map only once
        var nextAssessments: APIRubricAssessmentMap = [:]

        for criteria in assignment.rubric ?? [] {
            nextAssessments[criteria.id] = assessments[criteria.id] ?? prevAssessments?[criteria.id].map {
                APIRubricAssessment(comments: $0.comments, points: $0.points, rating_id: $0.ratingID)
            }
        }

        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            rubricAssessment: nextAssessments
        ).fetch { _, _, error in performUIUpdate {
            handleUploadFinished(error: error)
        } }
    }

    private func handleUploadFinished(error: Error?) {
        if assessmentsChangedDuringUpload {
            assessmentsChangedDuringUpload = false
            uploadRubricAssessments()
            return
        }

        isSaving = false

        if let error = error {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default))
        env.router.show(alert, from: controller, options: .modal())
    }
}
