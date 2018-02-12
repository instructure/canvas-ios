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
import {
  CourseSelect,
  mapStateToProps,
  shouldRefresh,
  doRefresh,
  isRefreshing } from '../CourseSelect'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import i18n from 'format-message'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let template = {
  ...require('../../../__templates__/course'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

let c1 = template.course({
  is_favorite: true,
  id: '1',
})

let c2 = template.course({
  is_favorite: false,
  id: '2',
})

let c3 = template.course({
  is_favorite: false,
  id: '3',
})

let defaultProps = {
  navigator: template.navigator({
    dismiss: jest.fn(),
  }),
  onSelect: jest.fn(),
  pending: false,
  sections: [
    {
      key: 0,
      title: 'favorites',
      data: [c1],
    },
    {
      key: 1,
      title: 'courses',
      data: [c2, c3],
    },
  ],
}

describe('CourseSelect', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <CourseSelect {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders and then selects a course and then dismisses', () => {
    const component = renderer.create(
      <CourseSelect {...defaultProps} />
    )
    const tree = component.toJSON()
    expect(tree).toMatchSnapshot()
    const courseRow = explore(tree).selectByID(`inbox.course-select.course-${c1.id}`) || {}
    courseRow.props.onPress()
    expect(defaultProps.onSelect).toHaveBeenCalled()
  })

  it('mapStateToProps', () => {
    const appState = template.appState({
      entities: {
        courses: {
          [c1.id]: {
            course: c1,
          },
          [c2.id]: {
            course: c2,
          },
          [c3.id]: {
            course: c3,
          },
        },
      },
    })

    let result = mapStateToProps(appState)
    expect(result).toMatchObject({
      sections: [
        {
          key: 0,
          title: i18n('Favorite Courses'),
          data: [c1],
        },
        {
          key: 1,
          title: i18n('Courses'),
          data: [c2, c3],
        },
      ],
    })
  })

  it('refresh functions', () => {
    const props = {
      refreshCourses: jest.fn(),
    }

    expect(shouldRefresh()).toEqual(true)
    doRefresh(props)
    expect(props.refreshCourses).toHaveBeenCalled()
    expect(isRefreshing({ pending: true })).toEqual(true)
  })
})
