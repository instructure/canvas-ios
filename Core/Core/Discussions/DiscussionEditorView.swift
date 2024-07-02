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

public struct DiscussionEditorView: View {
    let context: Context
    let topicID: String?
    let isAnnouncement: Bool
    let filePicker = FilePicker()

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var allowRating: Bool = false
    @State var assignment: Assignment?
    @State var attachment: URL?
    @State var canUnpublish: Bool = true
    @State var delayedPostAt: Date?
    @State var gradingType: GradingType = .points
    @State var lockAt: Date?
    @State var locked: Bool = true
    @State var message: String = ""
    @State var onlyGradersCanRate: Bool = false
    @State var overrides: [AssignmentOverridesEditor.Override] = []
    @State var pointsPossible: Double?
    @State var published: Bool = false
    @State var requireInitialPost: Bool = false
    @State var sections: Set<CourseSection> = []
    @State var sortByRating: Bool = false
    @State var threaded: Bool = false
    @State var title: String = ""
    @State var topic: DiscussionTopic?

    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
    @State var isTeacher = false
    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var alert: AlertItem?

    public init(context: Context, topicID: String?, isAnnouncement: Bool) {
        self.context = context
        self.topicID = topicID
        self.isAnnouncement = isAnnouncement
    }

    public var body: some View {
        form
            .navigationBarTitle(isAnnouncement ?
                topicID == nil ? Text("New Announcement", bundle: .core) : Text("Edit Announcement", bundle: .core) :
                topicID == nil ? Text("New Discussion", bundle: .core) : Text("Edit Discussion", bundle: .core),
                displayMode: .inline
            )
            .navigationBarItems(
                leading: Button(action: {
                    env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core).font(.regular17)
                })
                    .identifier("screen.dismiss"),
                trailing: HStack {
                    Button(action: attach, label: {
                        Image.paperclipLine.badge(attachment == nil ? nil : 1)
                    })
                        .accessibility(label: attachment == nil ? Text("Add Attachment", bundle: .core) : Text("Remove Attachment", bundle: .core))
                        .disabled(isLoading || isSaving)
                        .identifier("DiscussionEditor.attachmentButton")
                    Button(action: save, label: {
                        Text("Done", bundle: .core).font(.bold17)
                    })
                        .disabled(isLoading || isSaving)
                        .identifier("DiscussionEditor.doneButton")
                }
            )

            .alert(item: $alert) { alert in
                switch alert {
                case .error(let error):
                    return Alert(title: Text(error.localizedDescription))
                case .removeFile(let filename):
                    return Alert(
                        title: Text("Remove Attachment?", bundle: .core),
                        message: Text(filename),
                        primaryButton: .destructive(Text("Remove", bundle: .core)) {
                            attachment = nil
                        },
                        secondaryButton: .cancel()
                    )
                case .removeOverride(let override):
                    return AssignmentOverridesEditor.alert(toRemove: override, from: $overrides)
                case .emptyDescription:
                    return Alert(title: Text("A description is required", bundle: .core))
                }
            }

