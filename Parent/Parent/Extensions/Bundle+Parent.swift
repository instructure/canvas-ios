//
//  Bundle+Parent.swift
//  Parent
//
//  Created by Derrick Hathaway on 10/13/17.
//  Copyright © 2017 Instructure Inc. All rights reserved.
//

import Foundation

extension Bundle {
    static var parent: Bundle {
        return Bundle(for: StudentsListViewController.self)
    }
}
