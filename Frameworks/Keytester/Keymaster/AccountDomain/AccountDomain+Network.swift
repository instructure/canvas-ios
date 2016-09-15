//
//  AccountDomain+Network.swift
//  Keytester
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal
import SoLazy

extension AccountDomain {
    static func getAccountDomains() throws -> SignalProducer<[JSONObject], NSError> {
        guard let url = NSURL(string: "https://canvas.instructure.com/api/v1/accounts/search?per_page=50") else {
            ❨╯°□°❩╯⌢"URL parsing from normal url string didn't work"
        }
        let request = NSURLRequest(URL: url)
        return Session.unauthenticated.paginatedJSONSignalProducer(request)
    }
}
