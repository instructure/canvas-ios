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
import Combine

struct RichContentEditor: UIViewControllerRepresentable {
    private let env: AppEnvironment
    private let placeholder: String
    private let a11yLabel: String
    @Binding private var html: String
    private let uploadParameters: RichContentEditorUploadParameters
    @Binding private var height: CGFloat
    @Binding private var canSubmit: Bool
    @Binding private var isUploading: Bool
    @Binding private var error: Error?
    private let onFocus: (() -> Void)?
    private let focusTrigger: AnyPublisher<Void, Never>?

    final class Coordinator: RichContentEditorDelegate, CoreWebViewSizeDelegate {
        private let view: RichContentEditor
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

        func rce(_ editor: RichContentEditorViewController, isUploading: Bool) {
            view.isUploading = isUploading
        }

        func rce(_ editor: RichContentEditorViewController, didError error: Error) {
            view.error = error
        }

        func rceDidFocus(_ editor: RichContentEditorViewController) {
            view.onFocus?()
        }

        func coreWebView(_ webView: CoreWebView, didChangeContentHeight height: CGFloat) {
            view.height = height
        }
    }

    init(
        env: AppEnvironment,
        placeholder: String,
        a11yLabel: String,
        html: Binding<String>,
        uploadParameters: RichContentEditorUploadParameters,
        height: Binding<CGFloat>,
        canSubmit: Binding<Bool> = .constant(true),
        isUploading: Binding<Bool> = .constant(false),
        error: Binding<Error?>,
        onFocus: (() -> Void)? = nil,
        focusTrigger: AnyPublisher<Void, Never>? = nil
    ) {
        self.env = env
        self.placeholder = placeholder
        self.a11yLabel = a11yLabel
        self._html = html
        self.uploadParameters = uploadParameters
        self._height = height
        self._canSubmit = canSubmit
        self._isUploading = isUploading
        self._error = error
        self.onFocus = onFocus
        self.focusTrigger = focusTrigger
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Self.Context) -> RichContentEditorViewController {
        let uiViewController = RichContentEditorViewController.create(
            env: env,
            context: uploadParameters.context,
            uploadTo: uploadParameters.uploadTo
        )
        uiViewController.fileUploadBaseURL = uploadParameters.baseUrl
        uiViewController.webView.autoresizesHeight = true
        uiViewController.delegate = context.coordinator
        uiViewController.webView.sizeDelegate = context.coordinator

        // Prevent bad adjustedContentInset from adding unnecessary scrollbars
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(uiViewController.webView, name: UIResponder.keyboardWillHideNotification, object: nil)

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: RichContentEditorViewController, context: Self.Context) {
        uiViewController.placeholder = placeholder
        uiViewController.a11yLabel = a11yLabel

        if context.coordinator.lastHTML != html {
            uiViewController.setHTML(html)
        }

        if let focusTrigger {
            uiViewController.subscribeToFocusTrigger(focusTrigger)
        }
    }
}

#if DEBUG
struct RichContentEditorView_Previews: PreviewProvider {
    struct Preview: View {
        @State var html: String = "Edit Me!"
        @State var height: CGFloat = 200
        @State var canSubmit: Bool = false
        @State var isUploading: Bool = false
        @State var error: Error?
        var body: some View {
            RichContentEditor(
                env: .shared,
                placeholder: "Placeholder",
                a11yLabel: "Editor",
                html: $html,
                uploadParameters: .init(context: .course("1")),
                height: $height,
                canSubmit: $canSubmit,
                isUploading: $isUploading,
                error: $error
            ).frame(minHeight: 60, idealHeight: max(60, height))
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
