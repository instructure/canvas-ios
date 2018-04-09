//
//  File.swift
//  CanvasCore
//
//  Created by Layne Moseley on 4/9/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
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
            let svgImage = SVGKImage(contentsOfFile: tempPath)
            callback(svgImage?.uiImage)
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
