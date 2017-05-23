// @flow

import PropRegistry from '../PropRegistry.js'

test('prop registry', () => {
  PropRegistry.save('12345', { key: 'value' })
  expect(PropRegistry.load('12345')).toMatchObject({ key: 'value' })
})

test('prop registry with broken stuff', () => {
  PropRegistry.save()
  expect(PropRegistry.load()).toMatchObject({})
  expect(PropRegistry.load('999999')).toMatchObject({})
})
