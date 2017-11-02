/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import { ToDoListItem, mapStateToProps, type Props } from '../ToDoListItem'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/toDo'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('ToDoListItem', () => {
  let props: Props
  beforeEach(() => {
    props = {
      item: template.toDoItem(),
      courseName: 'React Native for Dummies',
      courseColor: '#000',
      index: 0,
      onPress: jest.fn(),
    }
  })

  it('renders', () => {
    props.courseColor = null
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders published assignment', () => {
    props.item = template.toDoItem({
      assignment: template.assignment({ name: 'Assignment 1', published: true }),
    })
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders unpublished assignment', () => {
    props.item = template.toDoItem({
      assignment: template.assignment({ name: 'Assignment 1', published: false }),
    })
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders quiz', () => {
    props.item = template.toDoItem({
      assignment: null,
      quiz: template.quiz({ title: 'Quiz 1' }),
    })
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders discussion', () => {
    props.item = template.toDoItem({
      assignment: template.assignment({ name: 'Assignment 1', submission_types: ['discussion_topic'] }),
    })
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders null due date', () => {
    props.item = template.toDoItem({
      assignment: template.assignment({ due_at: null }),
    })
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  function render (props: Props, options: any = {}): any {
    return renderer.create(<ToDoListItem {...props} />, options)
  }
})

describe('mapStateToProps', () => {
  it('maps course state to props', () => {
    const state = template.appState({
      entities: {
        courses: {
          '33': {
            color: '#111111',
            course: template.course({ name: 'Intro to JavaScript' }),
          },
        },
      },
    })
    const item = template.toDoItem({ course_id: '33' })
    const ownProps = { item, onPress: jest.fn(), index: 0 }
    expect(mapStateToProps(state, ownProps)).toEqual({
      courseName: 'Intro to JavaScript',
      courseColor: '#111111',
    })
  })
})
