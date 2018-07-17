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

import Foundation
import SVGKit

extension SVGKImage {
    static func imageWithContentsOfURL(url: URL, callback: @escaping (UIImage?) -> ()) -> URLSessionDataTask {
        let fileName = url.lastPathComponent
        let tempPath = NSTemporaryDirectory().appending("svg-cache-").appending(fileName)
        let tempURL = URL(fileURLWithPath: tempPath)
        let fileManager = FileManager.default
        let fetchImage = {
            if let source = SVGKSourceLocalFile.source(fromFilename: tempPath), let parser = SVGKParser(source: source) {
                // Adds only the supported parsers
                // The default implementation adds unsupported parsers like SVGKParserPatternsAndGradients
                parser.add(SVGKParserSVG())
                parser.add(SVGKParserGradient())
                parser.add(SVGKParserStyles())
                parser.add(SVGKParserDefsAndUse())
                parser.add(SVGKParserDOM())
                if let parsedResult = parser.parseSynchronously() {
                    let svgImage = SVGKImage(parsedSVG: parsedResult, from: source)
                    callback(svgImage?.uiImage)
                } else {
                    callback(nil)
                }
            } else {
                callback(nil)
            }
        }
        
        // If the file is already cached, use it immediatly
        if fileManager.fileExists(atPath: tempPath) {
            fetchImage()
        }

        // Fetch the file from the remote source and cache it
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error { return callback(nil) }
            guard let d = data else { return callback(nil) }
            do {
                try d.write(to: tempURL, options: .atomic)
                DispatchQueue.main.async(execute: fetchImage)
            } catch {
                callback(nil)
            }
        }
        task.resume()
        return task
    }
}

class SVGImageView: UIImageView {
    let url: URL
    var task: URLSessionDataTask?
    init(url: URL) {
        self.url = url
        super.init(image: nil)
        self.task = SVGKImage.imageWithContentsOfURL(url: url) { [weak self] (image) in
            self?.image = image
        }
    }
    
    deinit {
        self.task?.cancel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
