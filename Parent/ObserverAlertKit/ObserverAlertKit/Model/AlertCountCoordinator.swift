//
//  AlertCountCoordinator.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 2/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import TooLegit
import SoPersistent

public class AlertCountCoordinator: ManagedObjectCountObserver<Alert> {
    private let session: Session

    public init(session: Session, predicate: NSPredicate, alertCountUpdated: (Int)->Void) {
        self.session = session
        let context = try! session.alertsManagedObjectContext()

        super.init(predicate: predicate, inContext: context, objectCountUpdated: alertCountUpdated)
    }

    public func refresh() {
        guard let remote = try? Alert.getAlerts(session) else { return }
        let sync = Alert.syncSignalProducer(inContext: context, fetchRemote: remote)
        let _ = sync.start { event in
            switch event {
            case .Failed(let e):
                print(e)
                fallthrough
            default:
                break
            }
        }
    }
}
