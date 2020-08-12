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
      isSaving: false,
      loadError: null,
      saveError: null,
      refresh: jest.fn(),
      onPress: jest.fn(),
    }
  })

  it('gets courseColor and courseName from the model api', async () => {
    const courseColor = 'green'
    const course = template.courseModel()
    httpCache.handle('GET', 'users/self/colors', { custom_colors: { course_1: courseColor } })
    httpCache.handle('GET', 'courses/1', course)
    const tree = shallow(<Connected item={props.item} onPress={jest.fn()} />)
    tree.instance().api.cleanup()
    tree.instance().api.options.policy = 'cache-only'
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
