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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import QuizRow, { type Props } from '../QuizRow'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

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
