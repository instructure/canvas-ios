/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionsList, mapStateToProps, type Props } from '../DiscussionsList'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('DiscussionsList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      discussions: [],
      navigator: template.navigator(),
      courseColor: null,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders discussions', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1' })
    const two = template.discussion({ id: '2', title: 'discussion 2' })
    props.discussions = [one, two]
    testRender(props)
  })

  it('renders discussions with no assignments', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1', assignment: null })
    const two = template.discussion({ id: '2', title: 'discussion 2', assignment: null })
    props.discussions = [one, two]
    testRender(props)
  })

  it('renders pinned discussions', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1', pinned: true })
    const two = template.discussion({ id: '2', title: 'discussion 2', locked: true })
    props.discussions = [one, two]
    testRender(props)
  })

  it('navigates to discussion', () => {
    const discussion = template.discussion({ id: '1' })
    props.discussions = [discussion]
    const tree = render(props).toJSON()

    const row: any = explore(tree).selectByID('discussion-row-0')
    row.props.onPress()

    expect(props.navigator.show).toHaveBeenCalledWith(discussion.html_url)
  })

  it('renders in correct order', () => {
    props.discussions = [
      template.discussion({ id: '1', title: 'First', due_at: '2118-03-28T15:07:56.312Z' }),
      template.discussion({ id: '2', title: 'Second', due_at: '2117-03-28T15:07:56.312Z' }),
    ]
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<DiscussionsList {...props} />)
  }
})

describe('map state to prop', () => {
  it('maps state to props', () => {
    const discussions = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
    ]
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            color: '#fff',
            course: {
              name: 'Foo',
            },
            discussions: {
              pending: 0,
              error: null,
              refs: ['1', '2'],
            },
          },
        },
        discussions: {
          '1': {
            data: discussions[0],
          },
          '2': {
            data: discussions[1],
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toMatchObject({
      discussions,
      courseColor: '#fff',
    })
  })
})
