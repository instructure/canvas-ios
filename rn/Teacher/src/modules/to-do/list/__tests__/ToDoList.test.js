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

import { shallow } from 'enzyme'
import React from 'react'
import { API, httpCache } from '../../../../canvas-api/model-api'
import * as template from '../../../../__templates__'
import { alertError } from '../../../../redux/middleware/error-handler'
import { updateBadgeCounts } from '../../../tabbar/badge-counts'
import Connected, { ToDoList } from '../ToDoList'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})

jest.mock('../../../tabbar/badge-counts', () => ({
  updateBadgeCounts: jest.fn(),
}))

describe('ToDoList', () => {
  let props
  beforeEach(() => {
    props = {
      navigator: template.navigator(),
      list: [template.toDoModel()],
      getNextPage: jest.fn(),
      api: new API({ policy: 'cache-only' }),
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
    }
  })

  it('gets to dos from the model api', () => {
    const list = [ template.toDoModel() ]
    const next = 'users/self/todo?page=2'
    const getNextPage = jest.fn()
    httpCache.handle('GET', 'users/self/todo', { list, next, getNextPage })
    const tree = shallow(<Connected />)
    expect(tree.find(ToDoList).props()).toMatchObject({
      list,
      next,
      getNextPage,
    })
  })

  it('renders items', () => {
    const tree = shallow(<ToDoList {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('alerts when there is a load error', () => {
    const tree = shallow(<ToDoList {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })

  it('updates tab bar todo count on refresh', () => {
    const tree = shallow(<ToDoList {...props} />)
    tree.find('FlatList').simulate('Refresh')
    expect(updateBadgeCounts).toHaveBeenCalled()
    expect(props.refresh).toHaveBeenCalled()
  })

  it('gets next page immediately if there are less than 10', () => {
    const tree = shallow(<ToDoList {...props} />)
    const getNextPage = jest.fn()
    tree.setProps({
      list: [
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '1' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '2' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '3' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '4' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '5' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '6' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '7' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '8' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '9' }),
        template.toDoModel({ needsGradingCount: 0, htmlUrl: '10' }),
      ],
      getNextPage,
    })
    expect(getNextPage).toHaveBeenCalled()
  })

  it('gets next page on end reached', async () => {
    const tree = shallow(<ToDoList {...props} />)
    tree.find('FlatList').simulate('EndReached')
    expect(props.getNextPage).toHaveBeenCalled()
  })

  it('shows Speed Grader on assignment press', () => {
    props.navigator = template.navigator({ show: jest.fn() })
    props.list = [template.toDoModel({
      courseID: '222',
      assignment: template.assignment({ id: '1' }),
    })]
    const tree = shallow(<ToDoList {...props} />)
    tree.find('FlatList').dive().find('ToDoListItem')
      .simulate('Press', props.list[0])
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/222/assignments/1/submissions/speedgrader?filter=needs_grading',
      { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: false },
    )
  })

  it('shows Speed Grader on quiz press', () => {
    props.navigator = template.navigator({ show: jest.fn() })
    props.list = [template.toDoModel({
      courseID: '222',
      assignment: null,
      quiz: template.quiz({ id: '2', assignment_id: '1' }),
    })]
    const tree = shallow(<ToDoList {...props} />)
    tree.find('FlatList').dive().find('ToDoListItem')
      .simulate('Press', props.list[0])
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/222/assignments/1/submissions/speedgrader?filter=needs_grading',
      { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: false },
    )
  })
})
