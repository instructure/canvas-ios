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
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('renders on error', () => {
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    const instance = tree.getInstance()
    instance.onError()
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('renders on timeout', () => {
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    const instance = tree.getInstance()
    instance.onTimeout()
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('renders on timeout without actually timing out', () => {
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    const instance = tree.getInstance()
    instance.onMessage({
      nativeEvent: { data: 'done' },
    })
    instance.onTimeout()
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('renders on finish', () => {
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    const instance = tree.getInstance()
    instance.webView = {
      injectJavaScript: jest.fn(),
    }
    instance.onLoadEnd()
    expect(instance.webView.injectJavaScript).toHaveBeenCalled()
    instance.onMessage({
      nativeEvent: { data: 'done' },
    })
    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('renders error if needed', () => {
    const tree = renderer.create(
      <QuizPreview {...props} />
    )
    const instance = tree.getInstance()
    instance.webView = {
      injectJavaScript: jest.fn(),
    }
    instance.onLoadEnd()
    expect(instance.webView.injectJavaScript).toHaveBeenCalled()
    instance.onMessage({
      nativeEvent: { data: '' },
    })
    expect(tree.toJSON()).toMatchSnapshot()
    instance.onMessage({
      nativeEvent: { data: 'error' },
    })
    expect(tree.toJSON()).toMatchSnapshot()
  })
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
