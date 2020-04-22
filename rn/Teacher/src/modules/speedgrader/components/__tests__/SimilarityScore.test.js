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
import { SimilarityScore, type Props, mapStateToProps } from '../SimilarityScore'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('SimilarityScore', () => {
  let props: Props
  beforeEach(() => {
    props = {
      score: 0,
      status: 'scored',
      url: null,
    }
  })

  it('displays label', () => {
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('speedgrader.similarity-score.label')
    expect(label.children).toContain('Similarity Score')
  })

  it('displays score', () => {
    props.score = 20
    const score: any = explore(render(props).toJSON()).selectByID('speedgrader.similarity-score.score.label')
    expect(score.children).toContain('20%')
  })

  it('uses the correct color depending on the score', () => {
    testScoreColor(0)
    testScoreColor(1)
    testScoreColor(25)
    testScoreColor(50)
    testScoreColor(75)
    testScoreColor(100)
  })

  it('displays disclosure indicator if there is a url', () => {
    props.url = 'some url'
    expect(explore(render(props).toJSON()).selectByType('DisclosureIndicator')).not.toBeNull()
  })

  it('renders null without a status', () => {
    props.status = null
    expect(render(props).toJSON()).toBeNull()
  })

  it('renders pending status', () => {
    props.status = 'pending'
    const status: any = explore(render(props).toJSON()).selectByID('speedgrader.similarity-score.status.container')
    expect(status).toMatchSnapshot()
  })

  it('renders error status', () => {
    props.status = 'error'
    const status: any = explore(render(props).toJSON()).selectByID('speedgrader.similarity-score.status.container')
    expect(status).toMatchSnapshot()
  })

  function render (props: Props): any {
    return renderer.create(<SimilarityScore {...props} />)
  }

  function testScoreColor (score: number) {
    props.score = score
    const container: any = explore(render(props).toJSON()).selectByID('speedgrader.similarity-score.score.container')
    expect(container.props.style).toMatchSnapshot()
  }
})

describe('mapStateToProps', () => {
  it('maps text submission to props', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '1': {
            submission: template.submissionHistory([{
              id: '1',
              submission_type: 'online_text_entry',
              turnitin_data: {
                submission_1: {
                  status: 'scored',
                  similarity_score: 20,
                  outcome_response: {
                    outcomes_tool_placement_url: 'https://some-site-at-turnitin.com',
                  },
                },
              },
            }]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '1' })
    ).toEqual({
      score: 20,
      status: 'scored',
      url: 'https://some-site-at-turnitin.com',
    })
  })

  it('maps file submission to props', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '1': {
            submission: template.submissionHistory([{
              id: '1',
              submission_type: 'online_upload',
              attachments: [{
                id: '2',
              }],
              turnitin_data: {
                attachment_2: {
                  status: 'scored',
                  similarity_score: 20,
                },
              },
            }]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '1' })
    ).toEqual({
      score: 20,
      status: 'scored',
      url: null,
    })
  })

  it('maps selected submission and selected attachment to props', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '2': {
            selectedIndex: 0,
            selectedAttachmentIndex: 1,
            submission: template.submissionHistory([
              {
                id: '1',
                submission_type: 'online_upload',
                attachments: [
                  {
                    id: '1',
                  },
                  {
                    id: '2',
                  },
                  {
                    id: '3',
                  },
                ],
                turnitin_data: {
                  attachment_1: {
                    status: 'scored',
                    similarity_score: 10,
                  },
                  attachment_2: {
                    status: 'scored',
                    similarity_score: 20,
                  },
                  attachment_3: {
                    status: 'scored',
                    similarity_score: 30,
                  },
                },
              },
              {
                id: '2',
              },
            ]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '2' })
    ).toEqual({
      status: 'scored',
      score: 20,
      url: null,
    })
  })

  it('handles no submission id', () => {
    expect(
      mapStateToProps(template.appState(), { submissionID: null })
    ).toEqual({
      status: null,
      url: null,
      score: null,
    })
  })

  it('handles no turnitin data', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '1': {
            submission: template.submissionHistory([{
              id: '1',
              turnitin_data: undefined,
            }]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '1' })
    ).toEqual({
      status: null,
      url: null,
      score: null,
    })
  })

  it('handles submission types not supported by turnitin', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '1': {
            submission: template.submissionHistory([{
              id: '1',
              submission_type: 'online_url',
              turnitin_data: {
                submission_1: {
                  status: 'scored',
                  similarity_score: 20,
                },
              },
            }]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '1' })
    ).toEqual({
      status: null,
      url: null,
      score: null,
    })
  })

  it('handles uploads without attachments', () => {
    const state = template.appState({
      entities: {
        submissions: {
          '1': {
            submission: template.submissionHistory([{
              id: '1',
              submission_type: 'online_upload',
              attachments: [],
              turnitin_data: {
                attachment_1: {
                  status: 'scored',
                  similarity_score: 20,
                },
              },
            }]),
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { submissionID: '1' })
    ).toEqual({
      status: null,
      url: null,
      score: null,
    })
  })
})
