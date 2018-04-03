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

const diveList = (list: any) =>
  shallow(
    <list>
      {list.prop('data').map((item, index) =>
        <item key={list.prop('keyExtractor')(item)}>
          {list.prop('renderItem')({ item, index })}
        </item>
      )}
    </list>
  )

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
    diveList(tree.find('FlatList')).find('ToDoListItem')
      .simulate('Press', props.list[0])
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/222/gradebook/speed_grader',
      { modal: true, modalPresentationStyle: 'fullscreen' },
      {
        filter: expect.any(Function),
        studentIndex: 0,
        assignmentID: '1',
        onDismiss: expect.any(Function),
      },
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
    diveList(tree.find('FlatList')).find('ToDoListItem')
      .simulate('Press', props.list[0])
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/222/gradebook/speed_grader',
      { modal: true, modalPresentationStyle: 'fullscreen' },
      {
        filter: expect.any(Function),
        studentIndex: 0,
        assignmentID: '1',
        onDismiss: expect.any(Function),
      },
    )
  })
})
