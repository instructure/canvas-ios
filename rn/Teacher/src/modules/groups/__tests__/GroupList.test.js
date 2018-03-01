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
import { GroupList, mapStateToProps } from '../GroupList'
import renderer from 'react-native-test-utils'

const template = {
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/group'),
  ...require('../../../redux/__templates__/app-state'),
}

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
    let avatar = view.query('Avatar')
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
