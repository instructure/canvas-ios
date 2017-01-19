//
//  FavoriteBagelsViewController.swift
//  EverythingBagel
//
//  Created by Derrick Hathaway on 12/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SoPersistent
import SoPretty
import Result
import ReactiveSwift
import ReactiveCocoa

class BagelCardCell: PrettyCardsCell {
    @IBOutlet var name: UILabel!
}


struct PrettyBagelViewModel: CollectionViewCellViewModel {
    let name: String
    
    static func viewDidLoad(_ collectionView: UICollectionView) {
        let nib = UINib(nibName: "BagelCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "prettyBagel")
    }
    
    static let layout: UICollectionViewLayout = PrettyCardsLayout()
    
    func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "prettyBagel", for: indexPath) as! BagelCardCell
        cell.name.text = name
        return cell
    }
}



class FavoriteBagelsViewController: Bagel.CollectionViewController {
    let context: NSManagedObjectContext
    
    lazy var editAction: Action<(), (), NoError> = {
        return Action() { [weak self] _ in
            guard let me = self else { return .empty }
            
            let all = try! AllBagelsViewController(context: me.context)
            let nav = UINavigationController(rootViewController: all)
            me.present(nav, animated: false)
            
            return .empty
        }
    }()
    
    lazy var refreshAction: Action<(), (), NoError> = {
        return Action() { [weak self] _ in
            guard let refresher = self?.refresher else { return .empty }
            defer { refresher.refresh(true) }
            let nextComplete = refresher
                .refreshingCompleted
                .take(first: 1)
                .map { _ in () }
            return SignalProducer(nextComplete)
        }
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        do {
            prepare(try Bagel.favorites(in: context), refresher: Bagel.refresh(in: context)) { PrettyBagelViewModel(name: $0.name) }
        } catch {
            print(error.localizedDescription)
        }
        
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        edit.reactive.pressed = CocoaAction(editAction)
        navigationItem.rightBarButtonItem = edit
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        refresh.reactive.pressed = CocoaAction(refreshAction)
        navigationItem.leftBarButtonItem = refresh
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
