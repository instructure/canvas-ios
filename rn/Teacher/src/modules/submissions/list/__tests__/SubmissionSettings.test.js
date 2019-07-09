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
