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
    
    

import UIKit
import Result
import ReactiveSwift


private let backdropSessionIdentifier = "backdropSessionIdentifier"


internal class BackdropFileDownloader: NSObject {
    
    static let sharedDownloader: BackdropFileDownloader = BackdropFileDownloader()
    
    let statusChangedSignal: Signal<BackdropFile, NoError>
    let observer: Observer<BackdropFile, NoError>
    var disposable: Disposable?
    
    fileprivate override init() {
        let (s, o) = Signal<BackdropFile, NoError>.pipe()
        statusChangedSignal = s.observe(on: UIScheduler())
        observer = o
        super.init()
    }
    
    fileprivate var progressForType = [BackdropFile: Float]()
    
    internal func requestAllImages() {
        let shapes = (1...numShapeBackdrops).map { n in
            return BackdropFile(type: .shapes, n: n)
        }
        let images = (1...numPhotoBackdrops).map { n in
            return BackdropFile(type: .photos, n: n)
        }
        let allFileProducers: [SignalProducer<UIImage, NSError>] = (images + shapes).map { self.imageProducer($0) }
        let allFiles: SignalProducer<SignalProducer<UIImage, NSError>, NSError> = SignalProducer(allFileProducers)
        disposable = ScopedDisposable(allFiles.flatten(.merge).start())
    }
    
    func imageProducer(_ file: BackdropFile) -> SignalProducer<UIImage, NSError> {
        return SignalProducer() { [weak self] observer, disposable in
            
            // already have the file downloaded
            if let localFile = file.localFile {
                observer.send(value: localFile)
                observer.sendCompleted()
                return
            }
            
            
            // download the file
            let download = URLSession.shared.downloadTask(with: file.url) { url, response, error in
                if let error = error {
                    observer.send(error: error as NSError)
                } else if let url = url {
                    let writeResult = file.writeFileToPermanentLocationFromURL(url)
                    if let image = writeResult.value {
                        observer.send(value: image)
                        observer.sendCompleted()
                        
                        self?.observer.send(value: file)
                    } else if let error = writeResult.error {
                        observer.send(error: error)
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
    
    internal func numberOfRowsInSection(_ section: ImageType) -> Int {
        switch section {
        case ImageType.shapes:
            return numShapeBackdrops
        case ImageType.photos:
            return numPhotoBackdrops
        }
    }
    
    internal func indexPathForFile(_ file: BackdropFile) -> IndexPath {
        switch file.type {
        case .shapes:
            return IndexPath(row: file.n, section: file.type.rawValue)
        case .photos:
            return IndexPath(row: file.n, section: file.type.rawValue)
        }
    }
    
    internal func progressforFile(_ type: BackdropFile) -> Float {
        if let progress = self.progressForType[type] {
            return progress
        }
        return 0
    }
}
