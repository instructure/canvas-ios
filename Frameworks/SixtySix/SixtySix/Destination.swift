//
//  Destination.swift
//  SixtySix
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit


public protocol Destination {
    associatedtype Parameters
    
    static func visit(with parameters: Parameters) throws -> UIViewController
}
