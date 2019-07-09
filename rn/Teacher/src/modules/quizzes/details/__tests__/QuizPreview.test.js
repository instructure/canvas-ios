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
