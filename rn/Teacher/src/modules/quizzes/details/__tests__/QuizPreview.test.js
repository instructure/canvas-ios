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

import { QuizPreview, mapStateToProps } from '../QuizPreview'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/quiz'),
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
      body: 'done',
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
      body: 'done',
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
      body: '',
    })
    expect(tree.toJSON()).toMatchSnapshot()
    instance.onMessage({
      body: 'error',
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
