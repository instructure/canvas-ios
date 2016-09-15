//
//  Keymaster.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 6/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import SoLazy
import TooLegit
import Security

public class Keymaster {
    
    public static let sharedInstance = Keymaster()
    public var useSharedCredentials = false {
        didSet {
            if useSharedCredentials {
                keychain = FXKeychain(service: "com.instructure.shared-credentials", accessGroup: "8MKNFMCD9M.com.instructure.shared-credentials")
            } else {
                keychain = FXKeychain.defaultKeychain()
            }
        }
    }
    
    private let keychainClientsKey = "CBIKeychainClients"
    private var keychain = FXKeychain.defaultKeychain()
    
    public var currentSession: Session?
    
    // ---------------------------------------------
    // MARK: - Session Accessors
    // ---------------------------------------------
    public func mostRecentSession() -> Session? {
        let savedSessions = self.savedSessions()
        if savedSessions.count > 0 {
            return savedSessions[0]
        }
        
        return nil
    }
    
    public func savedSessions() -> [Session] {
        keychain.accessibility = FXKeychainAccess.AccessibleAfterFirstUnlock
        let object: AnyObject? = keychain.objectForKey("CBIKeychainClients")
        if let sessionDicts = object as? [[String: AnyObject]] {
            return sessionDicts.flatMap { Session.fromJSON($0).map { [$0] } ?? [] }
        }
        
        return []
    }

    public func savedSessionDictionaries() -> [[String: AnyObject]] {
        keychain.accessibility = FXKeychainAccess.AccessibleAfterFirstUnlock
        let object: AnyObject? = keychain.objectForKey("CBIKeychainClients")
        if let sessionDicts = object as? [[String: AnyObject]] {
            return sessionDicts
        }

        return []
    }
    
    public func deleteSession(session: Session) {
        let savedSessions = self.savedSessions()
        var mutableSessions = savedSessionDictionaries()

        for (index, savedSession) in savedSessions.enumerate() {
            if session.compare(savedSession) {
                mutableSessions.removeAtIndex(index)
            }
        }

        keychain.setObject(mutableSessions, forKey: keychainClientsKey)
    }
    
    public func addSession(session: Session) {
        self.updateMostRecentSession(session)
    }
    
    /**
     Used for updating a session to the first index in the client keychain.  This function keys off of the access token
     while the add function keys off the userID and the
     
     :param: session The session you want to be moved to index 0.
     */
    public func updateMostRecentSession(session: Session) {
        let savedSessions = self.savedSessions()
        var mutableSessions = savedSessionDictionaries()

        for (index, savedSession) in savedSessions.enumerate() {
            if session.compare(savedSession) {
                mutableSessions.removeAtIndex(index)
            }
        }

        mutableSessions.insert(session.dictionaryValue(), atIndex: 0)
        keychain.setObject(mutableSessions, forKey: keychainClientsKey)
    }
    
    // ---------------------------------------------
    // MARK: - User
    // ---------------------------------------------
    public func logout() {
        guard let session = currentSession else {
            return
        }
        
        deleteSession(session)
        currentSession = nil
    }
    
    public func switchUser() {
        currentSession = nil
    }
    
    public func login(session: Session) {
        currentSession = session
        addSession(session)
    }
    
    // ---------------------------------------------
    // MARK: - Masquerading
    // ---------------------------------------------
    public func masqueradeForUser(id: String, domain: String? = nil) {
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
    
    public func stopMasquerading() {
        guard let currentSession = currentSession, _ = currentSession.masqueradeAsUserID else {
            return
        }
        
        deleteSession(currentSession)
        // TODO: Fetch the user and set it on the session
        let newSession = Session(baseURL: currentSession.baseURL, user: currentSession.user, token: currentSession.token)
        addSession(newSession)
        self.currentSession = newSession
    }
}
