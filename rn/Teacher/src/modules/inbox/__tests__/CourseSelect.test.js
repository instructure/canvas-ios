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

// @flow

import React from 'react'
import {
  CourseSelect,
  mapStateToProps,
  shouldRefresh,
  doRefresh,
  isRefreshing } from '../CourseSelect'
import { shallow } from 'enzyme'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import i18n from 'format-message'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

let template = {
  ...require('../../../__templates__/course'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

let c1 = template.course({
  is_favorite: true,
  id: '1',
  concluded: false,
})

let c2 = template.course({
  is_favorite: false,
  id: '2',
  concluded: false,
})

let c3 = template.course({
  is_favorite: false,
  id: '3',
  concluded: false,
})

let c4 = template.course({
  id: '4',
  workflow_state: 'completed',
  concluded: false,
})

let c5 = template.course({
  id: '5',
  concluded: true,
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
  selectedCourseId: '2',
}

describe('CourseSelect', () => {
  beforeEach(() => jest.clearAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <CourseSelect {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('matches the style of the account', () => {
    let tree = shallow(<CourseSelect {...defaultProps} />)
    expect(tree.props().navBarStyle).toBe('modal')
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

  it('indicates the previously selected course', () => {
    const tree = renderer.create(<CourseSelect {...defaultProps} />).toJSON()
    expect(explore(tree).selectByID(`inbox.course-select.course-${c1.id}.checkmark`)).toBeNull()
    expect(explore(tree).selectByID(`inbox.course-select.course-${c2.id}.checkmark`)).not.toBeNull()
    expect(explore(tree).selectByID(`inbox.course-select.course-${c3.id}.checkmark`)).toBeNull()
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
          [c4.id]: {
            course: c4,
          },
          [c5.id]: {
            course: c5,
          },
        },
      },
    })

    let result = mapStateToProps(appState)
    expect(result).toMatchObject({
      sections: [
        {
          key: 0,
          title: i18n('Favorited Courses'),
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
