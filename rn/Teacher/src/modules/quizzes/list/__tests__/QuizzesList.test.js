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
import 'react-native'
import renderer from 'react-test-renderer'

import { QuizzesList, mapStateToProps, type Props } from '../QuizzesList'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizzesList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      pending: false,
      refreshing: false,
      quizzes: [],
      navigator: template.navigator(),
      courseColor: null,
      updateCourseDetailsSelectedTabSelectedRow: jest.fn(),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders the activity indicator when loading', () => {
    testRender({
      ...props,
      pending: true,
    })
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

    expect(props.navigator.show).toHaveBeenCalledWith(quiz.html_url)
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

  it('selects first item on regular horizontal trait collection', () => {
    props.quizzes = [
      template.quiz({ id: '1', title: 'First', due_at: '2118-03-28T15:07:56.312Z' }),
      template.quiz({ id: '2', title: 'Second', due_at: '2117-03-28T15:07:56.312Z' }),
    ]
    let tree = renderer.create(
      <QuizzesList {...props} />
    )

    let instance = tree.getInstance()
    instance.didSelectFirstItem = false
    instance.isRegularScreenDisplayMode = true
    let quiz = instance.data[0].data[0]
    instance._selectedQuiz = jest.fn()
    instance.selectFirstListItemIfNecessary()

    expect(instance._selectedQuiz).toHaveBeenCalledWith(quiz)
    expect(instance.didSelectFirstItem).toBe(true)
  })

  it('detects trait collection change', () => {
    let tree = renderer.create(
      <QuizzesList {...props} />
    )

    let instance = tree.getInstance()
    let traits = { 'window': { 'horizontal': 'regular' } }
    instance.selectFirstListItemIfNecessary = jest.fn()
    instance.traitCollectionDidChange(traits)

    expect(instance.selectFirstListItemIfNecessary).toHaveBeenCalled()
  })
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
            course: {
              name: 'Foo',
            },
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
