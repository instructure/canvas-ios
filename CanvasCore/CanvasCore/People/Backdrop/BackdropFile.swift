//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

import Result

import ReactiveSwift

let numShapeBackdrops = 20
let numPhotoBackdrops = 15

enum ImageType: Int, CustomStringConvertible {
    case shapes
    case photos
    
    static func count() -> Int {
        // this needs to just be the number of cases
        // needs to be set manually, since swift doesn't yet support reflection of enums
        return 2
    }
    
    var description: String {
        switch self {
        case .shapes:
            return NSLocalizedString("Shapes", tableName: "Localizable", bundle: .core, value: "", comment: "Shapes backdrops")
        case .photos:
            return NSLocalizedString("Photos", tableName: "Localizable", bundle: .core, value: "", comment: "Photos backdrops")
        }
    }
}

private func intToTwoDigitString(_ n: Int) -> String {
    if n < 0 || n > 99 {
        fatalError("can only handle two digit ints")
    }
    if n < 10 {
        return "0"+"\(n)"
    }else{
        return "\(n)"
    }
}

private let shapeRoot = "backdrop_img-"
private let photoRoot = "jayna_rice_"
private let rootURL = URL(string: "https://canvas-static-assets.s3.amazonaws.com/mobile/backdrop")!
private let backdropURLKey = "data"

/**
There are two type of Backdrop Files: Material Design-y Shapes and some images
from Matt Rice's mom. Thus type is Shapes or Photos. And n is the index within a type.
The index is 1-based.

Additionally this little struct encapsulates a surprising amount of logic. We need to:

1. Know where to download the file from (an amazon bucket that we share with Android).

2. Where to save the file locally on disk.

3. Convert to and from the shared JSON format that we use to track settings for users using the
UserCustomDataStore.

4. Use the struct as keys in a dictionary (hashable!)
*/
struct BackdropFile: Hashable, Equatable {
    
    // ---------------------------------------------
    // MARK: - Immutable Properties
    // ---------------------------------------------
    let type: ImageType
    let n: Int
    
    init (type: ImageType, n: Int) {
        self.type = type
        self.n = n
    }
    
    // ---------------------------------------------
    // MARK: - Hashing
    // ---------------------------------------------
    var hashValue: Int {
        // It is important that we avoid collisions here, because we use this to track
        // the preferences that we store to NSUserDefaults
        switch self.type {
        case .shapes:
            return n
        case .photos:
            return numShapeBackdrops + n
        }
    }
    
    static func fromHash(_ hash: Int) -> BackdropFile? {
        if hash > 0 && hash <= numShapeBackdrops + numPhotoBackdrops {
            if hash <= numShapeBackdrops {
                return BackdropFile(type: .shapes, n: hash)
            } else {
                let n = hash - numShapeBackdrops
                return BackdropFile(type: .photos, n: n)
            }
        }
        return nil
    }
    
    // ---------------------------------------------
    // MARK: - Descriptive
    // ---------------------------------------------
    var description: String {
        return name 
    }
    
    //! something along the lines of jayna_rice_04.jpg
    var name: String {
        let n = self.n
        switch self.type {
        case .shapes:
            if n <= 0 || n > numShapeBackdrops {
                ❨╯°□°❩╯⌢"This isn't a valid backdrop"
            } else {
                return shapeRoot + intToTwoDigitString(n) + ".jpg"
            }
        case .photos:
            if n <= 0 || n > numPhotoBackdrops {
                ❨╯°□°❩╯⌢"This isn't a valid backdrop"
            } else {
                return photoRoot + intToTwoDigitString(n) + ".jpg"
            }
        }
    }
    
    //! Inverse of BackdropFile.name
    fileprivate static func fromName(_ name: String) -> BackdropFile? {
        let start: String.Index = name.index(name.endIndex, offsetBy: -6)
        let end: String.Index = name.index(name.endIndex, offsetBy: -4)
        if start >= name.startIndex && end >= start && name.endIndex >= end {
            if let n = Int(name.substring(with: start..<end)) {
                if let _ = name.range(of: shapeRoot) {
                    return BackdropFile(type: .shapes, n: n)
                } else if let _ = name.range(of: photoRoot) {
                    return BackdropFile(type: .photos, n: n)
                }
            }
        }
        return nil
    }
    
    // ---------------------------------------------
    // MARK: - Local disk
    // ---------------------------------------------
    /**
    A path in the Cache directory. We want to save the files to disk
    for quicker loads, but we don't want to take up space if the user
    is running short of space. And no reason to backup to iTunes.
    */
    var localPath: String {
        guard let directory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first else { ❨╯°□°❩╯⌢"We need a caches directory!" }
        return (directory as NSString).appendingPathComponent(name)
    }
    
    //! The image from the local file stored on disk
    var localFile: UIImage? {
        return UIImage(contentsOfFile: localPath)
    }
    
    //! Save Image to Disk
    func writeImage(_ image: UIImage?) throws {
        if let image = image {
            try UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: localPath), options: .atomic)
        }
    }
    
    /**
    We use URLSessionDownloadTasks to download the files to temporary locations. Use this method to save it
    to a semi-permanent location in the Cache directory.
    */
    func writeFileToPermanentLocationFromURL(_ fromURL: URL) -> Result<UIImage, NSError> {
        return Result(attempt: {
            let data = try Data(contentsOf: fromURL)
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ProfileKit.BackdropFile.writeFileFromTemporyURLToPermanentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "error parsing file to UIImage"])
            }
            try writeImage(image)
            return image
        })
    }
    
    // ---------------------------------------------
    // MARK: - Android Bucket URLS
    // ---------------------------------------------
    /**
    A file in the Amazon bucket that we share with Android. If we are
    going to make any changes or add any files, we need to involve them in the
    discussion.
    */
    var url: URL {
        return rootURL.appendingPathComponent(name)
    }
    
    //! Inverse of BackdropFile.url()
    static func fromURL(_ url: String) -> BackdropFile? {
        if let range = url.range(of: rootURL.absoluteString) {
            let name = url.substring(with: range.upperBound..<url.endIndex)
            return BackdropFile.fromName(name)
        }
        return nil
    }
    
    // ---------------------------------------------
    // MARK: - JSON
    // ---------------------------------------------
    /**
    I have to parse this as a string, not as a dict, because of Android compatibility. Unfortunately
    that makes this fragile. 😦
    */
    static func JSONForFile(_ file: BackdropFile?) -> String? {
        if file == nil {
            return ""
        } else if let path = file?.url.absoluteString {
            return "{\"" + backdropURLKey + "\":\"" + path + "\"}"
        }
        return nil
    }
    
    //! Inverse of BackdropFile.JSONForFile
    static func fromJSON(_ json: String) -> Result<BackdropFile?, NSError> {
        var result: Result<BackdropFile?, NSError>
        if let rootRange = json.range(of: rootURL.absoluteString) {
            let start = rootRange.lowerBound
            let end = json.index(json.endIndex, offsetBy: -2)
            if start < end {
                let url = json.substring(with: start..<end)
                let file = BackdropFile.fromURL(url)
                result = Result(value: file)
                return result
            }
        } else if json == "" {
            result = Result(value: nil)
            return result
        }
        let error = NSError(domain: "ProfileKit.BackdropFile.fromJSON", code: BackdropError.jsonParse.rawValue, userInfo: [NSLocalizedDescriptionKey: "bad JSON"])
        result = Result(error: error)
        return result
    }
}


func ==(lhs: BackdropFile, rhs: BackdropFile) -> Bool {
    return lhs.type == rhs.type && lhs.n == rhs.n
}

