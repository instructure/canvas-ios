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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import QuizRow, { type Props } from '../QuizRow'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/quiz'),
}

describe('QuizRow', () => {
  let props
  beforeEach(() => {
    props = {
      quiz: template.quiz(),
      onPress: jest.fn(),
      index: 0,
      tintColor: '#fff',
      selected: false,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders published', () => {
    props.quiz.published = true
    testRender(props)
  })

  it('renders unpublished', () => {
    props.quiz.published = false
    testRender(props)
  })

  it('renders selected', () => {
    props.selected = true
    testRender(props)
  })

  it('sends onPress', () => {
    const tree = render(props).toJSON()
    const row: any = explore(tree).selectByID('quiz-row-0')
    row.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith(props.quiz)
  })

  it('renders multiple question count', () => {
    props.quiz.question_count = 144
    testRender(props)
  })

  it('renders single question count', () => {
    props.quiz.question_count = 1
    testRender(props)
  })

  it('renders without points possible', () => {
    props.quiz.points_possible = null
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<QuizRow {...props} />)
  }
})
