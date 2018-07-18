//
// Copyright (C) 2016-present Instructure, Inc.
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
