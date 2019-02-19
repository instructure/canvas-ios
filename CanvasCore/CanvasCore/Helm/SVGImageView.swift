//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import WebKit

// private image cache
fileprivate var rendered: [String:UIImage] = [:]
fileprivate var loading: [String:[SVGImageView]] = [:]

class SVGImageView: UIView {
    @objc let key: String
    @objc var observation: NSKeyValueObservation?
    @objc var webView: WKWebView?

    required init?(coder aDecoder: NSCoder) {
        key = ""
        super.init(coder: aDecoder)
    }

    @objc init(frame: CGRect, url: URL) {
        key = "\(url.absoluteString)@\(frame.width)x\(frame.height)"
        super.init(frame: frame)
        load(url: url)
    }

    @objc func load(url: URL) {
        if #available(iOS 11.0, *) {
            if let image = rendered[key] {
                addImage(image)
                return
            } else if loading[key] != nil {
                loading[key]?.append(self)
                return
            }
            loading[key] = []
            loading[key]?.append(self)
        }

        let view = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear

        let html = """
            <!doctype html>
            <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
            <style>html{height:100%}body{margin:0;height:100%;background:no-repeat center/contain url("\(url.absoluteString)")}</style>
            <script>window.onload=()=>{setTimeout(()=>{document.title="SVG"},0)}</script>
        """
        if #available(iOS 11.0, *) {
            webView = view // keep a reference
            observation = view.observe(\.title, options: .new) { webView, _ in
                guard webView.title == "SVG" else { return }
                webView.takeSnapshot(with: nil) { snapshot, error in
                    DispatchQueue.main.async { self.handleSnapshot(snapshot, error: error) }
                }
            }
        } else {
            view.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            view.isAccessibilityElement = false
            addSubview(view)
        }
        view.loadHTMLString(html, baseURL: url)
    }

    @objc func handleSnapshot(_ snapshot: UIImage?, error: Error?) {
        rendered[key] = snapshot
        if let image = snapshot, let queue = loading[key] {
            for view in queue {
                view.addImage(image)
            }
        }
        loading[key] = nil
        observation = nil
        webView = nil // deallocate webview
    }

    @objc func addImage(_ image: UIImage) {
        addSubview(UIImageView(image: image))
    }
}
