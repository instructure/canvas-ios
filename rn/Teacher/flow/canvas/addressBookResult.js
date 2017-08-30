// @flow

export type AddressBookResult = {
  id: string, // Can be a context id
  name?: string,
  full_name?: string,
  avatar_url?: string,
  type?: 'context',
  context_name?: string,
  user_count?: number,
}
