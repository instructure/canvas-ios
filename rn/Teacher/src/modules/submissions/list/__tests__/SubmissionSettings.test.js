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
import { SubmissionSettings } from '../SubmissionSettings'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import * as template from '../../../../__templates__'

jest.mock('Switch', () => 'Switch')

let defaultProps = {
  courseID: '1',
  assignmentID: '2',
  navigator: template.navigator(),
  mutate: jest.fn(),
  id: 'some_graphql_id',
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

  it('calls mutate when mute toggle is pressed', () => {
    let tree = renderer.create(
      <SubmissionSettings {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('submission-settings.muted') || {}
    toggle.props.onValueChange(true)

    expect(defaultProps.mutate).toHaveBeenCalledWith(
      {
        variables: {
          id: defaultProps.assignmentID,
          muted: true,
        },
        optimisticResponse: {
          updateAssignment: {
            assignment: {
              id: defaultProps.id,
              muted: true,
              __typename: 'Assignment',
            },
            __typename: 'UpdateAssignmentPayload',
          },
        },
      }
    )
  })
})
