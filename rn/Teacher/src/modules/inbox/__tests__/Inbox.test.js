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
import 'react-native'
import React from 'react'
import { shallow } from 'enzyme'
import { Inbox, handleRefresh, shouldRefresh, mapStateToProps, Refreshed } from '../Inbox'
import Navigator from '../../../routing/Navigator'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

const template = {
  ...require('../../../__templates__/conversations'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
}

const c1 = template.conversation({
  id: '1',
  context_code: 'course_1',
})
const c2 = template.conversation({
  id: '2',
  context_code: 'course_2',
})

let defaultProps = {
  courses: [template.course()],
  conversations: [c1, c2],
  refreshInboxAll: jest.fn(),
  refreshCourses: jest.fn(),
  scope: 'all',
  navigator: template.navigator({
    show: jest.fn(),
  }),
}

beforeEach(() => jest.clearAllMocks())

describe('Inbox', () => {
  it('renders correctly', () => {
    const tree = renderer.create(
      <Inbox {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('selected an item from the inbox', () => {
    const tree = renderer.create(
      <Inbox {...defaultProps} />
    ).toJSON()
    const row = explore(tree).selectByID(`inbox.conversation-${c1.id}`) || {}
    row.props.onPress(c1.id)
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      '/conversations/1',
    )
  })

  it('doesnt call refresh function if there is no next function', () => {
    let instance = renderer.create(
      <Inbox {...defaultProps} />
    ).getInstance()

    expect(instance.getNextPage()).toBeFalsy()
    expect(defaultProps.refreshInboxAll).not.toHaveBeenCalled
  })

  it('calls the refresh function with next if next is present', () => {
    let next = jest.fn()
    let instance = renderer.create(
      <Inbox {...defaultProps} next={next} />
    ).getInstance()

    instance.getNextPage()
    expect(defaultProps.refreshInboxAll).toHaveBeenCalledWith(next)
  })

  it('renders with an empty state', () => {
    const tree = renderer.create(
      <Inbox {...defaultProps} conversations={[]} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders the starred empty state', () => {
    const tree = renderer.create(
      <Inbox {...defaultProps} conversations={[]} scope='starred' />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders the activity indicator when loading conversations', () => {
    const tree = renderer.create(
      <Inbox {...defaultProps} conversations={[]} pending={true} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls navigator.show when addMessage is called', () => {
    const instance = renderer.create(
      <Inbox {...defaultProps} />
    ).getInstance()

    instance.addMessage()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      '/conversations/compose',
      { modal: true }
    )
  })

  it('_onChangeFilter', () => {
    const updateInboxSelectedScope = jest.fn()
    const instance = renderer.create(
      <Inbox conversations={[]} updateInboxSelectedScope={updateInboxSelectedScope} />
    ).getInstance()
    instance._onChangeFilter()
    expect(updateInboxSelectedScope).toHaveBeenCalled()
  })

  it('updates on scope change', () => {
    const tree = renderer.create(
      <Inbox conversations={[]} scope='all' />
    )

    let props = {
      scope: 'unread',
      refreshInboxUnread: jest.fn(),
      refreshCourses: jest.fn(),
    }

    setProps(tree, props)
    expect(props.refreshInboxUnread).toHaveBeenCalled()

    props = {
      scope: 'unread',
      refreshInboxUnread: jest.fn(),
      refreshCourses: jest.fn(),
    }

    setProps(tree, props)
    expect(props.refreshInboxUnread).not.toHaveBeenCalled()
    expect(props.refreshCourses).not.toHaveBeenCalled()
  })

  it('refreshed component', () => {
    const props = {
      conversations: [],
      refreshCourses: jest.fn(),
      refreshInboxAll: jest.fn(),
      scope: 'all',
      courses: [template.course()],
    }

    const tree = renderer.create(
      <Refreshed {...props} />
    )
    expect(tree.toJSON()).toMatchSnapshot()
    tree.getInstance().refresh()
    setProps(tree, props)
    expect(props.refreshCourses).not.toHaveBeenCalled()
    expect(props.refreshInboxAll).toHaveBeenCalled()
  })

  it('should call the right functions in handleRefresh', () => {
    let props = {
      refreshInboxAll: jest.fn(),
      scope: 'all',
      refreshCourses: jest.fn(),
      courses: [],
    }
    handleRefresh(props)
    expect(props.refreshInboxAll).toHaveBeenCalled()
    expect(props.refreshCourses).toHaveBeenCalled()

    props = {
      refreshInboxUnread: jest.fn(),
      scope: 'unread',
      refreshCourses: jest.fn(),
    }
    handleRefresh(props)
    expect(props.refreshInboxUnread).toHaveBeenCalled()

    props = {
      refreshInboxStarred: jest.fn(),
      scope: 'starred',
      refreshCourses: jest.fn(),
    }
    handleRefresh(props)
    expect(props.refreshInboxStarred).toHaveBeenCalled()

    props = {
      refreshInboxSent: jest.fn(),
      scope: 'sent',
      refreshCourses: jest.fn(),
    }
    handleRefresh(props)
    expect(props.refreshInboxSent).toHaveBeenCalled()

    props = {
      refreshInboxArchived: jest.fn(),
      scope: 'archived',
      refreshCourses: jest.fn(),
    }
    handleRefresh(props)
    expect(props.refreshInboxArchived).toHaveBeenCalled()
  })

  it('does not refresh courses if present', () => {
    const props = {
      refreshInboxArchived: jest.fn(),
      scope: 'archived',
      refreshCourses: jest.fn(),
      courses: [template.course()],
    }
    handleRefresh(props)
    expect(props.refreshCourses).not.toHaveBeenCalled()
  })

  it('filters conversations based on course', () => {
    const courses = [
      { id: '1' },
      { id: '2' },
    ]
    const tree = renderer.create(
      <Inbox {...defaultProps} courses={courses} scope='all' />
    )
    const instance = tree.getInstance()
    instance.setState({ selectedCourse: '1' })
    const node = tree.toJSON()
    expect(node).toMatchSnapshot()
  })

  it('shows CourseFilter', () => {
    const course = template.course({ id: '1' })
    const props = {
      ...defaultProps,
      courses: [course],
    }
    const view = shallow(<Inbox {...props} />)
    expect(view.find('CourseFilter')).toHaveLength(1)
  })

  it('hides CourseFilter when no courses', () => {
    const props = {
      ...defaultProps,
      courses: [],
    }
    const view = shallow(<Inbox {...props} />)
    expect(view.find('CourseFilter')).toHaveLength(0)
  })

  describe('shouldRefresh', () => {
    it('returns true when there are no conversations', () => {
      expect(shouldRefresh({
        conversations: [],
        scope: 'all',
        courses: [],
        next () {},
        navigator: new Navigator(''),
      })).toBe(true)
    })

    it('returns true when there is no next', () => {
      expect(shouldRefresh({
        conversations: [ template.conversation({}) ],
        scope: 'all',
        courses: [],
        navigator: new Navigator(''),
      })).toBe(true)
    })

    it('returns false when there is next & conversations', () => {
      expect(shouldRefresh({
        conversations: [ template.conversation({}) ],
        scope: 'all',
        courses: [],
        next () {},
        navigator: new Navigator(''),
      })).toBe(false)
    })
  })
})

describe('mapStateToProps', () => {
  it('maps state to props', () => {
    const c1 = template.conversation({
      id: '1',
    })
    const c2 = template.conversation({
      id: '2',
    })
    const course1 = template.course({ id: '1' })
    const course2 = template.course({ id: '2' })
    const appState = {
      inbox: {
        conversations: {
          '1': { data: c1 },
          '2': { data: c2 },
        },
        selectedScope: 'all',
        all: { refs: [c1.id, c2.id] },
      },
      entities: {
        courses: {
          '1': { course: course1 },
          '2': { course: course2 },
        },
      },
    }

    const results = mapStateToProps(appState)
    expect(results).toMatchObject({
      conversations: [c1, c2],
      courses: [course1, course2],
    })
  })

  it('filters courses restricted by date', () => {
    const course1 = template.course({ id: '1', access_restricted_by_date: true })
    const course2 = template.course({ id: '2', access_restricted_by_date: false })
    const appState = {
      inbox: {
        conversations: { },
        selectedScope: 'all',
        all: { refs: [] },
      },
      entities: {
        courses: {
          '1': { course: course1 },
          '2': { course: course2 },
        },
      },
    }

    const results = mapStateToProps(appState)
    expect(results.courses).toEqual([course2])
  })
})
