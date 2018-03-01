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

  it('renders the anonymous grading toggle as disabled when disableAnonymous is true', () => {
    let tree = renderer.create(
      <SubmissionSettings {...defaultProps} disableAnonymous={true} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
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

describe('mapStateToProps', () => {
  let ownProps = {
    courseID: '1',
    assignmentID: '1',
  }

  it('disables anonymous and anonymous is true when the course is anonymous', () => {
    let state = template.appState({
      entities: {
        courses: {
          '1': {
            enabledFeatures: ['anonymous_grading'],
          },
        },
        assignments: {
          '1': {
            data: template.assignment(),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props).toMatchObject({
      anonymous: true,
      disableAnonymous: true,
    })
  })

  it('disables anonymous and anonymous is truen when the assignment is associated to a quiz and it has anonymous_submissions turned on', () => {
    let state = template.appState({
      entities: {
        courses: {
          '1': {
            enabledFeatures: [],
          },
        },
        assignments: {
          '1': {
            data: template.assignment({ id: '1', quiz_id: '1' }),
            anonymousGradingOn: false,
          },
        },
        quizzes: {
          '1': {
            data: template.quiz({ id: '1', anonymous_submissions: true }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props).toMatchObject({
      anonymous: true,
      disableAnonymous: true,
    })
  })

  it('doesnt disable anonymous and anonymous is true when the assignment has anonymous grading turned on', () => {
    let state = template.appState({
      entities: {
        courses: {
          '1': {
            enabledFeatures: [],
          },
        },
        assignments: {
          '1': {
            data: template.assignment(),
            anonymousGradingOn: true,
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props).toMatchObject({
      anonymous: true,
      disableAnonymous: false,
    })
  })

  it('returns the muted value of the assignment', () => {
    let state = template.appState({
      entities: {
        courses: {
          '1': {
            enabledFeatures: [],
          },
        },
        assignments: {
          '1': {
            data: template.assignment({ muted: true }),
            anonymousGradingOn: false,
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
        courses: {
          '1': {
            enabledFeatures: [],
          },
        },
        assignments: {
          '1': {
            data: template.assignment(),
            anonymousGradingOn: false,
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.assignment).toEqual(state.entities.assignments['1'].data)
  })
})
