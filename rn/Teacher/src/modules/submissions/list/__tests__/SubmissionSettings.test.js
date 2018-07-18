//
// Copyright (C) 2017-present Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { SubmissionSettings, mapStateToProps } from '../SubmissionSettings'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../redux/__templates__/app-state'),
}

let defaultProps = {
  courseID: '1',
  assignmentID: '2',
  navigator: template.navigator(),
  updateAssignment: jest.fn(),
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

describe('mapStateToProps', () => {
  let ownProps = {
    courseID: '1',
    assignmentID: '1',
  }

  it('returns the muted value of the assignment', () => {
    let state = template.appState({
      entities: {
        assignments: {
          '1': {
            data: template.assignment({ muted: true }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.muted).toEqual(true)
  })

  it('returns the assignment', () => {
    let state = template.appState({
      entities: {
        assignments: {
          '1': {
            data: template.assignment(),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.assignment).toEqual(state.entities.assignments['1'].data)
  })
})
