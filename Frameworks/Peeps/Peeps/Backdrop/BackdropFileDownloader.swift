//
//  BackdropFileDownloader.swift
//  iCanvas
//
//  Created by Nathan Perry on 7/24/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
        let allFileProducers = (images + shapes).map { self.imageProducer($0) }
        let allFiles = SignalProducer(values: allFileProducers)
            .flatten(.Merge)
        disposable = ScopedDisposable(allFiles.start())
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
