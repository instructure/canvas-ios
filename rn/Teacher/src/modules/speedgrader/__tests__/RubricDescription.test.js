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

// @flow

import React from 'react'
import { RubricDescription, mapStateToProps } from '../RubricDescription'
import renderer from 'react-test-renderer'

jest.unmock('ScrollView')

const templates = {
  ...require('../../../__templates__/helm'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/rubric'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/session'),
}

let ownProps = {
  assignmentID: '1',
  rubricID: '1',
  navigator: templates.navigator(),
}

let defaultProps = {
  ...ownProps,
  description: 'A satisfactory description',
}

describe('RubricDescription', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <RubricDescription {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders without description', () => {
    let props = {
      ...defaultProps,
      description: null,
    }
    let tree = renderer.create(
      <RubricDescription {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('returns an empty description when there is no rubric', () => {
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: templates.assignment({
              id: '1',
            }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.description).toEqual('')
  })

  it('returns the rubric description whent here is a rubric', () => {
    let rubric = templates.rubric({ id: '1' })
    let state = templates.appState({
      entities: {
        assignments: {
          '1': {
            data: templates.assignment({
              id: '1',
              rubric: [rubric],
            }),
          },
        },
      },
    })

    let props = mapStateToProps(state, ownProps)
    expect(props.description).toEqual(rubric.long_description)
  })
})
