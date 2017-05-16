/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { QuizPreview, mapStateToProps } from '../QuizPreview'

jest.mock('WebView', () => 'WebView')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizPreview', () => {
  let props = {
    quiz: template.quiz(),
    navigator: template.navigator(),
  }

  it('renders', () => {
    testRender(props)
  })

  function testRender (props: any) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(
      <QuizPreview {...props} />
    )
  }
})

describe('QuizPreview mapStateToProps', () => {
  it('maps state to props', () => {
    const quiz = template.quiz({ id: '1' })
    const state: AppState = template.appState({
      entities: {
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: null,
          },
        },
      },
    })

    const result = mapStateToProps(state, { quizID: '1' })
    expect(result).toMatchObject({
      quiz,
    })
  })
})
