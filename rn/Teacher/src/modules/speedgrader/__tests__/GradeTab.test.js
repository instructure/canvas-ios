// @flow

import React from 'react'
import GradeTab from '../GradeTab'
import renderer from 'react-test-renderer'

jest.mock('../components/GradePicker')
jest.mock('../components/RubricDetails')

describe('GradeTab', () => {
  it('renders', () => {
    let tree = renderer.create(
      <GradeTab />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
