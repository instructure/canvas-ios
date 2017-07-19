// @flow

import 'react-native'
import React from 'react'
import RowWithDateInput from '../RowWithDateInput'

import renderer from 'react-test-renderer'

test('Render row with date', () => {
  let aRow = renderer.create(
    <RowWithDateInput
      title='Row with a date in it!'
      date='this should be a date'
       />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})

test('Render row with date and the clear button', () => {
  let aRow = renderer.create(
    <RowWithDateInput
      title='Row with a date in it!'
      date='this should be a date'
      showRemoveButton={true}
    />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})
