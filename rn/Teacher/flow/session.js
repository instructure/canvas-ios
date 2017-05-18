// @flow

export type SessionUser = {
  primary_email: string,
  id: string,
  avatar_url: string,
  name: string,
}

export type Session = {
  authToken: string,
  baseURL: string,
  user: SessionUser,
}
