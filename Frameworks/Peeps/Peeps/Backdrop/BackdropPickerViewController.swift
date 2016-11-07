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
import Foundation
import TooLegit
import ReactiveCocoa

private let backDropWidth: CGFloat = 1364
private let backDropHeight: CGFloat = 540
private let backdropWidthOverHeight = backDropWidth/backDropHeight

public class BackdropPickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // track the collection view offset so when we switch back and forth between tabs, we can save the place
    private var shapeOffset: CGFloat = 0
    private var photoOffset: CGFloat = 0
    
    public var imageSelected: ((image: UIImage) -> ())
    
    var collectionView: UICollectionView?
    var segControl: UISegmentedControl = UISegmentedControl()
    
    private let session: Session
    private var tintColor: UIColor?
    /**
    If the image changed on the server, and so we have a new value, we want to call imageSelected()
    on cancel.
    */
    private var imageUpdatedFromServer: Bool = false

    var disposable: Disposable?
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public init(session: Session, imageSelected: (UIImage) -> ()) {
        self.session = session
        self.imageSelected = imageSelected
        self.highlightedFile = session.backdropFile
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("not supported!")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let d = BackdropFileDownloader
            .sharedDownloader
            .statusChangedSignal
            .observeNext({ [weak self] file in
                if let collectionView = self?.collectionView where file.type.rawValue == self?.segControl.selectedSegmentIndex {
                    let row = file.n-1
                    dispatch_async(dispatch_get_main_queue()) {
                        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)])
                    }
                }
            }) {
                disposable = ScopedDisposable(d)
        }
        
        
        
        getBackdropOnServer(session)
            .startWithNext { file in
                self.session.backdropFile = file
                if file != self.highlightedFile {
                    self.imageUpdatedFromServer = true
                    self.highlightedFile = file
                    self.scrollToHighlighted()
                }
            }
        
        /////////////////////
        // NAVIGATION BUTTONS
        title = "Choose Cover Image"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(cancelled))
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //////////////////
        // COLLECTION VIEW
        self.navigationItem.leftBarButtonItem = cancelButton
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(BackdropCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView!)
        
        ////////////////////
        // SEGMENTED CONTROL
        let segHolder = UIView(frame: CGRectZero)
        segHolder.backgroundColor = UIColor.whiteColor()
        segHolder.translatesAutoresizingMaskIntoConstraints = false
        let segBorder = UIView(frame: CGRectZero)
        segBorder.translatesAutoresizingMaskIntoConstraints = false
        segBorder.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        segHolder.addSubview(segBorder)
        
        let items: [String] = (0..<ImageType.count()).map{n in
            let item = ImageType(rawValue: n)!
            return item.description
        }
        segControl = UISegmentedControl(items: items)
        segControl.addTarget(self, action: #selector(segPressed(_:)), forControlEvents: UIControlEvents.ValueChanged)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        
        segHolder.addSubview(segControl)
        self.view.addSubview(segHolder)
        
        /////////////
        // AUTOLAYOUT
        let views = ["seg": segHolder, "collection" : collectionView!, "border": segBorder]
        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[seg]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[seg][collection]|", options: [], metrics: nil, views: views))
        self.view.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .CenterX, relatedBy: .Equal, toItem: segControl, attribute: .CenterX, multiplier: 1.0, constant: 0))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .CenterY, relatedBy: .Equal, toItem: segControl, attribute: .CenterY, multiplier: 1.0, constant: 0))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .Width, relatedBy: .Equal, toItem: segControl, attribute: .Width, multiplier: 1, constant: 40))
        segHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[border]|", options: [], metrics: nil, views: views))
        segHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[border(1)]|", options: [], metrics: nil, views: views))
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        BackdropFileDownloader.sharedDownloader.requestAllImages()
        
        segControl.selectedSegmentIndex = ImageType.Photos.rawValue
        // we call layoutIfNeeded to make sure the collectionView doesn't try to reloadData after we have scrolled to the right place
        view.layoutIfNeeded()
        scrollToHighlighted()
        
        collectionView?.collectionViewLayout.invalidateLayout()
        
        // don't ask
        dispatch_async(dispatch_get_main_queue()) {
            self.scrollToHighlighted()
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        BackdropFileDownloader.sharedDownloader.cancelAllFetches()
    }
    
    // ---------------------------------------------
    // MARK: - Highlighted File
    // ---------------------------------------------
    private func scrollToHighlighted() {
        if let highlightedFile = self.highlightedFile {
            segControl.selectedSegmentIndex = highlightedFile.type.rawValue
            segPressed(segControl)
            if let path = pathForFile(highlightedFile) {
                collectionView?.scrollToItemAtIndexPath(path, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            }
        }
    }
    
    private var highlightedFile: BackdropFile? 
    
    // ---------------------------------------------
    // MARK: - Button Targets
    // ---------------------------------------------
    func cancelled() {
        if imageUpdatedFromServer {
            if let highlightedFile = highlightedFile, image = highlightedFile.localFile {
                imageSelected(image: image)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func segPressed(segControl: UISegmentedControl) {
        if segControl.selectedSegmentIndex == ImageType.Photos.rawValue {
            shapeOffset = collectionView!.contentOffset.y
        } else {
            photoOffset = collectionView!.contentOffset.y
        }
        collectionView!.reloadData()
        if segControl.selectedSegmentIndex == ImageType.Photos.rawValue {
            collectionView!.setContentOffset(CGPointMake(0,photoOffset), animated: false)
        } else {
            collectionView!.setContentOffset(CGPointMake(0, shapeOffset), animated: false)
        }
    }
    
    // ---------------------------------------------
    // MARK: - DataSource
    // ---------------------------------------------
    private func pathForFile(file: BackdropFile) -> NSIndexPath? {
        if file.type.rawValue == self.segControl.selectedSegmentIndex {
            return NSIndexPath(forRow: file.n-1, inSection: 0)
        }
        return nil
    }
    
    private func fileForPath(indexPath: NSIndexPath) -> BackdropFile {
        return BackdropFile(type: ImageType(rawValue: self.segControl.selectedSegmentIndex)!, n: indexPath.row+1)
    }
    
    private func imageForPath(indexPath: NSIndexPath) -> UIImage? {
        let file = fileForPath(indexPath)
        return file.localFile
    }
    
    private func progressForPath(indexPath: NSIndexPath) -> Float {
        return BackdropFileDownloader
            .sharedDownloader
            .progressforFile(self.fileForPath(indexPath))
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackdropFileDownloader
            .sharedDownloader
            .numberOfRowsInSection(ImageType(rawValue: segControl.selectedSegmentIndex)!)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! BackdropCell
        if let image = self.imageForPath(indexPath) {
            cell.image = image
        } else {
            cell.progress = self.progressForPath(indexPath)
        }
        let file = self.fileForPath(indexPath)
        cell.contentView.layer.borderColor = (file == self.highlightedFile) ? view.tintColor.CGColor : UIColor.clearColor().CGColor
        cell.contentView.layer.borderWidth = 5.0
        return cell
    }
    
    // ---------------------------------------------
    // MARK: - Flow Layout Delegate
    // ---------------------------------------------
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width/backdropWidthOverHeight)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    // ---------------------------------------------
    // MARK: - Delegate
    // ---------------------------------------------
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let image = self.imageForPath(indexPath) {
            self.highlightedFile = self.fileForPath(indexPath)
            session.backdropFile = self.highlightedFile
            setBackdropOnServer(self.highlightedFile, session: session)
                .startWithFailed { err in print(err) }
            imageSelected(image: image)
            navigationController?.popViewControllerAnimated(true)
        }
    }

}















