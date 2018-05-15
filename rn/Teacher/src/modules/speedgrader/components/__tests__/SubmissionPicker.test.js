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
import { SubmissionPicker, mapStateToProps } from '../SubmissionPicker'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('LayoutAnimation', () => ({
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))

const templates = {
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../redux/__templates__/app-state'),
}

let noSubProps = {
  submissionID: null,
  assignmentID: '2',
  courseID: '3',
  userID: '4',
  submissionProps: {
    name: 'Allura',
    avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    status: 'none',
    userID: '4',
    grade: 'not_submitted',
    submissionID: null,
    submission: null,
  },
  excuseAssignment: jest.fn(),
  gradeSubmission: jest.fn(),
  selectSubmissionFromHistory: jest.fn(),
  selectedIndex: null,
  selectedAttachmentIndex: null,
}

let subProps = {
  ...noSubProps,
  submissionID: '1',
  submissionProps: {
    name: 'Allura',
    avatarURL: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    status: 'submitted',
    userID: '4',
    grade: '5',
    submissionID: '1',
    submission: templates.submissionHistory([
      { id: '1', grade: null, submitted_at: '2017-04-26T17:46:00Z' },
      { id: '2', grade: null, submitted_at: '2016-01-01T00:01:00Z' },
    ]),
  },
}

let withIndex = {
  ...subProps,
  selectedIndex: 1,
}

let withZeroIndex = {
  ...subProps,
  selectedIndex: 0,
}

describe('SubmissionPicker', () => {
  it('renders with no submission', () => {
    let tree = renderer.create(
      <SubmissionPicker {...noSubProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with a submission', () => {
    let tree = renderer.create(
      <SubmissionPicker {...subProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with only one submission history', () => {
    let props = {
      ...subProps,
      submissionProps: {
        ...subProps.submissionProps,
        submission: templates.submissionHistory([
          { id: '1', grade: null, submitted_at: '2017-04-26T17:46:00Z' },
        ]),
      },
    }
    let tree = renderer.create(
      <SubmissionPicker {...props} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('opens the picker', () => {
    let tree = renderer.create(
      <SubmissionPicker {...withIndex} />
    ).toJSON()

    const pickerToggle = explore(tree).selectByID('header.toggle-submission_history-picker') || {}
    pickerToggle.props.onPress()
    expect(tree).toMatchSnapshot()
  })

  it('renders the picker with a non-zero index', () => {
    let tree = renderer.create(
      <SubmissionPicker {...withIndex} />
    )

    tree.getInstance().setState({ showingPicker: true })
    expect(tree).toMatchSnapshot()
  })

  it('renders the picker with a 0 index', () => {
    let tree = renderer.create(
      <SubmissionPicker {...withZeroIndex} />
    )

    tree.getInstance().setState({ showingPicker: true })
    expect(tree).toMatchSnapshot()
  })

  it('closes the picker', () => {
    let tree = renderer.create(
      <SubmissionPicker {...withIndex} />
    )

    tree.getInstance().setState({ showingPicker: true })

    const pickerToggle = explore(tree.toJSON()).selectByID('header.toggle-submission_history-picker') || {}
    pickerToggle.props.onPress()
    expect(tree).toMatchSnapshot()
  })

  it('chooses a different submission from history', () => {
    let tree = renderer.create(
      <SubmissionPicker {...withIndex} />
    )

    tree.getInstance().setState({ showingPicker: true })

    const picker = explore(tree.toJSON()).selectByID('header.picker') || {}
    picker.props.onValueChange(0)
    expect(withIndex.selectSubmissionFromHistory).toHaveBeenCalledWith('1', 0)
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            anonymousGradingOn: true,
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
      },
    })

    let dataProps = mapStateToProps(state, noSubProps)
    expect(dataProps).toMatchObject({
      selectedIndex: null,
    })
  })

  it('returns the correct data when there is a submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            anonymousGradingOn: true,
          },
        },
        submissions: {
          '1': {
            submission: {},
            pending: 0,
            error: null,
            selectedIndex: 3,
          },
        },
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps).toMatchObject({
      selectedIndex: 3,
    })
  })
})
