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
    
    

import TooLegit
import SoLazy
import CoreData
import SoPersistent

extension Session {
    private convenience init(baseURL: NSURL, user: SessionUser, token: String?, unitTesting: Bool) {
        self.init(baseURL: baseURL, user: user, token: token)
        if unitTesting {
            storeType = NSInMemoryStoreType
        }
    }
}

let _ivy: ()->Session = {
    
    let user = SessionUser(
        id: "5356213",
        name: "Ivy Iversen",
        loginID: "ivy",
        sortableName: "Iverson, Ivy",
        email: "derrick+ivy@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/images/thumbnails/56640046/jdWmlUJ45fnORk7lKkc7Z44t4dgLmIIooFSHXneW"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~0NPrUrYhEoKaMCgqWS1IGrIZjZ7HbV4KisYg7AzSlzRAAjtivuXUrzRF3fHycHTp",
        unitTesting: unitTesting)
}

let _art: ()->Session = {
    let user = SessionUser(
        id: "5370999",
        name: "Art Artimus",
        loginID: "art",
        sortableName: "Artimus, Art",
        email: "derrick+art@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/files/77785899/download?download_frd=1&verifier=72mditce94HTUmzKJuqKsz3vJ441KmTp4N1tVhFR"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~pwtrtRZk3N1VN3GcojSe0AFGgO14kDybKD1KVdFgHSIBbWgcDoqDsYttaDtpsrCd",
        unitTesting: unitTesting)
}

let _ns: ()->Session = {
    let user = SessionUser(
        id: "4301217",
        name: "nathan lambson",
        loginID: "nlambson",
        sortableName: "Lambson, Nathan",
        email: "nlambson+s@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/files/77785899/download?download_frd=1&verifier=72mditce94HTUmzKJuqKsz3vJ441KmTp4N1tVhFR"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~a2jh0jY1dceyFwpAAR3UZ0uCEj86nkJmDQQuYoo97qoe9eWf1Ese91kO6aFVDEnC",
        unitTesting: unitTesting)
}

let _nt: ()->Session = {
    let user = SessionUser(
        id: "4301214",
        name: "nathan lambson",
        loginID: "nlambson",
        sortableName: "Lambson, Nathan",
        email: "nlambson+t@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/files/77785899/download?download_frd=1&verifier=72mditce94HTUmzKJuqKsz3vJ441KmTp4N1tVhFR"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~0pvPDhO2uQ6mSAaVAX8XE1ogWxbWCriboUDsINoZ9HMnry0853t1QoS2z5T8NP8J",
        unitTesting: unitTesting)
}

let _nas: ()->Session = {
    let user = SessionUser(
        id: "6782429",
        name: "nathan student",
        loginID: "narmstrong+s@instructure.com",
        sortableName: "Armstrong, Nathan",
        email: "narmstrong+s@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/files/77785899/download?download_frd=1&verifier=72mditce94HTUmzKJuqKsz3vJ441KmTp4N1tVhFR"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~VrFstYIqog7pM72sX6tVWVQzlWqpVBPc6izVVQSSwZMCCW6VTWUKrcD4gai7v9Hd",
        unitTesting: unitTesting)
}

let _na_mgp: ()->Session = {
    let user = SessionUser(
        id: "2",
        name: "narmstrong+s@instructure.com",
        loginID: "narmstrong+s@instructure.com",
        sortableName: "narmstrong+s@instructure.com",
        email: "narmstrong+s@instructure.com",
        avatarURL: NSURL(string: ""))

    return Session(
        baseURL: NSURL(string: "https://narmstrong.instructure.com/")!,
        user: user,
        token: "7895~fd6cCPK3vsIO0d2ivNTnVYfwUJRkENjIzIH18hL9qXRhqkB16MaGLakuaiYNxwfA",
        unitTesting: unitTesting)
}

let _drip: ()->Session = {
    let user = SessionUser(
        id: "3828648",
        name: "Drip Dersky",
        loginID: "drip",
        sortableName: "Dersky, Drip",
        email: "derrick+drip@instructure.com",
        avatarURL: NSURL(string: "https://mobiledev.instructure.com/files/47408175/download?download_frd=1&verifier=aUgcpn1Aa4xMxT78ofiaEJNtTdi2UlgMSNkJktrK"))
    
    return Session(
        baseURL: NSURL(string: "https://mobiledev.instructure.com/")!,
        user: user,
        token: "1~pwtrtRZk3N1VN3GcojSe0AFGgO14kDybKD1KVdFgHSIBbWgcDoqDsYttaDtpsrCd",
        unitTesting: unitTesting)
}

