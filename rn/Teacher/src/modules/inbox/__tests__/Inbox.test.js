/* @flow */
import 'react-native'
import React from 'react'
import { Inbox, handleRefresh, mapStateToProps, Refreshed } from '../Inbox.js'
import setProps from '../../../../test/helpers/setProps'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../api/canvas-api/__templates__/conversations'),
  ...require('../../../__templates__/helm'),
}

const c1 = template.conversation({
  id: '1',
})
const c2 = template.conversation({
  id: '2',
})

let defaultProps = {
  conversations: [c1, c2],
  refreshInboxAll: jest.fn(),
  scope: 'all',
  navigator: template.navigator({
    show: jest.fn(),
  }),
}

beforeEach(() => jest.resetAllMocks())

it('renders correctly', () => {
  const tree = renderer.create(
    <Inbox {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('doesnt call refresh function if there is no next function', () => {
  let instance = renderer.create(
    <Inbox {...defaultProps} />
  ).getInstance()

  expect(instance.getNextPage()).toBeFalsy()
  expect(defaultProps.refreshInboxAll).not.toHaveBeenCalled
})

it('calls the refresh function with next if next is present', () => {
  let next = jest.fn()
  let instance = renderer.create(
    <Inbox {...defaultProps} next={next} />
  ).getInstance()

  instance.getNextPage()
  expect(defaultProps.refreshInboxAll).toHaveBeenCalledWith(next)
})

it('renders with an empty state', () => {
  const tree = renderer.create(
    <Inbox {...defaultProps} conversations={[]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders the starred empty state', () => {
  const tree = renderer.create(
    <Inbox {...defaultProps} conversations={[]} scope='starred' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders the activity indicator when loading conversations', () => {
  const tree = renderer.create(
    <Inbox {...defaultProps} conversations={[]} pending={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('calls navigator.show when addMessage is called', () => {
  const instance = renderer.create(
    <Inbox {...defaultProps} />
  ).getInstance()

  instance.addMessage()
  expect(defaultProps.navigator.show).toHaveBeenCalledWith(
    '/conversations/compose',
    { modal: true, modalPresentationStyle: 'fullscreen' }
  )
})

it('mapStateToProps', () => {
  const c1 = template.conversation({
    id: '1',
  })
  const c2 = template.conversation({
    id: '2',
  })
  const appState = {
    inbox: {
      conversations: {
        '1': c1,
        '2': c2,
      },
      selectedScope: 'all',
      all: { refs: [c1.id, c2.id] },
    },
  }

  const results = mapStateToProps(appState)
  expect(results).toMatchObject({
    conversations: [c1, c2],
  })
})

it('_onChangeFilter', () => {
  const updateInboxSelectedScope = jest.fn()
  const instance = renderer.create(
    <Inbox conversations={[]} updateInboxSelectedScope={updateInboxSelectedScope} />
  ).getInstance()
  instance._onChangeFilter()
  expect(updateInboxSelectedScope).toHaveBeenCalled()
})

it('updates on scope change', () => {
  const tree = renderer.create(
    <Inbox conversations={[]} scope='all' />
  )

  let props = {
    scope: 'unread',
    refreshInboxUnread: jest.fn(),
  }

  setProps(tree, props)
  expect(props.refreshInboxUnread).toHaveBeenCalled()

  props = {
    scope: 'unread',
    refreshInboxUnread: jest.fn(),
  }

  setProps(tree, props)
  expect(props.refreshInboxUnread).not.toHaveBeenCalled()
})

it('refreshed component', () => {
  const props = {
    conversations: [],
    refreshInboxAll: jest.fn(),
    scope: 'all',
  }

  const tree = renderer.create(
    <Refreshed {...props} />
  )
  expect(tree.toJSON()).toMatchSnapshot()
  tree.getInstance().refresh()
  setProps(tree, props)
  expect(props.refreshInboxAll).toHaveBeenCalled()
})

it('should call the right functions in handleRefresh', () => {
  let props = {
    refreshInboxAll: jest.fn(),
    scope: 'all',
  }
  handleRefresh(props)
  expect(props.refreshInboxAll).toHaveBeenCalled()

  props = {
    refreshInboxUnread: jest.fn(),
    scope: 'unread',
  }
  handleRefresh(props)
  expect(props.refreshInboxUnread).toHaveBeenCalled()

  props = {
    refreshInboxStarred: jest.fn(),
    scope: 'starred',
  }
  handleRefresh(props)
  expect(props.refreshInboxStarred).toHaveBeenCalled()

  props = {
    refreshInboxSent: jest.fn(),
    scope: 'sent',
  }
  handleRefresh(props)
  expect(props.refreshInboxSent).toHaveBeenCalled()

  props = {
    refreshInboxArchived: jest.fn(),
    scope: 'archived',
  }
  handleRefresh(props)
  expect(props.refreshInboxArchived).toHaveBeenCalled()
})
