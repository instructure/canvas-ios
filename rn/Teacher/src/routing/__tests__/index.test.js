// @flow

import store from '../../redux/store'
import { View } from 'react-native'
import { route, registerScreen, screenID } from '../index'

test('throws on unknown route', () => {
  const url = '/unknown/route/37'

  expect(() => { route(url) }).toThrow()
})

describe('route for foobars/:foobarID/baz', () => {
  beforeAll(() => {
    registerScreen('/foobars/:foobarID/baz', () => View, store)
  })

  it('parses foobarID', () => {
    const url = 'https://whatever/api/v1/foobars/134/baz'
    const destination = {
      screen: screenID('/foobars/:foobarID/baz'),
      passProps: { foobarID: '134' },
    }

    expect(route(url)).toEqual(destination)
  })

  it('ignores queries', () => {
    const url = 'https://host/api/v1/foobars/12/baz?q=47'
    const destination = {
      screen: screenID('/foobars/:foobarID/baz'),
      passProps: { foobarID: '12' },
    }

    expect(route(url)).toEqual(destination)
  })

  it('handles simple paths', () => {
    const url = '/foobars/87/baz'
    const destination = {
      screen: screenID('/foobars/:foobarID/baz'),
      passProps: { foobarID: '87' },
    }

    expect(route(url)).toEqual(destination)
  })

  it('handles path with extra parameters', () => {
    const url = '/foobars/87/baz'
    const destination = {
      screen: screenID('/foobars/:foobarID/baz'),
      passProps: { foobarID: '87', baz: '97' },
    }

    const result = route(url, { baz: '97' })
    expect(result).toEqual(destination)
  })
})
