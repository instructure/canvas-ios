//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import CanvasCore

import Security
import CanvasCore

open class Keymaster {
    
    open static let sharedInstance = Keymaster()
    open var useSharedCredentials = false {
        didSet {
            if useSharedCredentials {
                
                let service = Secrets.fetch(.parentKeychainService)
                let accessGroup = Secrets.fetch(.parentKeychainAccessGroup)
                
                if let s = service, let ag = accessGroup {
                    
                    keychain = FXKeychain(service: s, accessGroup: ag)
                }
                else {
                    NSLog("\n\n\n**WARNING**\nKeymaster was told to use shared credentials, but none exist")
                    keychain = FXKeychain.default()
                }
                
            } else {
                keychain = FXKeychain.default()
            }
        }
    }
    
    fileprivate let keychainClientsKey = "CBIKeychainClients"
    fileprivate var keychain = FXKeychain.default()
    
    open var currentSession: Session?
    
    // ---------------------------------------------
    // MARK: - Session Accessors
    // ---------------------------------------------
    open func mostRecentSession() -> Session? {
        let savedSessions = self.savedSessions()
        if savedSessions.count > 0 {
            return savedSessions[0]
        }
        
        return nil
    }
    
    open func savedSessions() -> [Session] {
        keychain.accessibility = FXKeychainAccess.accessibleAfterFirstUnlock
        let object = keychain.object(forKey: "CBIKeychainClients")
        if let sessionDicts = object as? [[String: AnyObject]] {
            return sessionDicts.flatMap { Session.fromJSON($0).map { [$0] } ?? [] }
        }
        
        return []
    }

    open func savedSessionDictionaries() -> [[String: AnyObject]] {
        keychain.accessibility = FXKeychainAccess.accessibleAfterFirstUnlock
        let object = keychain.object(forKey: "CBIKeychainClients")
        if let sessionDicts = object as? [[String: AnyObject]] {
            return sessionDicts
        }

        return []
    }
    
    open func deleteSession(_ session: Session) {
        let savedSessions = self.savedSessions()
        var mutableSessions = savedSessionDictionaries()

        for (index, savedSession) in savedSessions.enumerated() {
            if session.compare(savedSession) {
                mutableSessions.remove(at: index)
            }
        }

        keychain.setObject(mutableSessions, forKey: keychainClientsKey)
    }
    
    open func addSession(_ session: Session) {
        self.updateMostRecentSession(session)
    }
    
    /**
     Used for updating a session to the first index in the client keychain.  This function keys off of the access token
     while the add function keys off the userID and the
     
     :param: session The session you want to be moved to index 0.
     */
    open func updateMostRecentSession(_ session: Session) {
        let savedSessions = self.savedSessions()
        var mutableSessions = savedSessionDictionaries()

        for (index, savedSession) in savedSessions.enumerated() {
            if session.compare(savedSession) {
                mutableSessions.remove(at: index)
            }
        }

        mutableSessions.insert(session.dictionaryValue() as [String : AnyObject], at: 0)
        keychain.setObject(mutableSessions, forKey: keychainClientsKey)
    }
    
    // ---------------------------------------------
    // MARK: - User
    // ---------------------------------------------
    open func logout() {
        guard let session = currentSession else {
            return
        }
        
        deleteSession(session)
        currentSession = nil
    }
    
    open func switchUser() {
        currentSession = nil
    }
    
    open func login(_ session: Session) {
        currentSession = session
        addSession(session)
    }
    
    // ---------------------------------------------
    // MARK: - Masquerading
    // ---------------------------------------------
    open func masqueradeForUser(_ id: String, domain: String? = nil) {
        guard let session = currentSession else {
            return
        }
        
        var domainifiedDomain = domain
        domainifiedDomain?.domainify()
        
        if currentSession?.baseURL.host == domainifiedDomain {
            let newSession = Session(baseURL: session.baseURL, user: session.user, token: session.token, masqueradeAsUserID: id)
            currentSession = newSession
        } else {
            
        }
        
        // TODO: Fetch the masqueraded user and set it on the session
    }
    
    open func stopMasquerading() {
        guard let currentSession = currentSession, let _ = currentSession.masqueradeAsUserID else {
            return
        }
        
        deleteSession(currentSession)
        // TODO: Fetch the user and set it on the session
        let newSession = Session(baseURL: currentSession.baseURL, user: currentSession.user, token: currentSession.token)
        addSession(newSession)
        self.currentSession = newSession
    }
}
