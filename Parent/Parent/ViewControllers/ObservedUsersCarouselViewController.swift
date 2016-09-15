//
//  ObservedUsersCarouselViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import CoreData
import SoPersistent
import SoLazy
import ReactiveCocoa
import JaSON

typealias UserFetchedCollection = FetchedCollection<User, User>

class ObservedUsersCarouselViewController: UIViewController {
    let collection: UserFetchedCollection
    let syncProducer: User.ModelPageSignalProducer
    var disposable: Disposable?
    
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                userChanged(user)
            }
        }
    }
    let carousel : iCarousel = iCarousel(frame: CGRectZero)
    
    var userChanged: (User)->Void = { _ in }
    
    init(collection: UserFetchedCollection, syncProducer: User.ModelPageSignalProducer) {
        self.collection = collection
        self.syncProducer = syncProducer
        
        super.init(nibName: nil, bundle: nil)
        
        carousel.dataSource = self
        carousel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.type = .Rotary
        carousel.decelerationRate = 0.2
        self.view.addSubview(carousel)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": carousel]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": carousel]))
        
        collection.collectionUpdated = { [weak self] updates in
            self?.carousel.reloadData()
        }
        
        reloadData()
    }
    
    func reloadData() {
        disposable = syncProducer.start { [weak self] event in
            print(event)
            switch event {
            case .Completed, .Interrupted, .Failed:
                self?.carousel.reloadData()
            default: break
            }
        }
    }
}

extension ObservedUsersCarouselViewController : iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        // We should only have 1 section here
        return collection.numberOfItemsInSection(0)
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var itemView: UIImageView
        let itemSize: CGFloat = 90
        
        //create new view if no view is available for recycling
        if view == nil {
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:itemSize, height:itemSize))
            itemView.layer.cornerRadius = itemSize/2
            itemView.layer.borderColor = UIColor.whiteColor().CGColor
            itemView.layer.borderWidth = 4.0
            itemView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            itemView.clipsToBounds = true
        } else {
            itemView = view as! UIImageView;
        }
        
        itemView.image = UIImage(named: "icon_user")
        let user = userAtCarouselIndex(index)
        if let url = user.avatarURL {
            itemView.download(url: url, contentMode: .ScaleAspectFit)
        }
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch(option) {
        case .Spacing:
            return value * 1.75
        case .Wrap:
            return 1.0
        case .Tilt:
            return 0.2
        case .FadeMin:
            return 0.0
        case .FadeMax:
            return 0.0
        case .FadeMinAlpha:
            return 0.35
        default:
            return value
        }
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        guard (collection.numberOfItemsInSection(0) > 0) else {
            return
        }
        
        currentUser = userAtCarouselIndex(carousel.currentItemIndex)
    }
    
    func userAtCarouselIndex(index: Int) -> User {
        return collection[NSIndexPath(forRow: index, inSection: 0)]
    }
}

