// @flow

import React from 'react'
import GradeTab from '../GradeTab'
import renderer from 'react-test-renderer'

describe('GradePicker', () => {
  it('renders', () => {
    let tree = renderer.create(
      <GradeTab />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
