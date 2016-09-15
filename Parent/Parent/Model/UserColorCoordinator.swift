//
//  UserColorCoordinator.swift
//  Parent
//
//  Created by Brandon Pluim on 1/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import TooLegit

struct UserColorScheme {
    let topBackgroundTintColor: UIColor
    let bottomBackgroundTintColor: UIColor
    
    static let pinkUserScheme = UserColorScheme(topBackgroundTintColor: UIColor(r: 213, g: 0, b: 119), bottomBackgroundTintColor: UIColor(r: 81, g: 55, b: 204))
    static let blueUserScheme = UserColorScheme(topBackgroundTintColor: UIColor(r: 12, g: 215, b: 175), bottomBackgroundTintColor: UIColor(r: 28, g: 167, b: 233))
    static let redUserScheme = UserColorScheme(topBackgroundTintColor: UIColor.redColor(), bottomBackgroundTintColor: UIColor.orangeColor())
    static let greenUserScheme = UserColorScheme(topBackgroundTintColor: UIColor.blueColor(), bottomBackgroundTintColor: UIColor.greenColor())
    
    static let userColorSchemes: [UserColorScheme] = {
        var colorSchemes: [UserColorScheme] = []
        
        colorSchemes.append(UserColorScheme.pinkUserScheme)
        colorSchemes.append(UserColorScheme.blueUserScheme)
        colorSchemes.append(UserColorScheme.redUserScheme)
        colorSchemes.append(UserColorScheme.greenUserScheme)
        
        return colorSchemes
    }()
}

class UserColorCoordinator {
    
    static func colorSchemeForUser(user: User) -> UserColorScheme {
        let colorSchemes = UserColorScheme.userColorSchemes
        let randIndex = Int(user.id) % colorSchemes.count
        return(colorSchemes[randIndex])
    }
    
    static func setColorScheme(colorScheme: UserColorScheme, user: User) {
        
    }
    
}