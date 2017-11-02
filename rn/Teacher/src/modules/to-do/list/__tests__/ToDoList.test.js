/* @flow */

import React from 'react'
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import { ToDoList, mapStateToProps, type Props } from '../ToDoList'
import { ERROR_TITLE } from '../../../../redux/middleware/error-handler'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../ToDoListItem', () => 'ToDoListItem')

const template = {
  ...require('../../../../__templates__/toDo'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/error'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('ToDoList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      navigator: template.navigator(),
      items: [template.toDoItem()],
      getToDo: jest.fn(() => Promise.resolve({ data: [template.toDoItem()] })),
      refreshedToDo: jest.fn(),
    }
  })

  it('renders items', () => {
    props.items = [template.toDoItem()]
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('refreshes on mount', async () => {
    const spy = jest.fn(() => Promise.resolve({ data: [template.toDoItem()] }))
    props.getToDo = spy
    const view = render(props)
    await view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalled()
  })

  it('dispatches refreshedToDo on refresh', async () => {
    const spy = jest.fn()
    props.refreshedToDo = spy
    const data = [template.toDoItem()]
    props.getToDo = jest.fn(() => Promise.resolve({ data }))
    const view = render(props)
    const list: any = explore(view.toJSON()).selectByType('RCTScrollView')
    await list.props.onRefresh()
    expect(spy).toHaveBeenCalledWith(data)
  })

  it('alerts refresh error', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.getToDo = jest.fn(() => Promise.reject(template.error('ERROR')))
    const view = render(props)
    const list: any = explore(view.toJSON()).selectByType('RCTScrollView')
    await list.props.onRefresh()
    expect(spy).toHaveBeenCalledWith(ERROR_TITLE, 'ERROR')
  })

  it('shows Speed Grader on assignment press', () => {
    const spy = jest.fn()
    props.navigator = template.navigator({ show: spy })
    props.items = [template.toDoItem({
      course_id: '222',
      assignment: template.assignment({ id: '1' }),
    })]
    const view = render(props)
    const row: any = explore(view.toJSON()).selectByType('ToDoListItem')
    row.props.onPress()
    expect(spy).toHaveBeenCalledWith(
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
    const spy = jest.fn()
    props.navigator = template.navigator({ show: spy })
    props.items = [template.toDoItem({
      course_id: '222',
      quiz: template.quiz({ id: '2', assignment_id: '1' }),
    })]
    const view = render(props)
    const row: any = explore(view.toJSON()).selectByType('ToDoListItem')
    row.props.onPress()
    expect(spy).toHaveBeenCalledWith(
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

  function render (props: Props, options: any = {}): any {
    return renderer.create(<ToDoList {...props} />, options)
  }
})

describe('mapStateToProps', () => {
  it('uses counts directly from toDo entities if there are no submissions', () => {
    const items = [template.toDoItem({ assignment: template.assignment() })]
    const state = template.appState({
      toDo: { items },
      entities: {
        assignments: {},
      },
    })
    expect(mapStateToProps(state)).toEqual({ items })
  })

  it('uses submissions to determine needs_grading_count', () => {
    const assignment = template.assignment({ id: '1' })
    const ungraded = template.submission({
      id: '1',
      workflow_state: 'submitted',
    })
    const graded = template.submission({
      id: '2',
      workflow_state: 'graded',
    })
    const staleItem = template.toDoItem({
      assignment,
      needs_grading_count: 2,
    })
    const state = template.appState({
      toDo: { items: [staleItem] },
      entities: {
        assignments: {
          '1': {
            data: assignment,
            submissions: {
              pending: 0,
              refs: [ungraded.id, graded.id],
            },
          },
        },
        submissions: {
          [ungraded.id]: {
            submission: ungraded,
          },
          [graded.id]: {
            submission: graded,
          },
        },
      },
    })
    expect(mapStateToProps(state)).toEqual({
      items: [{ ...staleItem, needs_grading_count: 1 }],
    })
  })

  it('it does not include recently graded submissions', () => {
    const quiz = template.quiz({ id: '1' })
    const s1 = template.submission({
      id: '1',
      workflow_state: 'submitted',
    })
    const s2 = template.submission({
      id: '2',
      workflow_state: 'submitted',
    })
    const staleItem = template.toDoItem({
      quiz,
      needs_grading_count: 2,
    })
    const state = template.appState({
      toDo: { items: [staleItem] },
      entities: {
        quizzes: {
          '1': {
            data: quiz,
            submissions: {
              pending: 0,
              refs: [s1.id, s2.id],
            },
          },
        },
        submissions: {
          [s1.id]: {
            submission: s1,
          },
          [s2.id]: {
            submission: s2,
            lastGradedAt: new Date(Date.now() - 60000).getTime(), // 1 minute ago
          },
        },
      },
    })
    expect(mapStateToProps(state)).toEqual({
      items: [{ ...staleItem, needs_grading_count: 1 }],
    })
  })
})
