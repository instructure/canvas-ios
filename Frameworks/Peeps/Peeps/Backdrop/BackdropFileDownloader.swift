
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
import ReactiveCocoa


private let backdropSessionIdentifier = "backdropSessionIdentifier"


internal class BackdropFileDownloader: NSObject {
    
    static let sharedDownloader: BackdropFileDownloader = BackdropFileDownloader()
    
    let statusChangedSignal: Signal<BackdropFile, NoError>
    let observer: Observer<BackdropFile, NoError>
    var disposable: Disposable?
    
    private override init() {
        let (s, o) = Signal<BackdropFile, NoError>.pipe()
        statusChangedSignal = s.observeOn(UIScheduler())
        observer = o
        super.init()
    }
    
    private var progressForType = [BackdropFile: Float]()
    
    internal func requestAllImages() {
        let shapes = (1...numShapeBackdrops).map { n in
            return BackdropFile(type: .Shapes, n: n)
        }
        let images = (1...numPhotoBackdrops).map { n in
            return BackdropFile(type: .Photos, n: n)
        }
        let allFileProducers: [SignalProducer<UIImage, NSError>] = (images + shapes).map { self.imageProducer($0) }
        let allFiles: SignalProducer<SignalProducer<UIImage, NSError>, NSError> = SignalProducer(values: allFileProducers)
        disposable = ScopedDisposable(allFiles.flatten(.Merge).start())
    }
    
    func imageProducer(file: BackdropFile) -> SignalProducer<UIImage, NSError> {
        return SignalProducer() { [weak self] observer, disposable in
            
            // already have the file downloaded
            if let localFile = file.localFile {
                observer.sendNext(localFile)
                observer.sendCompleted()
                return
            }
            
            
            // download the file
            let download = NSURLSession.sharedSession().downloadTaskWithURL(file.url) { url, response, error in
                if let error = error {
                    observer.sendFailed(error)
                } else if let url = url {
                    let writeResult = file.writeFileToPermanentLocationFromURL(url)
                    if let image = writeResult.value {
                        observer.sendNext(image)
                        observer.sendCompleted()
                        
                        self?.observer.sendNext(file)
                    } else if let error = writeResult.error {
                        observer.sendFailed(error)
                    }
                }
            }
            
            
            download.resume()
            
            disposable += ActionDisposable() {
                download.cancel()
            }
        }
    }
    
    func cancelAllFetches() {
        disposable = nil
    }

    // ---------------------------------------------
    // MARK: - FRC-like Functionality
    // ---------------------------------------------
    internal func numberOfSection() -> Int {
        return ImageType.count()
    }
    
    internal func numberOfRowsInSection(section: ImageType) -> Int {
        switch section {
        case ImageType.Shapes:
            return numShapeBackdrops
        case ImageType.Photos:
            return numPhotoBackdrops
        }
    }
    
    internal func indexPathForFile(file: BackdropFile) -> NSIndexPath {
        switch file.type {
        case .Shapes:
            return NSIndexPath(forRow: file.n, inSection: file.type.rawValue)
        case .Photos:
            return NSIndexPath(forRow: file.n, inSection: file.type.rawValue)
        }
    }
    
    internal func progressforFile(type: BackdropFile) -> Float {
        if let progress = self.progressForType[type] {
            return progress
        }
        return 0
    }
}