let _parentTest: ()->Session = {
    let user = SessionUser(id: "1",
        name: "test",
        loginID: "test",
        sortableName: "test",
        email: "test@test.com",
        avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
    return Session(baseURL: NSURL(string: "https://mobile-1-canvas.portal2.canvaslms.com")!,
        user: user,
        token: "default~Sa3ThFR0ny6zu7knlUdObgp7RDN9wcoir2A9fL0sy0UfrsdbxTaJk5MHaUoiNEQM",
        unitTesting: unitTesting)
}

let _bt: ()->Session = {
    let user = SessionUser(id: "1",
                           name: "Brandon",
                           loginID: "bt",
                           sortableName: "Pluim, Brandon",
                           email: "test@test.com",
                           avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
    return Session(baseURL: NSURL(string: "https://mobiledev.instructure.com")!,
                   user: user,
                   token: "1~JC6sxZ9lNeVJloM6TOhW3pKZUsHIVTA8qwyC3wFNs67ZFsKeaYnkOTtNfdpAeuWN",
                   unitTesting: unitTesting)
}

let _observer: ()->Session = {
    let user = SessionUser(id: "6785550",
                           name: "Observer",
                           loginID: "narmstrong+observer@instructure.com",
                           sortableName: "Observer",
                           email: "test@test.com",
                           avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
    return Session(baseURL: NSURL(string: "https://mobiledev.instructure.com")!,
                   user: user,
                   token: "1~QOd45db8aiNWaecBXzN1c5Xx4uFBMthk3z5jD5p32Qu5tqLtJzWMpXFaqOyjz0ff",
                   unitTesting: unitTesting)
}

let _teacher: ()->Session = {
    let user = SessionUser(id: "7089580",
                           name: "Teacher 1",
                           loginID: "mobiledevinstruct+teacher1@gmail.com",
                           sortableName: "Teacher 1",
                           email: "mobiledevinstruct+teacher1@gmail.com",
                           avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
    return Session(baseURL: NSURL(string: "https://mobiledev.instructure.com")!,
                   user: user,
                   token: "1~26aSyGFzmqM8ocsSuAhoiwcln3O3KqWSrtHTUgvuOzpvLIMHMsduGXKFGjF8Guo3",
                   unitTesting: unitTesting)
}

let _inMemory: ()->Session = {
    let session = Session.unauthenticated
    session.storeType = NSInMemoryStoreType
    return session
}

let _eg: Session = {
    
    let user = SessionUser(id: "1",
                           
                           name: "Egan",
                           
                           loginID: "bt",
                           
                           sortableName: "Anderson, Egan",
                           
                           email: "p.egan.anderson@gmail.com",
                           
                           avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
    
    return Session(baseURL: NSURL(string: "https://utah.instructure.com")!,
                   
                   user: user,
                   
                   token: "2~Rad63AsPjUHPmzySnmaVAAkgZl4K7FPYJnMmMBmCkFczdSpWix0s0TWCgKLUENtU")
    
}()

let _twilsonStudent2: Session = {
    
    let user = SessionUser(id: "12",
                           
                           name: "student1hahahaha",
                           
                           loginID: "student1",
                           
                           sortableName: "One, Studenthahahah",
                           
                           email: "whoknows@somedomain.whatevs",
                           
                           avatarURL: NSURL(string: "https://twilson.instructure.com/files/375/download?download_frd=1&verifier=YUK83UfpkaN815lL5nnl986DIOYjfgIHlfUBCcIz")!)
    
    return Session(baseURL: NSURL(string: "https://twilson.instructure.com")!,
                   
                   user: user,
                   
                   token: "6040~FsPMsaFCsTlUwhrTkshvlP8p1Z2WHDp1763NkXyPiu6Mr3wdDleNYitRiG8fjk25")
    
}()

extension Session {
    public static var ivy: Session { return _ivy() }
    public static var art: Session { return _art() }
    public static var drip: Session { return _drip() }
    public static var ns: Session { return _ns() }
    public static var nt: Session { return _nt() }
    public static var nas: Session { return _nas() }
    public static var parentTest: Session { return _parentTest() }
    public static var bt: Session { return _bt() }
    public static var na_mgp: Session { return _na_mgp() }
    public static var observer: Session { return _observer() }
    public static var teacher: Session { return _teacher() }
    public static var inMemory: Session { return _inMemory() }
    public static var eg: Session { return _eg }
    public static var twilsonStudent2: Session { return _twilsonStudent2 }
}
