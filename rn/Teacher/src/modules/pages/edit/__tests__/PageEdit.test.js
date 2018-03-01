/* @flow */

import React from 'react'
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import { PageEdit, mapStateToProps, type Props } from '../PageEdit'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('Switch', () => 'Switch')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')
  .mock('../../../../common/components/rich-text-editor/RichTextEditor', () => 'RichTextEditor')
  .mock('../../../../common/components/SavingBanner', () => 'SavingBanner')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/page'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('PageEdit', () => {
  let props: Props
  beforeEach(() => {
    props = {
      courseID: '1',
      url: null,
      title: null,
      body: null,
      editing_roles: 'teachers',
      published: false,
      front_page: false,
      createPage: jest.fn(),
      updatePage: jest.fn(),
      refreshedPage: jest.fn(),
      deletedPage: jest.fn(),
      navigator: template.navigator(),
    }
  })

  it('renders', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  describe('front page edit', () => {
    beforeEach(() => {
      props.url = 'page-1'
      props.front_page = true
    })

    it('hides front page switch', () => {
      const view = render(props)
      const row: any = explore(view.toJSON()).selectByID('pages.edit.front_page.row')
      expect(row).toBeFalsy()
    })

    it('hides published switch', () => {
      const view = render(props)
      const row: any = explore(view.toJSON()).selectByID('pages.edit.published.row')
      expect(row).toBeFalsy()
    })
  })

  it('can edit front page if published', () => {
    const view = render(props)
    changePublished(view, true)
    const option = explore(view.toJSON()).selectByID('pages.edit.front_page.row')
    expect(option).toBeTruthy()
  })

  it('can edit published', () => {
    const view = render(props)
    const option = explore(view.toJSON()).selectByID('pages.edit.published.row')
    expect(option).toBeTruthy()
  })

  it('creates new page with values', async () => {
    const spy = jest.fn()
    props.createPage = spy
    props.courseID = '1'
    props.url = null
    props.title = null
    props.body = null
    props.editing_roles = 'teachers'
    props.published = false
    props.front_page = false

    const view = render(props)
    changeTitle(view, 'Page 1')
    changeBody(view, 'This is the body')
    changeEditingRoles(view, 'public')
    changePublished(view, true)
    changeFrontPage(view, true)
    await tapDone(view)

    expect(spy).toHaveBeenCalledWith('1', {
      title: 'Page 1',
      body: 'This is the body',
      editing_roles: 'public',
      published: true,
      front_page: true,
    })
  })

  it('updates page with values', async () => {
    const spy = jest.fn()
    props.updatePage = spy
    props.url = 'page-1'
    props.title = 'Page 1'

    const view = render(props)
    changeTitle(view, 'Page 1 (Edited)')
    await tapDone(view)

    expect(spy).toHaveBeenCalledWith('1', 'page-1', {
      title: 'Page 1 (Edited)',
      body: null,
      editing_roles: 'teachers',
      published: false,
      front_page: false,
    })
  })

  it('publishes page if front page', async () => {
    const spy = jest.fn()
    props.updatePage = spy
    props.front_page = false
    props.published = false
    props.url = 'page-1'

    const view = render(props)
    changePublished(view, true)
    changeFrontPage(view, true)
    await tapDone(view)

    expect(spy).toHaveBeenCalledWith('1', 'page-1', {
      title: props.title,
      body: props.body,
      editing_roles: props.editing_roles,
      published: true,
      front_page: true,
    })
  })

  it('dispatches refreshedPage action on Done', async () => {
    const spy = jest.fn()
    props.refreshedPage = spy
    props.url = 'page-1'
    props.updatePage = jest.fn(() => Promise.resolve({ data: 'it worked!' }))
    const view = render(props)
    await tapDone(view)
    expect(spy).toHaveBeenCalledWith('it worked!', props.courseID)
  })

  it('alerts save errors', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.createPage = jest.fn(() => Promise.reject(new Error('title cant be blank')))
    const view = render(props)
    await tapDone(view)
    expect(spy).toHaveBeenCalled()
  })

  it('shows SavingBanner while saving', async () => {
    const view = render(props)
    props.createPage = jest.fn(() => {
      banner = explore(view.toJSON()).selectByType('SavingBanner')
      return Promise.resolve({ data: 'yay' })
    })
    view.update(<PageEdit {...props} />)

    let banner = explore(view.toJSON()).selectByType('SavingBanner')
    expect(banner).toBeFalsy()
    await tapDone(view)
    expect(banner).toBeTruthy()
  })

  it('dismisses on Done', async () => {
    const spy = jest.fn()
    props.navigator = template.navigator({ dismiss: spy })
    props.createPage = jest.fn(() => Promise.resolve({ data: 'yay' }))
    const view = render(props)
    await tapDone(view)
    expect(spy).toHaveBeenCalled()
  })

  function render (props: Props, options: any) {
    return renderer.create(<PageEdit {...props} />, options)
  }

  function changeTitle (view: any, title: string) {
    const input: any = explore(view.toJSON()).selectByID('pages.edit.titleInput')
    input.props.onChangeText(title)
  }

  function changeBody (view: any, body: string) {
    const editor: any = explore(view.toJSON()).selectByType('RichTextEditor')
    editor.props.onChangeValue(body)
  }

  function changeFrontPage (view: any, frontPage: boolean) {
    const toggle: any = explore(view.toJSON()).selectByID('pages.edit.front_page.switch')
    toggle.props.onValueChange(frontPage)
  }

  function changeEditingRoles (view: any, roles: string) {
    const row: any = explore(view.toJSON()).selectByID('pages.edit.editing_roles.row')
    row.props.onPress()
    const picker: any = explore(view.toJSON()).selectByID('pages.edit.editing_roles.picker')
    picker.props.onValueChange(roles)
  }

  function changePublished (view: any, published: boolean) {
    const toggle: any = explore(view.toJSON()).selectByID('pages.edit.published.switch')
    toggle.props.onValueChange(published)
  }

  async function tapDone (view: any) {
    const done: any = explore(view.toJSON()).selectRightBarButton('pages.edit.doneButton')
    await done.action()
  }
})

describe('mapStateToProps', () => {
  it('maps new page props', () => {
    const state = template.appState()
    expect(mapStateToProps(state, { courseID: '1', url: null })).toEqual({
      title: undefined,
      body: undefined,
      editing_roles: 'teachers',
      published: false,
      front_page: false,
    })
  })

  it('maps edit page props', () => {
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            pages: {
              refs: ['1'],
            },
          },
        },
        pages: {
          '1': {
            data: template.page({
              id: '1',
              url: 'page-1',
              title: 'Winner',
              body: 'body',
              editing_roles: 'teachers,students',
              published: true,
              front_page: true,
            }),
          },
          '2': {
            data: template.page({ id: '2', url: 'page-1', title: 'Wrong' }),
          },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toEqual({
      title: 'Winner',
      body: 'body',
      editing_roles: 'students,teachers',
      published: true,
      front_page: true,
    })
  })

  it('maps public editing roles', () => {
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            pages: {
              refs: ['1'],
            },
          },
        },
        pages: {
          '1': {
            data: template.page({
              id: '1',
              url: 'page-1',
              editing_roles: 'public',
            }),
          },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toMatchObject({
      editing_roles: 'public',
    })
  })
})
