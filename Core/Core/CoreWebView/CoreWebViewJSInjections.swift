//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

/**
 This extension contains all JavaScripts that are always injected into CoreWebView contents when the `setup()` method is called.
 */
extension CoreWebView {

    public static func jsString(_ string: String?) -> String {
        guard let string = string else { return "null" }
        let escaped = string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
            .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
        return "'\(escaped)'"
    }

    var js: String {
        let defaultScripts = [
            Self.mathJaxJS,
            Self.LTIToolButtonJS,
            Self.fileContentJS,
            Self.contentSizeJS,
        ]
        let scriptsToInject = defaultScripts.filter {
            features.shouldInjectJS($0)
        }
        return scriptsToInject.joined(separator: "\n")
    }

    /**
     Searches for math equations and if any is found then MathJax is injected to properly format it.
     */
    public static var mathJaxJS: String {
        """
        // Handle Math Equations
        function loadMathJaxIfNecessary() {
          let foundMath = !!document.querySelector('math') || document.body.innerText.includes('\\\\') || document.body.innerText.includes('$$')
          document.querySelectorAll('img.equation_image').forEach(img => {
            let mathml = img.getAttribute('x-canvaslms-safe-mathml')
            if (!mathml && !img.dataset.equationContent) return
            foundMath = true
            const div = document.createElement('div')
            div.innerHTML = mathml || '<span>$$' + img.dataset.equationContent + '$$</span>'
            div.firstChild.setAttribute('style', img.getAttribute('style'))
            img.parentNode.replaceChild(div.firstChild, img)
          })

          if (foundMath) {
            window.MathJax = { displayAlign: 'inherit', messageStyle: 'none' }
            const script = document.createElement('script')
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-AMS-MML_HTMLorMML'
            document.body.appendChild(script)
          }
        }

        loadMathJaxIfNecessary()
        """
    }

    /**
     Replaces all LTI tool iframes with a button that opens the tool in a popup.
     */
    public static var LTIToolButtonJS: String {
        let buttonText = NSLocalizedString("Launch External Tool", bundle: .core, comment: "")
        return """
        function fixLTITools() {
            // Replace all iframes with a button to launch in SFSafariViewController
            document.querySelectorAll('iframe').forEach(iframe => {
                const replace = iframe => {
                    const a = document.createElement('a')
                    a.textContent = \(CoreWebView.jsString(buttonText))
                    a.classList.add('canvas-ios-lti-launch-button')
                    a.href = iframe.src
                    iframe.parentNode.replaceChild(a, iframe)
                }
                if (/\\/(courses|accounts)\\/[^\\/]+\\/external_tools\\/retrieve/.test(iframe.src)) {
                    replace(iframe)
                } else if (/\\/media_objects_iframe\\/m-\\w+/.test(iframe.src)) {
                    const match = iframe.src.match(/\\/media_objects_iframe\\/(m-\\w+)/)
                    if (match.length == 2) {
                        const mediaID = match[1]
                        const video = document.createElement('video')
                        video.src = '/users/self/media_download?entryId='+mediaID+'&media_type=video&redirect=1'
                        video.setAttribute('poster', '/media_objects/'+mediaID+'/thumbnail?width=550&height=448')
                        video.setAttribute('controls', '')
                        video.setAttribute('preload', 'none')
                        iframe.replaceWith(video)
                    }
                } else {
                    iframe.addEventListener('error', event => replace(event.target))
                }
            })
        }

        fixLTITools()
        """
    }

    /**
     Sends a message to the native code to reload the webview with the authenticated version of the iframe's src.
     */
    public static var fileContentJS: String {
        """
        // If there is only one iframe
        // and id="cnvs_content"
        // and the src is a canvas file
        // reload the webview with an authenticated version of the iframe's src
        // https://community.canvaslms.com/thread/31562-canvas-ios-app-not-loading-iframe-content
        const iframes = document.querySelectorAll('iframe');
        if (iframes.length == 1 && /\\/courses\\/\\d+\\/files\\/\\d+\\/download/.test(iframes[0].src) && iframes[0].id === "cnvs_content") {
            window.webkit.messageHandlers.loadFrameSource.postMessage(iframes[0].src)
        }
        """
    }

    /**
     Notifies native code about the size of the rendered html page.
     */
    public static var contentSizeJS: String {
        """
        // Send content height whenever it changes
        let lastHeight = 0
        let lastWidth = window.innerWidth
        const checkSize = () => {
            const height = window.editor && window.editor.contentHeight || document.documentElement.scrollHeight
            if (lastHeight !== height) {
                lastHeight = height
                window.webkit.messageHandlers.resize.postMessage({ height })
            }
        }
        const observer = new MutationObserver(checkSize)
        observer.observe(document.documentElement, { attributes: true, childList: true, subtree: true })
        window.addEventListener('resize', () => {
            let width = window.innerWidth
            if (lastWidth !== width) {
                lastWidth = width
                checkSize()
            }
        })
        window.addEventListener('load', () => {
            checkSize()
            document.addEventListener('load', checkSize, true)
        })
        window.addEventListener('error', checkSize, true)
        if (window.ResizeObserver) {
            new ResizeObserver(checkSize).observe(document.documentElement)
        }
        checkSize()
        """
    }
}
