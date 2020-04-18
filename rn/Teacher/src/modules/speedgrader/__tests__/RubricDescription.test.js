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

// @flow

import React from 'react'
import { RubricDescription, mapStateToProps } from '../RubricDescription'
import renderer from 'react-test-renderer'

jest.unmock('react-native/Libraries/Components/ScrollView/ScrollView')

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
  beforeEach(() => jest.clearAllMocks())

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
