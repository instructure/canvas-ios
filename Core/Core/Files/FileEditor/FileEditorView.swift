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

    @State var title: String = ""

    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
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
        ZStack {
            form.disabled(isLoading || isSaving)
            if isLoading || isSaving {
                CircleProgress().size()
            }
        }
            .alert(isPresented: $showError) {
                Alert(title: Text(verbatim: ""), message: Text(error!.localizedDescription))
            }
            .avoidKeyboardArea()
            .background(Color.backgroundGrouped)
            .navigationBarTitle(isFile ? Text("Edit File", bundle: .core) : Text("Edit Folder", bundle: .core), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    guard let controller = self.viewController() else { return }
                    self.env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core)
                })
                    .identifier("screen.dismiss"),
                trailing: Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                    .disabled(isLoading || isSaving)
                    .identifier("FileEditor.doneButton")
            )
            .navBarStyle(.modal)
            .onAppear(perform: load)
    }

    var form: some View {
        ScrollView { VStack(alignment: .leading, spacing: 0) {
            Text("Title", bundle: .core)
                .font(.semibold14).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            Divider()
            TextField(NSLocalizedString("Add Title", bundle: .core, comment: ""), text: $title)
                .font(.regular16).foregroundColor(.textDarkest)
                .padding(16)
                .background(Color.backgroundLightest)
                .identifier("FileEditor.titleField")
            Divider()
        } }
    }

    func load() {
        guard !isLoaded else { return }
    }

    func save() {
        isSaving = true
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
