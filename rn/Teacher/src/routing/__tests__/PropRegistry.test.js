// @flow

import PropRegistry from '../PropRegistry'

describe('PropRegistry', () => {
  beforeEach(() => {
    PropRegistry.registry = { }
  })

  test('saves props', () => {
    const props = { foo: 'bar' }
    PropRegistry.save('fizzbuzz', props)

    const savedProps = PropRegistry.load('fizzbuzz')
    expect(savedProps.foo).toEqual('bar')
  })

  test('returns empty object if bad instance id', () => {
    const savedProps = PropRegistry.load('fizzbuzz')
    expect(savedProps).toEqual({})
  })
})
