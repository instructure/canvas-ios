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

public struct FileEditorView: View {
    private enum AlertItem: Identifiable {
        case error(Error)
        case deleteConfirmation
        case itemDoesNotExist

        var id: String {
            switch self {
            case .error(let error): return error.localizedDescription
            case .deleteConfirmation: return "deleteConfirmation"
            case .itemDoesNotExist: return "itemDoesNotExist"
            }
        }
    }

    let context: Context?
    let itemID: ItemID
    enum ItemID {
        case file(String)
        case folder(String)
    }

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var name: String = ""
    @State var access: Access = .published
    @State var unlockAt: Date?
    @State var lockAt: Date?
    @State var copyright: String = ""
    @State var justification: UseJustification = .own_copyright
    @State var license: License = .cc_by

    @State var isLoading = true
    @State var isLoaded = false
    @State var usageRightsRequired = false
    @State var isSaving = false
    @State private var alertItem: AlertItem?

    public init(context: Context? = nil, fileID: String) {
        self.context = context
        self.itemID = .file(fileID)
    }

    public init(folderID: String) {
        self.context = nil
        self.itemID = .folder(folderID)
    }

    var isFile: Bool {
        switch itemID {
        case .file: return true
        case .folder: return false
        }
    }

    public var body: some View {
        form
            .navigationBarTitleView(isFile
                                        ? String(localized: "Edit File", bundle: .core)
                                        : String(localized: "Edit Folder", bundle: .core)
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: dismiss, label: {
                    Text("Cancel", bundle: .core)
                })
                    .identifier("screen.dismiss"),
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                    .disabled(isLoading || isSaving)
                    .identifier("FileEditor.doneButton")
            )
            .navigationBarStyle(.modal)

            .alert(item: $alertItem) {
                switch $0 {
                case .error(let error):
                    return Alert(title: Text(error.localizedDescription))
                case .deleteConfirmation:
                    let message = isFile ? nil : Text("Deleting this folder will also delete all of the files inside the folder.", bundle: .core)
                    return Alert(title: Text("Are you sure you want to delete \(name)?", bundle: .core),
                                 message: message,
                                 primaryButton: .destructive(Text("Delete", bundle: .core), action: delete),
                                 secondaryButton: .cancel())
                case .itemDoesNotExist:
                    return Alert(title: Text("File No Longer Exists", bundle: .core),
                                 message: Text("The file has been deleted by the author.", bundle: .core),
                                 dismissButton: .cancel(Text("Close", bundle: .core)) {
                                                    dismiss()
                                                })
                }
            }