            .onAppear(perform: load)
    }

    enum AlertItem: Identifiable {
        case error(Error)
        case removeFile(String)
        case removeOverride(AssignmentOverridesEditor.Override)
        case emptyDescription

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .removeFile(let filename):
                return "remove \(filename)"
            case .removeOverride(let override):
                return "remove override \(override.id)"
            case .emptyDescription:
                return "empty description"
            }
        }
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Title", bundle: .core)) {
                CustomTextField(placeholder: Text("Add Title", bundle: .core),
                                text: $title,
                                identifier: "DiscussionEditor.titleField",
                                accessibilityLabel: Text("Title", bundle: .core))
            }

            EditorSection(label: Text("Description", bundle: .core)) {
                RichContentEditor(
                    placeholder: String(localized: "Add description", bundle: .core),
                    a11yLabel: String(localized: "Description", bundle: .core),
                    html: $message,
                    context: context,
                    uploadTo: .context(context),
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

            EditorSection(label: Text("Options", bundle: .core)) {
                if canUnpublish, isTeacher, !isAnnouncement {
                    Toggle(isOn: $published) { Text("Publish", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.publishedToggle")
                    Divider()
                }
                if assignment == nil, context.contextType == .course {
                    ButtonRow(action: pickSections, content: {
                        Text("Sections", bundle: .core)
                        Spacer()
                        (sections.isEmpty ? Text("All", bundle: .core) :
                            sections.count == 1 ? sections.first.map { Text($0.name) } :
                            Text("\(sections.count) sections", bundle: .core)
                        )
                            .font(.medium16).foregroundColor(.textDark)
                        Spacer().frame(width: 16)
                        DisclosureIndicator()
                    })
                        .identifier("DiscussionEditor.sectionsButton")
                    Divider()
                }
                if isAnnouncement {
                    Toggle(isOn: Binding(get: { delayedPostAt != nil }, set: { newValue in
                        withAnimation(.default) {
                            delayedPostAt = newValue ? Clock.now.startOfDay() : nil
                        }
                    })) {
                        Text("Delay posting", bundle: .core)
                    }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.delayedPostAtToggle")
                    Divider()
                    if let delayedPostAt = delayedPostAt {
                        ButtonRow(action: { CoreDatePicker.showDatePicker(for: $delayedPostAt, maxDate: lockAt, from: controller) }, content: {
                            Text("Post at", bundle: .core)
                            Spacer()
                            Text(DateFormatter.localizedString(from: delayedPostAt, dateStyle: .medium, timeStyle: .short))
                        })
                        .identifier("DiscussionEditor.delayedPostAtPicker")
                        Divider()
                    }
                    Toggle(isOn: Binding(get: { !locked }, set: { newValue in
                        withAnimation(.default) { locked = !newValue }
                    })) {
                        Text("Allow users to comment", bundle: .core)
                    }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.lockedToggle")
                    Divider()
                } else {
                    Toggle(isOn: $threaded) { Text("Allow threaded replies", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.threadedToggle")
                    Divider()
                }
                if !isAnnouncement || locked == false {
                    Toggle(isOn: $requireInitialPost) { Text("Users must post before seeing replies", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.requireInitialPostToggle")
                    Divider()
                }
                Toggle(isOn: $allowRating.animation(.default)) { Text("Allow liking", bundle: .core) }
                    .font(.semibold16).foregroundColor(.textDarkest)
                    .padding(16)
                    .identifier("DiscussionEditor.allowRatingToggle")
                Divider()
                if allowRating {
                    Toggle(isOn: $onlyGradersCanRate) { Text("Only graders can like", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.onlyGradersCanRateToggle")
                    Divider()
                    Toggle(isOn: $sortByRating) { Text("Sort by likes", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("DiscussionEditor.sortByRatingToggle")
                    Divider()
                }
                if assignment != nil {
                    DoubleFieldRow(
                        label: Text("Points", bundle: .core),
                        placeholder: "--",
                        value: $pointsPossible
                    )
                        .identifier("DiscussionEditor.pointsField")
                    Divider()
                    ButtonRow(action: {
                        let options = GradingType.allCases
                        self.env.router.show(ItemPickerViewController.create(
                            title: String(localized: "Display Grade as", bundle: .core),
                            sections: [ ItemPickerSection(items: options.map {
                                ItemPickerItem(title: $0.string)
                            }) ],
                            selected: options.firstIndex(of: gradingType).flatMap {
                                IndexPath(row: $0, section: 0)
                            },
                            didSelect: { gradingType = options[$0.row] }
                        ), from: controller)
                    }, content: {
                        Text("Display Grade as", bundle: .core)
                        Spacer()
                        Text(gradingType.string)
                            .font(.medium16).foregroundColor(.textDark)
                        Spacer().frame(width: 16)
                        DisclosureIndicator()
                    })
                        .identifier("DiscussionEditor.gradingTypeButton")
                }
            }

            if let assignment = assignment {
                AssignmentOverridesEditor(
                    courseID: assignment.courseID,
                    groupCategoryID: topic?.groupCategoryID,
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
            } else if isTeacher, !isAnnouncement {
                EditorSection(label: Text("Availability", bundle: .core)) {
                    ButtonRow(action: { CoreDatePicker.showDatePicker(for: $delayedPostAt, maxDate: lockAt, from: controller) }, content: {
                        Text("Available from", bundle: .core)
                        Spacer()
                        if let delayedPostAt = delayedPostAt {
                            Text(DateFormatter.localizedString(from: delayedPostAt, dateStyle: .medium, timeStyle: .short))
                        }
                    })

                    Divider()
                    ButtonRow(action: { CoreDatePicker.showDatePicker(for: $lockAt, minDate: delayedPostAt, from: controller) }, content: {
                        Text("Available until", bundle: .core)
                        Spacer()
                        if let lockAt = lockAt {
                            Text(DateFormatter.localizedString(from: lockAt, dateStyle: .medium, timeStyle: .short))
                        }
                    })

                }
            }
        }
    }

    func attach() {
        if let file = topic?.attachments?.first, file.url == attachment {
            alert = .removeFile(file.displayName ?? file.filename)
        } else if let url = attachment {
            alert = .removeFile(url.lastPathComponent)
        } else {
            filePicker.pickAttachment(from: controller) { result in
                switch result {
                case .success(let url):
                    attachment = url
                case .failure(let attachmentError):
                    alert = .error(attachmentError)
                }
            }
        }
    }

    func pickSections() {
        env.router.show(CoreHostingController(DiscussionSectionsPicker(
            courseID: context.id,
            selection: $sections
        )), from: controller)
    }

    func load() {
        guard !isLoaded else { return }
        loadIsTeacher()
        guard let topicID = topicID else {
            isLoading = false
            isLoaded = true
            return
        }
        let useCase = GetDiscussionTopic(context: context, topicID: topicID)
        useCase.fetch(force: true) { _, _, fetchError in performUIUpdate {
            topic = env.database.viewContext.fetch(scope: useCase.scope).first
            allowRating = topic?.allowRating == true
            assignment = topic?.assignment
            attachment = topic?.attachments?.first?.url
            canUnpublish = topic?.canUnpublish != false
            delayedPostAt = topic?.delayedPostAt
            locked = topic?.locked == true
            lockAt = topic?.lockAt
            message = topic?.message ?? ""
            onlyGradersCanRate = topic?.onlyGradersCanRate == true
            published = topic?.published ?? false
            requireInitialPost = topic?.requireInitialPost == true
            sections = topic?.sections ?? []
            sortByRating = topic?.sortByRating == true
            threaded = topic?.discussionType == "threaded"
            title = topic?.title ?? ""

            guard let assignmentID = topic?.assignmentID, context.contextType == .course else {
                gradingType = .points
                pointsPossible = nil
                isLoading = false
                isLoaded = true
                alert = fetchError.map { .error($0) }
                return
            }

            let useCase = GetAssignment(courseID: context.id, assignmentID: assignmentID, include: [ .overrides ])
            useCase.fetch(force: true) { _, _, fetchError in performUIUpdate {
                assignment = env.database.viewContext.fetch(scope: useCase.scope).first
                gradingType = assignment?.gradingType ?? .points
                overrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) } ?? []
                pointsPossible = assignment?.pointsPossible

                isLoading = false
                isLoaded = true
                alert = fetchError.map { .error($0) }
            } }
        } }
    }

    func loadIsTeacher() {
        if context.contextType == .course {
            loadIsTeacher(courseID: context.id)
        } else if context.contextType == .group {
            let useCase = GetGroup(groupID: context.id)
            useCase.fetch { _, _, _ in performUIUpdate {
                let group: Group? = env.database.viewContext.fetch(scope: useCase.scope).first
                if let courseID = group?.courseID {
                    loadIsTeacher(courseID: courseID)
                }
            } }
        }
    }

    func loadIsTeacher(courseID: String) {
        let useCase = GetCourse(courseID: courseID)
        useCase.fetch { _, _, _ in performUIUpdate {
            let course: Course? = env.database.viewContext.fetch(scope: useCase.scope).first
            isTeacher = course?.hasTeacherEnrollment == true
        } }
    }

    func save() {
        if isAnnouncement && message.isEmpty {
            alert = .emptyDescription
            return
        }
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        UpdateDiscussionTopic(context: context, topicID: topicID, form: [
            .allow_rating: .bool(allowRating),
            .attachment: attachment?.isFileURL == true ? attachment.map { APIFormDatum.file(
                filename: $0.lastPathComponent,
                type: "application/octet-stream",
                at: $0
            ) } : nil,
            .delayed_post_at: .date(delayedPostAt),
            .discussion_type: .string(threaded ? "threaded" : "side_comment"),
            .is_announcement: .bool(isAnnouncement),
            .locked: isAnnouncement ? .bool(locked) : nil,
            .lock_at: .date(lockAt),
            .message: .string(message),
            .only_graders_can_rate: .bool(allowRating && onlyGradersCanRate),
            .published: .bool(isTeacher && !isAnnouncement ? published : true),
            .remove_attachment: attachment == nil && topic?.attachments?.first != nil ? .bool(true) : nil,
            .require_initial_post: .bool(requireInitialPost),
            .sort_by_rating: .bool(allowRating && sortByRating),
            .specific_sections: .string(sections.isEmpty ? "all" : sections.map { $0.id } .sorted().joined(separator: ",")),
            .title: .string(title)
        ]).fetch { result, _, fetchError in performUIUpdate {
            alert = fetchError.map { .error($0) }
            if fetchError == nil, result != nil {
                saveAssignment()
            } else {
                isSaving = false
            }
        } }
    }

    func saveAssignment() {
        let originalOverrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) }
        guard
            let assignment = assignment,
            assignment.gradingType != gradingType ||
            assignment.pointsPossible != pointsPossible ||
            originalOverrides != overrides
        else {
            isSaving = false
            return env.router.dismiss(controller)
        }
        let (dueAt, unlockAt, lockAt, apiOverrides) = AssignmentOverridesEditor.apiOverrides(for: assignment.id, from: overrides)
        UpdateAssignment(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            dueAt: dueAt,
            gradingType: gradingType,
            lockAt: lockAt,
            overrides: originalOverrides == overrides ? nil : apiOverrides,
            pointsPossible: pointsPossible,
            unlockAt: unlockAt
        ).fetch { result, _, fetchError in performUIUpdate {
            alert = fetchError.map { .error($0) }
            isSaving = false
            if result != nil {
                GetAssignment(courseID: assignment.courseID, assignmentID: assignment.id, include: [ .overrides ])
                    .fetch(force: true) // updated overrides & allDates aren't in result
                env.router.dismiss(controller)
            }
        } }
    }
}
