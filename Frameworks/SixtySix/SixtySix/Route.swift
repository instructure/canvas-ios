//
//  Route.swift
//  SixtySix
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import UIKit
import Pathetic

public struct Route {
    let follow: (String) throws -> UIViewController?
    
    public init<D: Destination>(_ template: PathTemplate<D.Parameters>, to destination: D.Type) {
        follow = { try template.match($0).map(D.visit) }
    }
}
