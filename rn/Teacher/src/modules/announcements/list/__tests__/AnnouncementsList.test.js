/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { AnnouncementsList, type Props, mapStateToProps } from '../AnnouncementsList'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')

describe('AnnouncementsList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      courseID: '1',
      refreshing: false,
      refresh: jest.fn(),
      pending: 0,
      error: null,
      navigator: template.navigator(),
      announcements: [
        template.discussion({
          id: '1',
          title: 'Untitled',
          posted_at: '2013-11-14T16:55:00-07:00',
        }),
        template.discussion({
          id: '2',
          title: 'Getting Started in Biology 101',
          posted_at: '2013-10-28T14:16:00-07:00',
        }),
      ],
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('navigates to new announcement', () => {
    props.navigator.show = jest.fn()
    props.courseID = '2'
    tapAdd(render(props))
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/2/announcements/new',
      { modal: true },
    )
  })

  it('navigates to announcement when row tapped', () => {
    const announcement = template.discussion({ html_url: 'https://canvas.instructure.com/courses/1/discussions/2' })
    props.navigator.show = jest.fn()
    props.announcements = [announcement]
    const row: any = explore(render(props).toJSON()).selectByID('announcements.list.announcement.row-0')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(announcement.html_url, { modal: false }, {
      isAnnouncement: true,
    })
  })

  function testRender (props: any) {
    expect(render(props)).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(<AnnouncementsList {...props} />)
  }

  function tapAdd (component: any) {
    const addBtn: any = explore(component.toJSON()).selectRightBarButton('announcements.list.addButton')
    addBtn.action()
  }
})

describe('mapStateToProps', () => {
  it('maps course announcement refs to props', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const three = template.discussion({ id: '3' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '3'],
            },
            course: {
              name: 'CS 1010',
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
          '3': {
            data: three,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toEqual({
      announcements: [one, three],
      pending: 1,
      courseName: 'CS 1010',
      error: null,
    })
  })

  it('maps empty state', () => {
    const state = template.appState({
      entities: {},
    })
    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toEqual({
      announcements: [],
      courseName: '',
      pending: 0,
      error: null,
    })
  })

  it('maps without course', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const three = template.discussion({ id: '3' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '3'],
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
          '3': {
            data: three,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toEqual({
      announcements: [one, three],
      pending: 1,
      courseName: '',
      error: null,
    })
  })
})
