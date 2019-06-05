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
import Foundation

import ReactiveSwift

private let backDropWidth: CGFloat = 1364
private let backDropHeight: CGFloat = 540
private let backdropWidthOverHeight = backDropWidth/backDropHeight

open class BackdropPickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // track the collection view offset so when we switch back and forth between tabs, we can save the place
    fileprivate var shapeOffset: CGFloat = 0
    fileprivate var photoOffset: CGFloat = 0
    
    @objc open var imageSelected: ((_ image: UIImage) -> ())
    
    @objc var collectionView: UICollectionView?
    @objc var segControl: UISegmentedControl = UISegmentedControl()
    
    fileprivate let session: Session
    fileprivate var tintColor: UIColor?
    /**
    If the image changed on the server, and so we have a new value, we want to call imageSelected()
    on cancel.
    */
    fileprivate var imageUpdatedFromServer: Bool = false

    var disposable: Disposable?
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    @objc public init(session: Session, imageSelected: @escaping (UIImage) -> ()) {
        self.session = session
        self.imageSelected = imageSelected
        self.highlightedFile = session.backdropFile
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("not supported!")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if let d = BackdropFileDownloader
            .sharedDownloader
            .statusChangedSignal
            .observeValues({ [weak self] file in
                if let collectionView = self?.collectionView, file.type.rawValue == self?.segControl.selectedSegmentIndex {
                    let row = file.n-1
                    DispatchQueue.main.async {
                        collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
                    }
                }
            }) {
                disposable = ScopedDisposable(d)
        }
        
        
        
        getBackdropOnServer(session)
            .startWithResult { file in
                self.session.backdropFile = file.value!
                if file.value! != self.highlightedFile {
                    self.imageUpdatedFromServer = true
                    self.highlightedFile = file.value.flatMap { $0 }
                    self.scrollToHighlighted()
                }
            }
        
        /////////////////////
        // NAVIGATION BUTTONS
        title = "Choose Cover Image"
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelled))
        
        self.view.backgroundColor = UIColor.white
        
        //////////////////
        // COLLECTION VIEW
        self.navigationItem.leftBarButtonItem = cancelButton
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.register(BackdropCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.backgroundColor = UIColor.white
        self.view.addSubview(collectionView!)
        
        ////////////////////
        // SEGMENTED CONTROL
        let segHolder = UIView(frame: CGRect.zero)
        segHolder.backgroundColor = UIColor.white
        segHolder.translatesAutoresizingMaskIntoConstraints = false
        let segBorder = UIView(frame: CGRect.zero)
        segBorder.translatesAutoresizingMaskIntoConstraints = false
        segBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        segHolder.addSubview(segBorder)
        
        let items: [String] = (0..<ImageType.count()).map{n in
            let item = ImageType(rawValue: n)!
            return item.description
        }
        segControl = UISegmentedControl(items: items)
        segControl.addTarget(self, action: #selector(segPressed(_:)), for: UIControl.Event.valueChanged)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        
        segHolder.addSubview(segControl)
        self.view.addSubview(segHolder)
        
        /////////////
        // AUTOLAYOUT
        let views = ["seg": segHolder, "collection" : collectionView!, "border": segBorder]
        self.edgesForExtendedLayout = UIRectEdge()
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[seg]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collection]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[seg][collection]|", options: [], metrics: nil, views: views))
        self.view.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .centerX, relatedBy: .equal, toItem: segControl, attribute: .centerX, multiplier: 1.0, constant: 0))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .centerY, relatedBy: .equal, toItem: segControl, attribute: .centerY, multiplier: 1.0, constant: 0))
        segHolder.addConstraint(NSLayoutConstraint(item: segHolder, attribute: .width, relatedBy: .equal, toItem: segControl, attribute: .width, multiplier: 1, constant: 40))
        segHolder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: views))
        segHolder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[border(1)]|", options: [], metrics: nil, views: views))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BackdropFileDownloader.sharedDownloader.requestAllImages()
        
        segControl.selectedSegmentIndex = ImageType.photos.rawValue
        // we call layoutIfNeeded to make sure the collectionView doesn't try to reloadData after we have scrolled to the right place
        view.layoutIfNeeded()
        scrollToHighlighted()
        
        collectionView?.collectionViewLayout.invalidateLayout()
        
        // don't ask
        DispatchQueue.main.async {
            self.scrollToHighlighted()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        BackdropFileDownloader.sharedDownloader.cancelAllFetches()
    }
    
    // ---------------------------------------------
    // MARK: - Highlighted File
    // ---------------------------------------------
    fileprivate func scrollToHighlighted() {
        if let highlightedFile = self.highlightedFile {
            segControl.selectedSegmentIndex = highlightedFile.type.rawValue
            segPressed(segControl)
            if let path = pathForFile(highlightedFile) {
                collectionView?.scrollToItem(at: path, at: UICollectionView.ScrollPosition.centeredVertically, animated: false)
            }
        }
    }
    
    fileprivate var highlightedFile: BackdropFile? 
    
    // ---------------------------------------------
    // MARK: - Button Targets
    // ---------------------------------------------
    @objc func cancelled() {
        if imageUpdatedFromServer {
            if let highlightedFile = highlightedFile, let image = highlightedFile.localFile {
                imageSelected(image)
            }
        }
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func segPressed(_ segControl: UISegmentedControl) {
        if segControl.selectedSegmentIndex == ImageType.photos.rawValue {
            shapeOffset = collectionView!.contentOffset.y
        } else {
            photoOffset = collectionView!.contentOffset.y
        }
        collectionView!.reloadData()
        if segControl.selectedSegmentIndex == ImageType.photos.rawValue {
            collectionView!.setContentOffset(CGPoint(x: 0,y: photoOffset), animated: false)
        } else {
            collectionView!.setContentOffset(CGPoint(x: 0, y: shapeOffset), animated: false)
        }
    }
    
    // ---------------------------------------------
    // MARK: - DataSource
    // ---------------------------------------------
    fileprivate func pathForFile(_ file: BackdropFile) -> IndexPath? {
        if file.type.rawValue == self.segControl.selectedSegmentIndex {
            return IndexPath(row: file.n-1, section: 0)
        }
        return nil
    }
    
    fileprivate func fileForPath(_ indexPath: IndexPath) -> BackdropFile {
        return BackdropFile(type: ImageType(rawValue: self.segControl.selectedSegmentIndex)!, n: indexPath.row+1)
    }
    
    fileprivate func imageForPath(_ indexPath: IndexPath) -> UIImage? {
        let file = fileForPath(indexPath)
        return file.localFile
    }
    
    fileprivate func progressForPath(_ indexPath: IndexPath) -> Float {
        return BackdropFileDownloader
            .sharedDownloader
            .progressforFile(self.fileForPath(indexPath))
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackdropFileDownloader
            .sharedDownloader
            .numberOfRowsInSection(ImageType(rawValue: segControl.selectedSegmentIndex)!)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BackdropCell
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = String(format: NSLocalizedString("Image %d", bundle: .core, value: "", comment: ""), indexPath.item)
        if let image = self.imageForPath(indexPath) {
            cell.image = image
        } else {
            cell.progress = self.progressForPath(indexPath)
        }
        let file = self.fileForPath(indexPath)
        cell.contentView.layer.borderColor = (file == self.highlightedFile) ? view.tintColor.cgColor : UIColor.clear.cgColor
        cell.contentView.layer.borderWidth = 5.0
        return cell
    }
    
    // ---------------------------------------------
    // MARK: - Flow Layout Delegate
    // ---------------------------------------------
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: width/backdropWidthOverHeight)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    // ---------------------------------------------
    // MARK: - Delegate
    // ---------------------------------------------
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let image = self.imageForPath(indexPath) {
            self.highlightedFile = self.fileForPath(indexPath)
            session.backdropFile = self.highlightedFile
            setBackdropOnServer(self.highlightedFile, session: session)
                .startWithFailed { err in print(err) }
            imageSelected(image)
            let _ = navigationController?.popViewController(animated: true)
        }
    }

}















