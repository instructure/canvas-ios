//
//  File.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoAutomated
import CoreData
import TooLegit
import DoNotShipThis
import AVFoundation // fixes random "library not loaded" errors.

// MARK: - Pandas
extension Panda {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      name: String = "Bai Yun"
    ) -> Panda {
        let panda = Panda(inContext: context)
        panda.id = id
        panda.name = name
        return panda
    }
}

// MARK: - People
extension SWPerson {
    static func build(context: NSManagedObjectContext,
                      name: String = "Luke Skywalker",
                      height: String = "172"
    ) -> SWPerson {
        let person = SWPerson(inContext: context)
        person.name = name
        person.height = height
        return person
    }
}

// MARK: - Sessions
let _starWarsAPI: ()->Session = {
        let user = SessionUser(id: "", name: "")
        let baseURL = NSURL(string: "https://swapi.co/api")!
        return Session(baseURL: baseURL, user: user, token: nil, unitTesting: true)
}

extension Session {
    static var starWarsAPI: Session { return _starWarsAPI() }
}
