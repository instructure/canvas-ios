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
    
    

import CoreData
import TooLegit
import SoLazy

public struct Credentials {
    let id: String
    let domain: String
    let email: String
    let password: String
    let token: String
    let name: String

    public init(id: String, domain: String, email: String, password: String, token: String, name: String) {
        self.id = id
        self.domain = domain
        self.email = email
        self.password = password
        self.token = token
        self.name = name
    }

    // MARK: Students

    public static let user1 = Credentials(
        id: "7086865",
        domain: "mobiledev.instructure.com",
        email: "mobiledevinstruct+user1@gmail.com",
        password: "finland-deflect-flab-lend-taper",
        token: "1~O7YyCsxPDKM4GCd3aybOh6jrX4kaRAgT1CXtFa7ClmG79u9mOF2j7Nr56liMdGro",
        name: "User 1"
    )

    public static let user2 = Credentials(
        id: "7087269",
        domain: "mobiledev.instructure.com",
        email: "",
        password: "firewall-clement-jingle-largesse-lechery",
        token: "1~VbcPWlz04rwjhjkKleaTdclWm6lANCmatgDvpS4NDLtqBw957x1cOhyUt6INKmLi",
        name: "User 2"
    )

    public static let user3 = Credentials(
        id: "7087360",
        domain: "mobiledev.instructure.com",
        email: "",
        password: "freckle-cozy-water-bastion-behove",
        token: "1~Re7oAox3PlWgeVksgEirLFTQ8QOcRIK6gybqUpZAMjH9M9aDikXXcqnkr0jyp9Rm",
        name: "User 3"
    )

    public static let user4 = Credentials(
        id: "6782429",
        domain: "mobiledev.instructure.com",
        email: "narmstrong+s@instructure.com",
        password: "password",
        token: "1~VrFstYIqog7pM72sX6tVWVQzlWqpVBPc6izVVQSSwZMCCW6VTWUKrcD4gai7v9Hd",
        name: "nathan student"
    )

    public static let mgpUser1 = Credentials(
        id: "2",
        domain: "narmstrong.instructure.com",
        email: "narmstrong+s@instructure.com",
        password: "password",
        token: "7895~fd6cCPK3vsIO0d2ivNTnVYfwUJRkENjIzIH18hL9qXRhqkB16MaGLakuaiYNxwfA",
        name: "narmstrong+s@instructure.com"
    )

    // MARK: Teachers

    public static let teacher1 = Credentials(
        id: "7089580",
        domain: "mobiledev.instructure.com",
        email: "mobiledevinstruct+teacher1@gmail.com",
        password: "showdown-wording-gamy-dank-macao",
        token: "1~26aSyGFzmqM8ocsSuAhoiwcln3O3KqWSrtHTUgvuOzpvLIMHMsduGXKFGjF8Guo3",
        name: "Teacher 1"
    )

    // MARK: Beta

    public static let user1Beta = Credentials(
        id: user1.id,
        domain: "mobiledev.beta.instructure.com",
        email: user1.email,
        password: user1.password,
        token: user1.token,
        name: user1.name
    )

    public static let user2Beta = Credentials(
        id: user2.id,
        domain: "mobiledev.beta.instructure.com",
        email: user2.email,
        password: user2.password,
        token: user2.token,
        name: user2.name
    )

    public static let teacher1Beta = Credentials(
        id: teacher1.id,
        domain: "mobiledev.beta.instructure.com",
        email: teacher1.email,
        password: teacher1.password,
        token: teacher1.token,
        name: teacher1.name
    )
}

public class User {
    let credentials: Credentials

    public var id: String {
        return credentials.id
    }

    public lazy var session: Session = {
        let creds = self.credentials
        let user = SessionUser(id: creds.id, name: creds.name, loginID: nil, sortableName: creds.name, email: creds.email, avatarURL: nil)
        let baseURL = NSURL(string: "https://\(creds.domain)")!
        return Session(baseURL: baseURL, user: user, token: creds.token, unitTesting: true)
    }()

    public init(credentials: Credentials) {
        self.credentials = credentials
    }
}

extension Session {
    public convenience init(baseURL: NSURL, user: SessionUser, token: String?, unitTesting: Bool) {
        self.init(baseURL: baseURL, user: user, token: token)
        if unitTesting {
            storeType = NSInMemoryStoreType
        }
    }

    public static var user1: Session {
        return User(credentials: .user1).session
    }
}
