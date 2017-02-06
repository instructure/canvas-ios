//
//  Presenter.swift
//  SixtySix
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

public protocol Presenter {
    func present(_ destination: UIViewController, from source: UIViewController, animated: Bool)
}

public struct PushPresenter: Presenter {
    public func present(_ destination: UIViewController, from source: UIViewController, animated: Bool) {
        source.navigationController?.pushViewController(destination, animated: animated)
    }
    
    public init() {}
}
