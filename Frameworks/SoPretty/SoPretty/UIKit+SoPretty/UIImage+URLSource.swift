//
//  UIImage+URLSource.swift
//  SoPretty
//
//  Created by Brandon Pluim on 1/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension UIImageView {
    public func downloadedFrom(url: NSURL, contentMode mode: UIViewContentMode) {
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}