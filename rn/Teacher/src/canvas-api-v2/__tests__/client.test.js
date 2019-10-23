import getClient, { getURI, clearClient } from '../client'

describe('getClient', () => {
  beforeEach(() => clearClient())

  it('creates the correct uri', () => {
    expect(getURI()).toEqual('http://mobiledev.instructure.com/api/graphql')
  })

  it('only creates one client', () => {
    let client = getClient()
    let client2 = getClient()
    expect(client2).toEqual(client)
  })
})