            .onAppear(perform: load)
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Name", bundle: .core)) {
                CustomTextField(placeholder: Text("Name", bundle: .core),
                                text: $name,
                                identifier: "FileEditor.nameField",
                                accessibilityLabel: Text("Name", bundle: .core))
            }

            EditorSection(label: Text("Access", bundle: .core)) {
                ButtonRow(action: {
                    env.router.show(ItemPickerViewController.create(
                        title: String(localized: "Access", bundle: .core),
                        sections: [ ItemPickerSection(items: Access.allCases.map {
                            ItemPickerItem(title: $0.label)
                        }) ],
                        selected: Access.allCases.firstIndex(of: access).flatMap {
                            IndexPath(row: $0, section: 0)
                        },
                        didSelect: { access = Access.allCases[$0.row] }
                    ), from: controller)
                }, content: {
                    Text(access.label)
                    Spacer()
                    DisclosureIndicator()
                })
                .identifier("FileEditor.accessButton")
                .accessibility(label: Text("Access", bundle: .core))
                .accessibility(value: Text(access.label))

                if access == .scheduled {
                    Divider()
                    ButtonRow(action: { CoreDatePicker.showDatePicker(for: $unlockAt, maxDate: lockAt, from: controller) }, content: {
                        Text("Available from", bundle: .core)
                        Spacer()
                        if let unlockAt = unlockAt {
                            Text(DateFormatter.localizedString(from: unlockAt, dateStyle: .medium, timeStyle: .short))
                        }
                    })
                    .identifier("FileEditor.unlockAtButton")

                    Divider()
                    ButtonRow(action: { CoreDatePicker.showDatePicker(for: $lockAt, minDate: unlockAt, from: controller) }, content: {
                        Text("Available until", bundle: .core)
                        Spacer()
                        if let lockAt = lockAt {
                            Text(DateFormatter.localizedString(from: lockAt, dateStyle: .medium, timeStyle: .short))
                        }
                    })
                    .identifier("FileEditor.lockAtButton")
                }
            }

            if usageRightsRequired {
                EditorSection(label: Text("Usage Rights", bundle: .core)) {
                    TextFieldRow(
                        label: Text("Copyright Holder", bundle: .core),
                        placeholder: String(localized: "Name", bundle: .core),
                        text: $copyright
                    )
                        .identifier("FileEditor.copyrightField")
                    Divider()
                    ButtonRow(action: {
                        env.router.show(ItemPickerViewController.create(
                            title: String(localized: "Usage Right", bundle: .core),
                            sections: [ ItemPickerSection(items: UseJustification.allCases.map {
                                ItemPickerItem(title: $0.label)
                            }) ],
                            selected: UseJustification.allCases.firstIndex(of: justification).flatMap {
                                IndexPath(row: $0, section: 0)
                            },
                            didSelect: { justification = UseJustification.allCases[$0.row] }
                        ), from: controller)
                    }, content: {
                        Text(justification.label)
                        Spacer()
                        DisclosureIndicator()
                    })
                        .identifier("FileEditor.justificationButton")
                    if justification == .creative_commons {
                        Divider()
                        ButtonRow(action: {
                            env.router.show(ItemPickerViewController.create(
                                title: String(localized: "Creative Commons License", bundle: .core),
                                sections: [ ItemPickerSection(items: License.allCases.map {
                                    ItemPickerItem(title: $0.label)
                                }) ],
                                selected: License.allCases.firstIndex(of: license).flatMap {
                                    IndexPath(row: $0, section: 0)
                                },
                                didSelect: { license = License.allCases[$0.row] }
                            ), from: controller)
                        }, content: {
                            Text(license.label)
                            Spacer()
                            DisclosureIndicator()
                        })
                            .identifier("FileEditor.licenseButton")
                    }
                }
            }

            EditorSection {
                ButtonRow(action: { alertItem = .deleteConfirmation }, content: {
                    Image(uiImage: .trashLine)
                        .foregroundColor(.textDanger)
                    Spacer().frame(width: 16)
                    (isFile ? Text("Delete File", bundle: .core) : Text("Delete Folder", bundle: .core))
                        .foregroundColor(.textDanger)
                    Spacer()
                })
                    .identifier("FileEditor.deleteButton")
            }
        }
    }

    func load() {
        guard !isLoaded else { return }
        loadCourseSettings()
        switch itemID {
        case .file(let fileID):
            let useCase = GetFile(context: context, fileID: fileID)
            useCase.fetch { _, response, error in performUIUpdate {
                if let error {
                    if (response as? HTTPURLResponse)?.statusCode == 404 {
                        alertItem = .itemDoesNotExist
                    } else {
                        alertItem = .error(error)
                    }
                }
                let file: File? = self.env.database.viewContext.fetch(scope: useCase.scope).first
                self.name = file?.displayName ?? file?.filename ?? ""
                self.copyright = file?.usageRights?.legalCopyright ?? ""
                self.justification = file?.usageRights?.useJustification ?? .own_copyright
                self.license = file?.usageRights?.license.flatMap { License(rawValue: $0) } ?? .cc_by
                self.loaded(locked: file?.locked, hidden: file?.hidden, unlockAt: file?.unlockAt, lockAt: file?.lockAt)
            } }
        case .folder(let folderID):
            let useCase = GetFolder(context: context, folderID: folderID)
            useCase.fetch { _, response, error in performUIUpdate {
                if let error {
                    if (response as? HTTPURLResponse)?.statusCode == 404 {
                        alertItem = .itemDoesNotExist
                    } else {
                        alertItem = .error(error)
                    }
                }
                let folder: Folder? = self.env.database.viewContext.fetch(scope: useCase.scope).first
                self.name = folder?.name ?? ""
                self.loaded(locked: folder?.locked, hidden: folder?.hidden, unlockAt: folder?.unlockAt, lockAt: folder?.lockAt)
            } }
        }
    }

    func loaded(locked: Bool?, hidden: Bool?, unlockAt: Date?, lockAt: Date?) {
        if locked == true {
            access = .unpublished
        } else if hidden == true {
            access = .hidden
        } else if unlockAt != nil || lockAt != nil {
            access = .scheduled
            self.unlockAt = unlockAt
            self.lockAt = lockAt
        } else {
            access = .published
        }
        isLoading = false
        isLoaded = true
    }

    func save() {
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let locked = access == .unpublished
        let hidden = access == .hidden
        let unlockAt = access == .scheduled ? self.unlockAt : nil
        let lockAt = access == .scheduled ? self.lockAt : nil
        switch itemID {
        case .file(let fileID):
            saveUsageRights {
                UpdateFile(request: PutFileRequest(fileID: fileID, name: name, locked: locked, hidden: hidden, unlockAt: unlockAt, lockAt: lockAt))
                    .fetch { result, _, error in performUIUpdate { self.saved(result != nil, error: error) } }
            }
        case .folder(let folderID):
            UpdateFolder(folderID: folderID, name: name, locked: locked, hidden: hidden, unlockAt: unlockAt, lockAt: lockAt)
                .fetch { result, _, error in performUIUpdate { self.saved(result != nil, error: error) } }
        }
    }

    func saveUsageRights(_ then: @escaping () -> Void) {
        guard usageRightsRequired, let context = context, case .file(let fileID) = itemID else {
            return then()
        }
        UpdateUsageRights(context: context, fileIDs: [ fileID ], usageRights: APIUsageRights(
            legal_copyright: copyright.trimmingCharacters(in: .whitespacesAndNewlines),
            license: justification == .creative_commons ? license.rawValue : nil,
            use_justification: justification
        )).fetch { result, _, error in performUIUpdate {
            if let error {
                alertItem = .error(error)
            }

            if result != nil {
                then()
            } else {
                self.isSaving = false
            }
        } }
    }

    func delete() {
        isSaving = true
        switch itemID {
        case .file(let fileID):
            DeleteFile(fileID: fileID)
                .fetch { result, _, error in performUIUpdate { self.saved(result != nil, error: error) } }
        case .folder(let folderID):
            DeleteFolder(folderID: folderID, force: true)
                .fetch { result, _, error in performUIUpdate { self.saved(result != nil, error: error) } }
        }
    }

    func saved(_ success: Bool, error: Error?) {
        if let error {
            alertItem = .error(error)
        }

        self.isSaving = false
        if success {
            dismiss()
        }
    }

    func loadCourseSettings() {
        guard isFile, let context = context, context.contextType == .course else { return }
        let useCase = GetCourseSettings(courseID: context.id)
        useCase.fetch { _, _, _ in performUIUpdate {
            let settings: CourseSettings? = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.usageRightsRequired = settings?.usageRightsRequired == true
        } }
    }

    func dismiss() {
        env.router.dismiss(controller)
    }

    enum Access: CaseIterable {
        case published, unpublished, hidden, scheduled

        var label: String {
            switch self {
            case .published:
                return String(localized: "Publish", bundle: .core)
            case .unpublished:
                return String(localized: "Unpublish", bundle: .core)
            case .hidden:
                return String(localized: "Only available to students with link", bundle: .core)
            case .scheduled:
                return String(localized: "Schedule student availability", bundle: .core)
            }
        }
    }

    // There is an API to fetch these, but it's static, not context dependendent, so this avoids an api call
    enum License: String, CaseIterable {
        case cc_by, cc_by_sa, cc_by_nc, cc_by_nc_sa, cc_by_nd, cc_by_nc_nd

        var label: String {
            switch self {
            case .cc_by:
                return String(localized: "Attribution", bundle: .core)
            case .cc_by_sa:
                return String(localized: "Attribution Share Alike", bundle: .core)
            case .cc_by_nc:
                return String(localized: "Attribution Non-Commercial", bundle: .core)
            case .cc_by_nc_sa:
                return String(localized: "Attribution Non-Commercial Share Alike", bundle: .core)
            case .cc_by_nd:
                return String(localized: "Attribution No Derivatives", bundle: .core)
            case .cc_by_nc_nd:
                return String(localized: "Attribution Non-Commercial No Derivatives", bundle: .core)
            }
        }
    }
}

#if DEBUG
struct FileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUI.Group {
            FileEditorView(context: .course("1"), fileID: "1")
            FileEditorView(folderID: "2")
        }
    }
}
#endif
