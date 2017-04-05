// @flow

export type SessionUser = {
  primary_email: string,
  id: string,
}

export type Session = {
  authToken: string,
  baseURL: string,
  user: SessionUser,
}
