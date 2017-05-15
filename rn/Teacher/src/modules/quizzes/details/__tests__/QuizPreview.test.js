/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import cloneDeep from 'lodash/cloneDeep'

import { QuizPreview, mapStateToProps } from '../QuizPreview'

jest.mock('WebView', () => 'WebView')

const template = {
  ...require('../../../../__templates__/react-native-navigation'),
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

  it('calls navigation functions', () => {
    const ownProps = cloneDeep(props)
    const dismissModal = jest.fn()
    ownProps.navigator = template.navigator({
      dismissModal,
    })
    const preview = render(ownProps)
    preview.getInstance().onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'dismiss',
    })

    expect(dismissModal).toHaveBeenCalled()
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
