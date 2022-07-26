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

public struct QuizEditorView: View {

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @ObservedObject private var viewModel: QuizEditorViewModel

    @State var canUnpublish: Bool = true
    @State var description: String = ""
    @State var gradingType: GradingType = .points
    @State var title: String = ""
    @State var overrides: [AssignmentOverridesEditor.Override] = []
    @State var pointsPossible: Double?
    @State var published: Bool = false

    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var alert: AlertItem?

    public init(viewModel: QuizEditorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        form
            .navigationBarTitle(Text("Edit Quiz Details", bundle: .core), displayMode: .inline)
            .navBarItems(leading: {
                Button(action: {
                    env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core).fontWeight(.regular)
                })
                    .identifier("screen.dismiss")
            }, trailing: {
                Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                .disabled(viewModel.state != .ready)
                    .identifier("QuizEditor.doneButton")
            })

            .alert(item: $alert) { alert in
                switch alert {
                case .error(let error):
                    return Alert(title: Text(error.localizedDescription))
                case .removeOverride(let override):
                    return AssignmentOverridesEditor.alert(toRemove: override, from: $overrides)
                }
            }

            //.onAppear(perform: load) is this necessary?
    }

    enum AlertItem: Identifiable {
        case error(Error)
        case removeOverride(AssignmentOverridesEditor.Override)

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .removeOverride(let override):
                return "remove override \(override.id)"
            }
        }
    }

    var form: some View {
        EditorForm(isSpinning: viewModel.state != .ready) {
            titleSection
            basicSettingsSection
            attemptsSection

            AssignmentOverridesEditor(
                courseID: viewModel.courseID,
                groupCategoryID: viewModel.assignment?.groupCategoryID,
                overrides: $overrides,
                toRemove: Binding(get: {
                    if case .removeOverride(let override) = alert {
                        return override
                    }
                    return nil
                }, set: {
                    alert = $0.map { AlertItem.removeOverride($0) }
                })
            )
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        EditorSection(label: Text("Title", bundle: .core)) {
            CustomTextField(placeholder: Text("Add Title", bundle: .core),
                            text: $viewModel.title,
                            identifier: "QuizEditor.titleField",
                            accessibilityLabel: Text("Title", bundle: .core))
        }

        EditorSection(label: Text("Description", bundle: .core)) {
            RichContentEditor(
                placeholder: NSLocalizedString("Add description", comment: ""),
                a11yLabel: NSLocalizedString("Description", comment: ""),
                html: $viewModel.description,
                context: .course(viewModel.courseID),
                uploadTo: .context(.course(viewModel.courseID)),
                height: $rceHeight,
                canSubmit: $rceCanSubmit,
                error: Binding(get: {
                    if case .error(let error) = alert { return error }
                    return nil
                }, set: {
                    if let error = $0 { alert = .error(error) }
                })
            )
                .frame(height: max(200, rceHeight))
        }
    }

    @ViewBuilder
    private var basicSettingsSection: some View {
        EditorSection {
            quizTypeRow
            if (viewModel.shouldShowPublishedToggle) {
                Divider()
                Toggle(isOn: $viewModel.published) { Text("Publish", bundle: .core) }
                    .font(.semibold16).foregroundColor(.textDarkest)
                    .padding(16)
                    .identifier("QuizEditor.publishedToggle")
            }
            Divider()
            //assignmentGroupRow
            //Divider()
            Toggle(isOn: $viewModel.shuffleAnswers) { Text("Shuffle Answers", bundle: .core) }
                .font(.semibold16).foregroundColor(.textDarkest)
                .padding(16)
                .identifier("QuizEditor.shuffleAnswersToggle")
                .background(Color.backgroundLightest)
            Divider()
            Toggle(isOn: $viewModel.timeLimit) { Text("Time Limit", bundle: .core) }
                .font(.semibold16).foregroundColor(.textDarkest)
                .padding(16)
                .identifier("QuizEditor.timeLimitToggle")
                .background(Color.backgroundLightest)
            if viewModel.timeLimit {
                Divider()
                DoubleFieldRow(
                    label: Text("Length in minutes", bundle: .core),
                    placeholder: "--",
                    value: $viewModel.lengthInMinutes
                )
                .identifier("QuizEditor.lengthInMinutes")
            }
        }
    }

    @ViewBuilder
    private var attemptsSection: some View {
        EditorSection {
            Toggle(isOn: $viewModel.allowMultipleAttempts) { Text("Allow Multiple Attempts", bundle: .core) }
                .font(.semibold16).foregroundColor(.textDarkest)
                .padding(16)
                .identifier("QuizEditor.allowMultipleAttemptsToggle")
                .background(Color.backgroundLightest)
            if viewModel.allowMultipleAttempts {
                Divider()
                scoreToKeepRow
                Divider()
                DoubleFieldRow(
                    label: Text("Allowed Attempts", bundle: .core),
                    placeholder: NSLocalizedString("Unlimited", bundle: .core, comment: ""),
                    value: $viewModel.allowedAttempts
                )
                .identifier("QuizEditor.lengthInMinutes")
            }
        }
    }

    @ViewBuilder
    private var quizTypeRow: some View {
        ButtonRow(action: {
            let options = QuizType.allCases
            self.env.router.show(ItemPickerViewController.create(
                title: NSLocalizedString("Quiz Type", comment: ""),
                sections: [ ItemPickerSection(items: options.map {
                    ItemPickerItem(title: $0.sectionTitle)
                }), ],
                selected: options.firstIndex(of: viewModel.quizType).flatMap {
                    IndexPath(row: $0, section: 0)
                },
                didSelect: { viewModel.quizType = options[$0.row] }
            ), from: controller)
        }, content: {
            Text("Quiz Type", bundle: .core)
            Spacer()
            Text(viewModel.quizType.sectionTitle)
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
            .identifier("QuizEditor.quizTypeButton")
    }

    @ViewBuilder
    private var assignmentGroupRow: some View {
        Text("Assignment Group", bundle: .core)

       /* ButtonRow(action: {
            let options = viewModel.assignmentGroups
            self.env.router.show(ItemPickerViewController.create(
                title: NSLocalizedString("Quiz Type", comment: ""),
                sections: [ ItemPickerSection(items: options.map {
                    ItemPickerItem(title: $0.sectionTitle)
                }), ],
                selected: options.firstIndex(of: viewModel.quizType).flatMap {
                    IndexPath(row: $0, section: 0)
                },
                didSelect: { viewModel.quizType = options[$0.row] }
            ), from: controller)
        }, content: {
            Text("Quiz Type", bundle: .core)
            Spacer()
            Text(viewModel.quizType.sectionTitle)
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
            .identifier("QuizEditor.quizTypeButton")*/
    }

    @ViewBuilder
    private var scoreToKeepRow: some View {
        ButtonRow(action: {
            let options = ScoringPolicy.allCases
            self.env.router.show(ItemPickerViewController.create(
                title: NSLocalizedString("Quiz Score to Keep", comment: ""),
                sections: [ ItemPickerSection(items: options.map {
                    ItemPickerItem(title: $0.text)
                }), ],
                selected: options.firstIndex(of: viewModel.scoreToKeep ?? ScoringPolicy.keep_highest).flatMap {
                    IndexPath(row: $0, section: 0)
                },
                didSelect: { viewModel.scoreToKeep = options[$0.row] }
            ), from: controller)
        }, content: {
            Text("Quiz Score to Keep", bundle: .core)
            Spacer()
            Text(viewModel.scoreToKeep?.text ?? "")
                .font(.medium16).foregroundColor(.textDark)
            Spacer().frame(width: 16)
            DisclosureIndicator()
        })
            .identifier("QuizEditor.quizScoreToKeepButton")
    }

    func save() {
    }
/*
    func save() {
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        let originalOverrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) }
        guard
            let assignmentID = assignmentID,
            let assignment = assignment,
            assignment.details != description ||
            assignment.gradingType != gradingType ||
            assignment.pointsPossible != pointsPossible ||
            assignment.published != published ||
            assignment.name != title ||
            originalOverrides != overrides
        else {
            isSaving = false
            return env.router.dismiss(controller)
        }
        let (dueAt, unlockAt, lockAt, apiOverrides) = AssignmentOverridesEditor.apiOverrides(for: assignment.id, from: overrides)
        UpdateAssignment(
            courseID: courseID,
            assignmentID: assignmentID,
            description: description,
            dueAt: dueAt,
            gradingType: gradingType,
            lockAt: lockAt,
            name: title,
            overrides: originalOverrides == overrides ? nil : apiOverrides,
            pointsPossible: pointsPossible,
            published: published,
            unlockAt: unlockAt
        ).fetch { result, _, fetchError in performUIUpdate {
            alert = fetchError.map { .error($0) }
            isSaving = false
            if result != nil {
                GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
                    .fetch(force: true) // updated overrides & allDates aren't in result
                env.router.dismiss(controller)
            }
        } }
    }
 */
}
