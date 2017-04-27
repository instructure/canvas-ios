// @flow

import React from 'react'
import { RubricDetails } from '../RubricDetails'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  assignmentID: '1',
  rubricItems: [templates.rubric()],
  rubricSettings: templates.rubricSettings(),
}

describe('Rubric', () => {
  it('doesnt render anything when there is no rubric', () => {
    let props = {
      ...defaultProps,
      rubricItems: null,
    }
    let tree = renderer.create(
      <RubricDetails {...props} />
    ).toJSON()

    expect(tree).toBeNull()
  })

  it('renders a rubric', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})
