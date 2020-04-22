//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { SubmissionPicker, mapStateToProps } from '../SubmissionPicker'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('react-native/Libraries/LayoutAnimation/LayoutAnimation', () => ({
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
  it('returns the correct data when there is no submission ID', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {},
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

    let props = { ...subProps, submissionID: null }
    let dataProps = mapStateToProps(state, props)
    expect(dataProps).toMatchObject({
      selectedIndex: null,
    })
  })

  it('returns the correct data when there is no submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {},
        },
        submissions: {},
      },
    })

    let dataProps = mapStateToProps(state, subProps)
    expect(dataProps.selectedIndex).toBeUndefined()
  })

  it('returns the correct data when there is a submission', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {},
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
