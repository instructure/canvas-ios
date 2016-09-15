//
//  ClosureAliases.swift
//  Parent
//
//  Created by Brandon Pluim on 11/17/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

public typealias UIButtonAction = (UIButton) -> ()
public typealias ChallengeHandler = (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> ()