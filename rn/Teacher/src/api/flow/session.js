// @flow

export type User = {
  primary_email: string,
}

export type Session = {
  authToken: string,
  baseURL: string,
  user: User,
}
