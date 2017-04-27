// @flow

import React from 'react'
import RubricItem from '../RubricItem'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  rubricItem: templates.rubric(),
}

describe('RubricItem', () => {
  it('renders', () => {
    let tree = renderer.create(
      <RubricItem {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})
