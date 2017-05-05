// @flow

import 'react-native'
import React from 'react'
import RowWithDetail from '../RowWithDetail'

import renderer from 'react-test-renderer'

test('Render row with detail label', () => {
  let aRow = renderer.create(
    <RowWithDetail
      title='Row with a switch in it!'
      detail='this is a detail label'
       />
  )
  expect(aRow.toJSON()).toMatchSnapshot()
})
