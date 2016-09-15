//
//  Bamboo.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

final class Bamboo: NSManagedObject, Model {

    @NSManaged var id: String
    @NSManaged var length: Double

}
