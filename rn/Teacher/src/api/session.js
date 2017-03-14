/* @flow */

let currentSession: ?Session = null

export function setSession (session: ?Session): void {
  currentSession = session
}

export function getSession (): ?Session {
  return currentSession
}
