// @flow

import React from 'react'
import { SubmissionSettings } from '../SubmissionSettings'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../__templates__/helm'),
}

let defaultProps = {
  courseID: '1',
  assignmentID: '2',
  navigator: template.navigator(),
  anonymousGrading: jest.fn(),
  anonymous: false,
}

describe('SubmissionSettings', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders properly', () => {
    let tree = renderer.create(
      <SubmissionSettings {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls navigator.dismiss when done is pressed', () => {
    let instance = renderer.create(
      <SubmissionSettings {...defaultProps} />
    ).getInstance()
    instance.dismiss()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls anonymousGrading when the toggle is pressed', () => {
    let tree = renderer.create(
      <SubmissionSettings {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('submission-settings.anonymous') || {}
    toggle.props.onValueChange(true)

    expect(defaultProps.anonymousGrading).toHaveBeenCalledWith(
      '1', '2', true
    )
  })
})
