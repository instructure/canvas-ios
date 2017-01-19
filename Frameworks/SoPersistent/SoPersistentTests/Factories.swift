//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import SoAutomated
import CoreData
import TooLegit
import DoNotShipThis
import AVFoundation // fixes random "library not loaded" errors.

// MARK: - Pandas
extension Panda {
    static func build(_ context: NSManagedObjectContext,
                      id: String = "1",
                      name: String = "Bai Yun"
    ) -> Panda {
        let panda = Panda(inContext: context)
        panda.id = id
        panda.name = name
        try! context.saveFRD()
        return panda
    }
}

// MARK: - People
extension SWPerson {
    static func build(_ context: NSManagedObjectContext,
                      name: String = "Luke Skywalker",
                      height: String = "172"
    ) -> SWPerson {
        let person = SWPerson(inContext: context)
        person.name = name
        person.height = height
        try! context.saveFRD()
        return person
    }
}

// MARK: - Sessions
let _starWarsAPI: ()->Session = {
        let user = SessionUser(id: "", name: "")
        let baseURL = URL(string: "https://swapi.co/api")!
        return Session(baseURL: baseURL, user: user, token: nil, unitTesting: true)
}

extension Session {
    static var starWarsAPI: Session { return _starWarsAPI() }
}
