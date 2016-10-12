//
//  Group+Collections.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit

extension Group {
    
    public static func refresher(session: Session) throws -> Refresher {
        let remote = try getAllGroups(session)
        let context = try session.enrollmentManagedObjectContext()
        let sync = syncSignalProducer(inContext: context, fetchRemote: remote)
            .map { _ in }
        let colors = Enrollment.syncFavoriteColors(session, inContext: context)
        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync.concat(colors), scope: session.refreshScope, cacheKey: key)
    }
    
    public static func favoritesCollection(session: Session) throws -> FetchedCollection<Group> {
        let favorites = NSPredicate(format: "%K == YES", "isFavorite")
        let frc = try Group.fetchedResults(favorites, sortDescriptors: ["name".ascending, "id".ascending], sectionNameKeypath: nil, inContext: session.enrollmentManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }
    
    public typealias CollectionViewController = FetchedCollectionViewController<Group>
}
