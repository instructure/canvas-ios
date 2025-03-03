//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import CombineExt
import Core
import WebKit

/// The error type for the HighlightJSInterface
enum HighlightJSInterfaceError: Error {
    case functionCallFailed(String)
}

/// This Web Feature registers JavaScript with the WKWebView and proxys requests to and from that JavaScript
/// It allows for the application of highlights to the web view
class HighlightWebFeature: CoreWebViewFeature {

    // MARK: - Private

    private let documentLoadedRelay = CurrentValueRelay<Void>(())
    private let highlightTapRelay = CurrentValueRelay<NotebookTextSelection?>(nil)

    // MARK: - Public

    /// Applies the highlights to the web view
    func apply(webView: WKWebView, notebookTextSelections: [NotebookTextSelection]) async {
        await withCheckedContinuation { continuation in
            if let jsonData = try? JSONEncoder().encode(notebookTextSelections),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let evalString = "applyHighlights(\(jsonString))"
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(evalString) { _, _ in
                        continuation.resume()
                    }
                }
            }
        }
    }

    /// Gets the NotebookTextSelection of the current selection in the web view
    func getCurrentSelection(webView: WKWebView) async -> NotebookTextSelection? {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                webView.evaluateJavaScript("getSelectionCoordinates()") { result, _ in
                    var notebookTextSelection: NotebookTextSelection?
                    if let result = result,
                          let data = try? JSONSerialization.data(withJSONObject: result) {
                        notebookTextSelection = try? JSONDecoder().decode(NotebookTextSelection.self, from: data)
                    }
                    continuation.resume(returning: notebookTextSelection)
                }
            }
        }
    }

    /// Listens for when the user taps on a highlight
    func listenForHighlightTaps() -> AnyPublisher<NotebookTextSelection, Never> {
        highlightTapRelay.compactMap { $0 }.eraseToAnyPublisher()
    }

    // MARK: - Override

    /// Applies the feature to the given web view configuration
    override func apply(on configuration: WKWebViewConfiguration) {
        super.apply(on: configuration)
        let userContentController = WKUserContentController()

        if let userScript = loadJavaScript() {
            userContentController.addUserScript(userScript)
        }

        NotebookHighlightTapMessageHandler.register(with: userContentController, callback: highlightTapCallback)

        configuration.userContentController = userContentController
    }

    // MARK: - Private

    private func documentLoadedCallback() {
        documentLoadedRelay.accept(())
    }

    private func loadJavaScript() -> WKUserScript? {
        guard let jsFilePath = Bundle(identifier: "com.instructure.horizon")?.path(forResource: "WebHighlighting", ofType: "js"),
           let jsString = try? String(contentsOfFile: jsFilePath, encoding: .utf8) else {
return nil
        }
        return WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    private func highlightTapCallback(notebookTextSelection: NotebookTextSelection) {
        highlightTapRelay.accept(notebookTextSelection)
    }
}

// MARK: - Message Handler Classes

// The Message channel called when a highlight is tapped
private class NotebookHighlightTapMessageHandler: NSObject, WKScriptMessageHandler {
    typealias HighlightTapCallback = ((NotebookTextSelection) -> Void)

    private let highlightTapCallback: HighlightTapCallback

    private static let messageChannelName = "notebookHighlightTap"

    static func register(with userContentController: WKUserContentController, callback: @escaping HighlightTapCallback) {
        userContentController.add(
            NotebookHighlightTapMessageHandler(highlightTapCallback: callback),
            name: NotebookHighlightTapMessageHandler.messageChannelName
        )
    }

    private init(highlightTapCallback: @escaping HighlightTapCallback) {
        self.highlightTapCallback = highlightTapCallback
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == NotebookHighlightTapMessageHandler.messageChannelName {
            if let jsonString = message.body as? String,
               let jsonData = jsonString.data(using: .utf8),
               let notebookTextSelection = try? JSONDecoder().decode(NotebookTextSelection.self, from: jsonData) {
                self.highlightTapCallback(notebookTextSelection)
            }
        }
    }
}

// MARK: - Models
/// This is only used to communicate with the JavaScript
struct NotebookTextSelection: Codable, Equatable {
    let backgroundColor: String?
    let borderColor: String?
    let range: RangeSelector
    let selectedText: String
    let textPosition: TextPositionSelector

    struct RangeSelector: Codable, Equatable {
        let startContainer: String
        let endContainer: String
        let startOffset: Int
        let endOffset: Int
    }

    struct TextPositionSelector: Codable, Equatable {
        let start: Int
        let end: Int
    }
}
