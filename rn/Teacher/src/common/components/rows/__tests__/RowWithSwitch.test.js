// @flow

import 'react-native'
import React from 'react'
import RowWithSwitch from '../RowWithSwitch'

import renderer from 'react-test-renderer'

test('Render row with switch', () => {
  const onValueChange = jest.fn()
  let aRow = renderer.create(
    <RowWithSwitch
      title='Row with a switch in it!'
      onValueChange={onValueChange}
      identifier='test' />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
  aRow.getInstance().onValueChange(true, 'test')
  expect(onValueChange).toHaveBeenLastCalledWith(true, 'test')
})
