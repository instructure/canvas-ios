/* @flow */

import googleForm from '../google-form'

const uri = 'https://docs.google.com/a/'

describe('google form', () => {
  it('returns uri without answers', () => {
    const form = googleForm(uri, {})
    expect(form({})).toEqual(uri)
  })

  it('can be configured with entries and pre-filled answers', () => {
    const form = googleForm(uri, {
      os: '1',
      osVersion: '2',
      device: '3',
    })

    const expected = 'https://docs.google.com/a/?entry.1=iOS&entry.2=0.1'
    expect(form({ os: 'iOS', osVersion: '0.1' })).toEqual(expected)
  })

  it('converts spaces to +', () => {
    const form = googleForm(uri, {
      os: '1',
      osVersion: '2',
      device: '3',
    })

    const expected = 'https://docs.google.com/a/?entry.1=iOS&entry.3=iPhone+7'
    expect(form({ os: 'iOS', device: 'iPhone 7' })).toEqual(expected)
  })
})
