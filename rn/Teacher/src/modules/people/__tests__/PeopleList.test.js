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
import { ActionSheetIOS } from 'react-native'
import { PeopleList, mapStateToProps, type Props } from '../PeopleList'
// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../__templates__/addressBook'),
  ...require('../../../__templates__/course'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')
  .mock('../../../common/TypeAheadSearch', () => 'TypeAheadSearch')
  .mock('../../../common/components/rows/Row', () => 'Row')
  .mock('ActionSheetIOS', () => ({
    showActionSheetWithOptions: jest.fn(),
  }))

const u1 = template.addressBookResult({
  id: '1',
})
const u2 = template.addressBookResult({
  id: '2',
})

describe('People List', () => {
  let props: Props
  beforeEach(() => {
    jest.resetAllMocks()
    props = {
      onSelect: jest.fn(),
      context: 'course_1',
      name: 'Address Book Course',
      navigator: template.navigator(),
      courseColor: '#f00',
      course: template.course(),
      mashAllContactsInGroups: true,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders type ahead search results', () => {
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([u1, u2], null)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(2)
  })

  it('renders next type ahead search results', () => {
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestStarted()
    typeahead.props.onRequestFinished([u1], null)
    typeahead.props.onNextRequestFinished([u2], null)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(2)
  })

  it('pushes next branch', () => {
    props.navigator.show = jest.fn()
    const teachers = template.addressBookResult({
      id: 'course_1_teachers',
      name: 'Teachers',
    })
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([teachers], null)
    const row: any = explore(screen.toJSON()).selectByID('course_1_teachers')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(
      `/courses/${props.course.id}/users`,
      { },
      {
        onSelect: expect.any(Function),
        context: 'course_1_teachers',
        name: 'Teachers',
        showFilter: false,

      },
    )
  })

  it('selects item', () => {
    props.navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
      show: jest.fn(),
    })
    const item = template.addressBookResult({
      id: '1',
      name: 'E.T.C',
    })
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([item], null)
    const row: any = explore(screen.toJSON()).selectByID('1')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/users/1', undefined, { modal: false })
    expect(screen.getInstance().state.selectedRowID).toBe('1')
    expect(screen.getInstance()._isRowSelected(item)).toBe(true)
  })

  it('calls next on end reached', () => {
    const mock = jest.fn()
    const createNodeMock = ({ type }) => {
      if (type === 'TypeAheadSearch') {
        return {
          next: mock,
        }
      }
    }
    const screen = render(props, { createNodeMock })
    const list: any = explore(screen.toJSON()).selectByType('RCTScrollView')
    list.props.onEndReached()
    expect(mock).toHaveBeenCalled()
  })

  it('give type ahead the correct params', () => {
    props.context = 'course_2'
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    expect(typeahead.props.parameters('Malthael')).toEqual({
      context: 'course_2',
      search: 'Malthael',
      per_page: 15,
      type: 'user',
      skip_visibility_checks: 1,
    })
  })

  it('Will filter', () => {
    let priorFetchedOptions = [{
      avatar_url: 'https://mobiledev.instructure.com/images/messages/avatar-group-50.png',
      type: 'context',
      permissions: {},
      id: 'course_1422605_teachers',
      name: 'Teachers',
      user_count: 2,
    }]

    const screen = render(props).getInstance()
    screen._fetchInitialActionSheetOptionsHandler(priorFetchedOptions, null)
    screen._updateFilter = jest.fn()
    screen._chooseFilter()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](0)
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(screen._updateFilter).toHaveBeenCalledWith(0)
  })

  it('Will update filter with context', () => {
    let item = { id: 'course_1422605_sections',
      name: 'Course Sections',
      item_count: 3,
      type: 'context' }
    let results = [item]
    const screen = render(props).getInstance()
    screen._fetchInitialActionSheetOptionsHandler(results, null)
    screen._fetchFilterOptions = jest.fn()
    screen._updateFilter(0)
    expect(screen._fetchFilterOptions).toHaveBeenCalledWith(item.id, screen._groupFetchHandler, false)
  })

  it('Will update filter and show members', () => {
    let results = [ { avatar_url: 'https://mobiledev.instructure.com/images/messages/avatar-group-50.png',
      type: 'context',
      permissions: {},
      id: 'course_1422605_teachers',
      name: 'Teachers',
      user_count: 2 },
    { avatar_url: 'https://mobiledev.instructure.com/images/messages/avatar-group-50.png',
      type: 'context',
      permissions: {},
      id: 'course_1422605_students',
      name: 'Students',
      user_count: 7 },
    { avatar_url: 'https://mobiledev.instructure.com/images/messages/avatar-group-50.png',
      type: 'context',
      permissions: {},
      id: 'course_1422605_observers',
      name: 'Observers',
      user_count: 1 },
    { id: 'course_1422605_sections',
      name: 'Course Sections',
      item_count: 3,
      type: 'context' },
    { id: 'course_1422605_groups',
      name: 'Student Groups',
      item_count: 3,
      type: 'context' } ]
    let item = results[0]
    const screen = render(props).getInstance()
    screen._fetchInitialActionSheetOptionsHandler(results, null)
    screen._onSelectItem = jest.fn()
    screen._updateFilter(0)
    expect(screen._onSelectItem).toHaveBeenCalledWith(item)
    expect(screen.state.filters.length).toBe(1)
  })

  it('test update filter', () => {
    let someResults = [{
      'id': '4634548',
      'full_name': 'nlambson',
      'common_courses': {
        '24219': ['TeacherEnrollment'],
      },
      'common_groups': {},
      'avatar_url': 'https://training.instructure.com/images/thumbnails/39010913/U1SNohq7Gn6r1PQVxylQnaHZzR5edu9os1FfEGz9',
    }, {
      'id': '8253362',
      'full_name': 'Lance',
      'common_courses': {
        '24219': ['StudentEnrollment'],
      },
      'common_groups': {},
      'avatar_url': 'https://mobiledev.instructure.com/images/thumbnails/106457231/qHO3rtlZoJGhmUZROqY8BgXx0gBL5JWlbqWMHPSv',
    }, {
      'id': '170000003356518',
      'full_name': 'Brady Larson',
      'common_courses': {
        '24219': ['TeacherEnrollment'],
      },
      'common_groups': {},
      'avatar_url': 'https://mobiledev.instructure.com/images/thumbnails/170000000004831/5UA86Fg8SxqHjdnZ0EpLbGJCHd43mFP7UO66CexD',
    }]
    let rendering = renderWithSomeDefaultPeopleRows(props, someResults)
    expect(rendering.toJSON()).toMatchSnapshot()
  })

  function render (props: Props, options: Object = {}) {
    return renderer.create(
      <PeopleList {...props} />, options
    )
  }

  function renderWithSomeDefaultPeopleRows (props: Props, rows: AddressBookResult[]) {
    let rendering = render(props)
    const screen = rendering.getInstance()
    screen._requestFinished(rows, null)
    return rendering
  }

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }
})

describe('map state to props', () => {
  it('returns an empty object for now', () => {
    let state = template.appState()
    expect(mapStateToProps(state, { courseID: '999999' })).toEqual({ course: undefined, courseColor: undefined })
  })

  it('returns an course and color', () => {
    let course = template.course()
    let state = template.appState()
    state.entities.courses = { [course.id]: { course: course, color: '#f00' } }
    expect(mapStateToProps(state, { courseID: course.id })).toEqual({ course, courseColor: '#f00' })
  })
})
