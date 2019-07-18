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
import { GroupList, mapStateToProps } from '../GroupList'
import renderer from 'react-native-test-utils'
import * as template from '../../../__templates__'

let defaultProps = {
  group: template.group(),
  groupID: template.group().id,
  courseID: '1',
  navigator: template.navigator({
    dismiss: jest.fn(),
  }),
  refresh: jest.fn(),
  refreshing: false,
  pending: 0,
  error: '',
}

jest
  .mock('../../../routing/Screen', () => 'Screen')

describe('GroupList', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders properly', () => {
    let tree = renderer(
      <GroupList {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders without a group', () => {
    let noGroupProps = {
      ...defaultProps,
      group: null,
    }
    let tree = renderer(
      <GroupList {...noGroupProps}/>
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders empty list', () => {
    let noUserProps = {
      ...defaultProps,
      group: {
        ...defaultProps.group,
        users: null,
      },
    }
    let tree = renderer(
      <GroupList {...noUserProps}/>
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('navigates to the context card when an avatar is pressed', () => {
    let view = renderer(
      <GroupList {...defaultProps} />
    )
    let avatar = view.query('[accessibilityTraits="button"]')
    avatar.simulate('press')
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      `/courses/1/users/1`,
      { modal: true }
    )
  })
})

describe('mapStateToProps', () => {
  it('maps group list refs to props', () => {
    const group = template.group({ id: '1' })

    let ownProps = {
      groupID: group.id,
      courseID: '1',
    }

    const state = template.appState({
      entities: {
        groups: {
          [group.id]: {
            group: {
              ...group,
            },
            pending: 0,
            error: null,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, ownProps)
    ).toEqual({
      pending: 0,
      error: null,
      groupID: '1',
      group: group,
    })
  })

  it('maps without a group in state', () => {
    const group = template.group({ id: '1' })

    let ownProps = {
      groupID: group.id,
      courseID: '1',
    }

    const state = template.appState({
      entities: {
        groups: {
        },
      },
    })

    expect(
      mapStateToProps(state, ownProps)
    ).toEqual({
      pending: 0,
      error: null,
      groupID: '1',
      group: null,
    })
  })
})
