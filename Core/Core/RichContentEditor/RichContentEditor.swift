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

struct RichContentEditor: UIViewControllerRepresentable {
    let placeholder: String
    @Binding var html: String
    let context: Context
    let uploadTo: FileUploadContext
    @Binding var height: CGFloat
    @Binding var canSubmit: Bool
    @Binding var error: Error?

    class Coordinator: RichContentEditorDelegate, CoreWebViewSizeDelegate {
        let view: RichContentEditor
        var lastHTML: String = ""

        init(_ view: RichContentEditor) {
            self.view = view
        }

        func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
            view.canSubmit = canSubmit
            editor.getHTML {
                self.lastHTML = $0
                self.view.html = $0
            }
        }

        func rce(_ editor: RichContentEditorViewController, didError error: Error) {
            view.error = error
        }

        func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat) {
            view.height = height
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Self.Context) -> RichContentEditorViewController {
        let uiViewController = RichContentEditorViewController.create(context: self.context, uploadTo: uploadTo)
        uiViewController.webView.autoresizesHeight = true
        // Prevent bad adjustedContentInset from adding unnecessary scrollbars
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillHideNotification, object: nil)
        return uiViewController
    }

    func updateUIViewController(_ uiViewController: RichContentEditorViewController, context: Self.Context) {
        uiViewController.delegate = context.coordinator
        uiViewController.webView.sizeDelegate = context.coordinator
        uiViewController.placeholder = placeholder
        if context.coordinator.lastHTML != html {
            uiViewController.setHTML(html)
        }
    }
}

#if DEBUG
struct RichContentEditorView_Previews: PreviewProvider {
    struct Preview: View {
        @State var html: String = "Edit Me!"
        @State var height: CGFloat = 200
        @State var canSubmit: Bool = false
        @State var error: Error?
        var body: some View {
            RichContentEditor(
                placeholder: "Placeholder",
                html: $html,
                context: .course("1"),
                uploadTo: .myFiles,
                height: $height,
                canSubmit: $canSubmit,
                error: $error
            ).frame(minHeight: 60, idealHeight: max(60, height))
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
