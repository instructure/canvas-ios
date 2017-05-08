/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { QuizzesList, mapStateToProps, type Props } from '../QuizzesList'
import { route } from '../../../../routing'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing')

const template = {
  ...require('../../../../__templates__/react-native-navigation'),
  ...require('../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizzesList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      quizzes: [],
      navigator: template.navigator(),
      courseColor: null,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders quizzes', () => {
    const one = template.quiz({ id: '1', title: 'Quiz 1' })
    const two = template.quiz({ id: '2', title: 'Quiz 2' })
    props.quizzes = [one, two]
    testRender(props)
  })

  it('navigates to quiz', () => {
    const quiz = template.quiz({ id: '1' })
    props.quizzes = [quiz]
    const tree = render(props).toJSON()

    const row: any = explore(tree).selectByID('quiz-row-0')
    row.props.onPress()

    const expectedDestination = route(quiz.html_url)
    expect(props.navigator.push).toHaveBeenCalledWith(expectedDestination)
  })

  it('renders in correct order', () => {
    props.quizzes = [
      template.quiz({ id: '1', title: 'First', due_at: '2118-03-28T15:07:56.312Z' }),
      template.quiz({ id: '2', title: 'Second', due_at: '2117-03-28T15:07:56.312Z' }),
    ]
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<QuizzesList {...props} />)
  }
})

describe('map state to prop', () => {
  it('maps state to props', () => {
    const quizzes = [
      template.quiz({ id: '1' }),
      template.quiz({ id: '2' }),
    ]
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            color: '#fff',
            quizzes: {
              pending: 0,
              error: null,
              refs: ['1', '2'],
            },
          },
        },
        quizzes: {
          '1': {
            data: quizzes[0],
          },
          '2': {
            data: quizzes[1],
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toMatchObject({
      quizzes,
      courseColor: '#fff',
    })
  })
})
