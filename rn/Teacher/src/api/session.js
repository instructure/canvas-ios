/* @flow */

export type Session = {
  authToken: string,
  baseURL: string,
}

let currentSession: ?Session = null

export function setSession (session: ?Session) {
  currentSession = session
}

export function getSession (): ?Session {
  return currentSession
}
