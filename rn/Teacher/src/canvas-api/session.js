//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

let currentSession: ?Session = null

export function setSession (session: ?Session): void {
  currentSession = session
}

export function getSession (): Session {
  if (!currentSession) {
    console.warn('The user session is being requested, yet none exists. Are you sure that is what you want?')
    // The main usecase for actually returning this blank session is when components render on logout
    // On logout, we clear out redux which triggers components to render, which in turn those components might need a session
    // But, blank session is fine because the user has logged out
    return {
      baseURL: '',
      authToken: '',
      user: {
        id: '',
        primary_email: '',
        avatar_url: '',
        name: '',
      },
    }
  }
  return currentSession
}

// There are a few places where we do need to get the session and know whether it exists, but that's rare
// Almost everywhere should use getSession() instead
export function getSessionUnsafe (): ?Session {
  return currentSession
}

// returns true is the sessions are similar, otherwise returns false
export function compareSessions (s1: Session, s2: Session): boolean {
  return (
    s1.baseURL === s2.baseURL &&
    s1.user.id === s2.user.id &&
    s1.actAsUserID === s2.actAsUserID
  )
}
