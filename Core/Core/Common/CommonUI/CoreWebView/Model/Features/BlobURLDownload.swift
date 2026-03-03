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

import Foundation

/// Intercepts clicks on `<a href="blob:...">` anchors in **all frames** (including cross-origin
/// iframes) by injecting a capture-phase click listener. Running the script in each frame's own
/// JS context avoids the same-origin restriction that would block a `fetch()` issued from the
/// main frame against a blob URL that was created inside a cross-origin iframe.
class BlobURLDownload: CoreWebViewFeature {

    static let messageHandlerName = "blobDownload"

    private let script = """
        document.addEventListener('click', function(event) {
            var el = event.target.closest('a[href^="blob:"]');
            if (!el) { return; }
            event.preventDefault();
            var fileName = el.download || '';
            fetch(el.href)
                .then(function(r) { return r.blob(); })
                .then(function(blob) {
                    var reader = new FileReader();
                    reader.onload = function() {
                        var base64 = reader.result.split(',')[1];
                        window.webkit.messageHandlers.\(messageHandlerName).postMessage({
                            data: base64,
                            mimeType: blob.type || 'application/octet-stream',
                            fileName: fileName
                        });
                    }
                    reader.onerror = function(err) {
                        console.error('BlobURLDownload FileReader error:', err);
                    }
                    reader.readAsDataURL(blob);
                })
                .catch(function(err) {
                    console.error('BlobURLDownload fetch error:', err);
                });
        }, true);
        """

    override func apply(on webView: CoreWebView) {
        webView.addScript(script, forMainFrameOnly: false)
        webView.handle(Self.messageHandlerName) { [weak webView] message in
            guard let webView,
                  let body = message.body as? [String: String],
                  let base64 = body["data"],
                  let mimeType = body["mimeType"],
                  let fileName = body["fileName"]
            else { return }
            webView.handleBlobDownload(base64: base64, mimeType: mimeType, fileName: fileName)
        }
    }
}

public extension CoreWebViewFeature {

    static var blobURLDownload: CoreWebViewFeature {
        BlobURLDownload()
    }
}
