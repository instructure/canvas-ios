// @flow

import React from 'react'
import GradePicker from '../GradePicker'
import renderer from 'react-test-renderer'

describe('GradePicker', () => {
  it('renders', () => {
    let tree = renderer.create(
      <GradePicker />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
