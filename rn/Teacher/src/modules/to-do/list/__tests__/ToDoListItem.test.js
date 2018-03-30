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
import Connected, { ToDoListItem } from '../ToDoListItem'

describe('ToDoListItem', () => {
  let props
  beforeEach(() => {
    httpCache.clear()
    props = {
      navigator: template.navigator(),
      item: template.toDoModel({ courseID: '1' }),
      courseName: 'Course 1',
      courseColor: '#fff',
      api: new API({ policy: 'cache-only' }),
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
      onPress: jest.fn(),
    }
  })

  it('gets courseColor and courseName from the model api', () => {
    const courseColor = 'green'
    const course = template.courseModel()
    httpCache.handle('GET', 'users/self/colors', { custom_colors: { course_1: courseColor } })
    httpCache.handle('GET', 'courses/1', course)
    const tree = shallow(<Connected item={props.item} />)
    expect(tree.find(ToDoListItem).props()).toMatchObject({
      courseColor,
      courseName: course.name,
    })
  })

  it('renders', () => {
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders published assignment', () => {
    props.item = template.toDoModel({
      assignment: template.assignment({ name: 'Assignment 1', published: true }),
    })
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders unpublished assignment', () => {
    props.item = template.toDoModel({
      assignment: template.assignment({ name: 'Assignment 1', published: false }),
    })
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders quiz', () => {
    props.item = template.toDoModel({
      assignment: null,
      quiz: template.quiz({ title: 'Quiz 1' }),
    })
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders discussion', () => {
    props.item = template.toDoModel({
      assignment: template.assignment({ name: 'Assignment 1', submission_types: ['discussion_topic'] }),
    })
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders null due date', () => {
    props.item = template.toDoModel({
      assignment: template.assignment({ due_at: null }),
    })
    const tree = shallow(<ToDoListItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('passes the item to onPress', () => {
    const tree = shallow(<ToDoListItem {...props} />)
    tree.find('Row').simulate('Press')
    expect(props.onPress).toHaveBeenCalledWith(props.item)
  })
})
