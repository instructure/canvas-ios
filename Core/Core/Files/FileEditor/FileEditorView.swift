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

@available(iOSApplicationExtension 13.0.0, *)
public struct FileEditorView: View {
    let context: Context?
    let itemID: ItemID
    enum ItemID {
        case file(String)
        case folder(String)
    }

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var viewController

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
    @State var showDeleteConfirm: Bool = false
    @State var showError: Bool = false
    @State var error: Error? {
        didSet { showError = error != nil }
    }

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
            .navigationBarTitle(isFile ? Text("Edit File", bundle: .core) : Text("Edit Folder", bundle: .core), displayMode: .inline)
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

            .alert(isPresented: Binding(get: { self.showError || self.showDeleteConfirm }, set: {
                self.showError = false
                self.showDeleteConfirm = $0
            })) {
                showError ? Alert(title: Text(error!.localizedDescription)) :
                Alert(
                    title: Text("Are you sure you want to delete \(name)?", bundle: .core),
                    message: isFile ? nil : Text("Deleting this folder will also delete all of the files inside the folder.", bundle: .core),
                    primaryButton: .destructive(Text("Delete", bundle: .core), action: delete),
                    secondaryButton: .cancel()
                )
            }

            .onAppear(perform: load)
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Name", bundle: .core)) {
                TextField(NSLocalizedString("Name", bundle: .core, comment: ""), text: $name)
                    .font(.regular16).foregroundColor(.textDarkest)
                    .padding(16)
                    .identifier("FileEditor.nameField")
            }

            EditorSection(label: Text("Access", bundle: .core)) {
                Button(action: {
                    guard let controller = self.viewController() else { return }
                    self.env.router.show(ItemPickerViewController.create(
                        title: NSLocalizedString("Access", bundle: .core, comment: ""),
                        sections: [ ItemPickerSection(items: Access.allCases.map {
                            ItemPickerItem(title: $0.label)
                        }), ],
                        selected: Access.allCases.firstIndex(of: self.access).flatMap {
                            IndexPath(row: $0, section: 0)
                        },
                        didSelect: { self.access = Access.allCases[$0.row] }
                    ), from: controller)
                }, label: {
                    Text(access.label).font(.semibold16)
                    Spacer()
                    DisclosureIndicator()
                })
                    .padding(16)
                    .accentColor(.textDarkest)
                    .identifier("FileEditor.accessButton")

                if access == .scheduled {
                    Divider()
                    OptionalDatePicker(selection: $unlockAt, max: lockAt, initial: Clock.now.startOfDay()) {
                        Text("Available from")
                    }
                        .identifier("FileEditor.unlockAtButton")
                    Divider()
                    OptionalDatePicker(selection: $lockAt, min: unlockAt, initial: Clock.now.endOfDay()) {
                        Text("Available to")
                    }
                        .identifier("FileEditor.lockAtButton")
                }
            }

            if usageRightsRequired {
                EditorSection(label: Text("Usage Rights", bundle: .core)) {
                    TextFieldRow(
                        label: Text("Copyright Holder", bundle: .core),
                        placeholder: NSLocalizedString("Name", bundle: .core, comment: ""),
                        text: $copyright
                    )
                        .identifier("FileEditor.copyrightField")
                    Divider()
                    Button(action: {
                        guard let controller = self.viewController() else { return }
                        self.env.router.show(ItemPickerViewController.create(
                            title: NSLocalizedString("Usage Right", bundle: .core, comment: ""),
                            sections: [ ItemPickerSection(items: UseJustification.allCases.map {
                                ItemPickerItem(title: $0.label)
                            }), ],
                            selected: UseJustification.allCases.firstIndex(of: self.justification).flatMap {
                                IndexPath(row: $0, section: 0)
                            },
                            didSelect: { self.justification = UseJustification.allCases[$0.row] }
                        ), from: controller)
                    }, label: {
                        Text(justification.label).font(.semibold16)
                        Spacer()
                        DisclosureIndicator()
                    })
                        .padding(16)
                        .accentColor(.textDarkest)
                        .identifier("FileEditor.justificationButton")
                    if justification == .creative_commons {
                        Divider()
                        Button(action: {
                            guard let controller = self.viewController() else { return }
                            self.env.router.show(ItemPickerViewController.create(
                                title: NSLocalizedString("Creative Commons License", bundle: .core, comment: ""),
                                sections: [ ItemPickerSection(items: License.allCases.map {
                                    ItemPickerItem(title: $0.label)
                                }), ],
                                selected: License.allCases.firstIndex(of: self.license).flatMap {
                                    IndexPath(row: $0, section: 0)
                                },
                                didSelect: { self.license = License.allCases[$0.row] }
                            ), from: controller)
                        }, label: {
                            Text(license.label).font(.semibold16)
                            Spacer()
                            DisclosureIndicator()
                        })
                            .padding(16)
                            .accentColor(.textDarkest)
                            .identifier("FileEditor.licenseButton")
                    }
                }
            }

            EditorSection {
                Button(action: { self.showDeleteConfirm = true }, label: {
                    Image(uiImage: .trashLine)
                    Spacer().frame(width: 16)
                    isFile ? Text("Delete File", bundle: .core) : Text("Delete Folder", bundle: .core)
                    Spacer()
                })
                    .padding(16)
                    .font(.semibold16).accentColor(.textDanger)
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
            useCase.fetch { _, _, error in performUIUpdate {
                self.error = error
                let file: File? = self.env.database.viewContext.fetch(scope: useCase.scope).first
                self.name = file?.displayName ?? file?.filename ?? ""
                self.copyright = file?.usageRights?.legalCopyright ?? ""
                self.justification = file?.usageRights?.useJustification ?? .own_copyright
                self.license = file?.usageRights?.license.flatMap { License(rawValue: $0) } ?? .cc_by
                self.loaded(locked: file?.locked, hidden: file?.hidden, unlockAt: file?.unlockAt, lockAt: file?.lockAt)
            } }
        case .folder(let folderID):
            let useCase = GetFolder(context: context, folderID: folderID)
            useCase.fetch { _, _, error in performUIUpdate {
                self.error = error
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
        isSaving = true
        let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let locked = access == .unpublished
        let hidden = access == .hidden
        let unlockAt = access == .scheduled ? self.unlockAt : nil
        let lockAt = access == .scheduled ? self.lockAt : nil
        switch itemID {
        case .file(let fileID):
            saveUsageRights {
                UpdateFile(fileID: fileID, name: name, locked: locked, hidden: hidden, unlockAt: unlockAt, lockAt: lockAt)
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
            self.error = error
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
        self.error = error
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
        guard let controller = viewController() else { return }
        env.router.dismiss(controller)
    }

    enum Access: CaseIterable {
        case published, unpublished, hidden, scheduled

        var label: String {
            switch self {
            case .published:
                return NSLocalizedString("Publish", bundle: .core, comment: "")
            case .unpublished:
                return NSLocalizedString("Unpublish", bundle: .core, comment: "")
            case .hidden:
                return NSLocalizedString("Only available to students with link", bundle: .core, comment: "")
            case .scheduled:
                return NSLocalizedString("Schedule student availability", bundle: .core, comment: "")
            }
        }
    }

    // There is an API to fetch these, but it's static, not context dependendent, so this avoids an api call
    enum License: String, CaseIterable {
        case cc_by, cc_by_sa, cc_by_nc, cc_by_nc_sa, cc_by_nd, cc_by_nc_nd

        var label: String {
            switch self {
            case .cc_by:
                return NSLocalizedString("Attribution", bundle: .core, comment: "")
            case .cc_by_sa:
                return NSLocalizedString("Attribution Share Alike", bundle: .core, comment: "")
            case .cc_by_nc:
                return NSLocalizedString("Attribution Non-Commercial", bundle: .core, comment: "")
            case .cc_by_nc_sa:
                return NSLocalizedString("Attribution Non-Commercial Share Alike", bundle: .core, comment: "")
            case .cc_by_nd:
                return NSLocalizedString("Attribution No Derivatives", bundle: .core, comment: "")
            case .cc_by_nc_nd:
                return NSLocalizedString("Attribution Non-Commercial No Derivatives", bundle: .core, comment: "")
            }
        }
    }
}

#if DEBUG
@available(iOSApplicationExtension 13.0.0, *)
struct FileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUI.Group {
            FileEditorView(context: .course("1"), fileID: "1")
            FileEditorView(folderID: "2")
        }
    }
}
#endif
