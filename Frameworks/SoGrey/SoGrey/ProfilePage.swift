//
//  File.swift
//  SoGrey
//
//  Created by Layne Moseley on 4/12/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation

public class ProfilePage {
    
    public static let sharedInstance = ProfilePage()
    private init() {}
    
    private let pageContainer = e.selectBy(id: "module.profile")
    
    public func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        pageContainer.assertExists()
    }
}
