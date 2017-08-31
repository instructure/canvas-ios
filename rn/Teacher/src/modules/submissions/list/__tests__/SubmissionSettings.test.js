//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import React from 'react'
import { SubmissionSettings } from '../SubmissionSettings'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/assignments'),
}

let defaultProps = {
  courseID: '1',
  assignmentID: '2',
  navigator: template.navigator(),
  anonymousGrading: jest.fn(),
  updateAssignment: jest.fn(),
  anonymous: false,
  muted: false,
  assignment: template.assignment({ id: '2' }),
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

  it('calls updateAssignment when mute toggle is pressed', () => {
    let tree = renderer.create(
      <SubmissionSettings {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('submission-settings.muted') || {}
    toggle.props.onValueChange(true)

    expect(defaultProps.updateAssignment).toHaveBeenCalledWith(
      '1',
      { ...defaultProps.assignment, muted: true },
      defaultProps.assignment
    )
  })
})
