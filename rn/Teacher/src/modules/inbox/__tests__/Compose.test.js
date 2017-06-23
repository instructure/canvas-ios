// @flow

import React from 'react'
import { Compose } from '../Compose'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

let template = {
  ...require('../../../__templates__/helm'),
  ...require('../../../api/canvas-api/__templates__/addressBook'),
  ...require('../../../api/canvas-api/__templates__/course'),
}

let defaultProps = {
  navigator: template.navigator({
    dismiss: jest.fn(),
  }),
  refreshInboxSent: jest.fn(),
}

jest
  .mock('LayoutAnimation', () => ({
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))
.mock('TouchableOpacity', () => 'TouchableOpacity')

describe('Compose', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with passed in recipients', () => {
    const u1 = template.addressBookResult({
      id: '1',
    })
    const u2 = template.addressBookResult({
      id: '2',
    })

    let tree = renderer.create(
      <Compose {...defaultProps} recipients={[u1, u2]} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders after picking a course', () => {
    let course = template.course()
    let onSelect = jest.fn()
    const show = jest.fn((path, options, passthrough) => {
      onSelect = passthrough.onSelect
    })

    const navigator = template.navigator({ show, dismiss: jest.fn() })
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )

    component.getInstance().selectCourse()
    onSelect(course)
    expect(navigator.dismiss).toHaveBeenCalled()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('sets all the data and then send the message', () => {
    let course = template.course()
    const recipient = template.addressBookResult()
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )
    const instance = component.getInstance()
    instance._bodyChanged('body of the message')
    instance._subjectChanged('subject of the message')
    instance.setStateAndUpdate({ course })
    instance.setStateAndUpdate({ recipients: [recipient] })
    expect(instance.state.sendDisabled).toEqual(false)
  })

  it('gets and sets recipients', () => {
    const recipient = template.addressBookResult()
    let onSelect = jest.fn()
    let onCancel = jest.fn()
    const show = jest.fn((path, options, passthrough) => {
      onSelect = passthrough.onSelect
      onCancel = passthrough.onCancel
    })

    const navigator = template.navigator({ show, dismiss: jest.fn() })
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )

    component.getInstance().selectCourse()
    onSelect(template.course())
    component.getInstance()._openAddressBook()
    onSelect([recipient])
    expect(navigator.dismiss).toHaveBeenCalled()
    expect(component.getInstance().state.recipients).toEqual([recipient])
    onCancel()
    expect(navigator.dismiss).toHaveBeenCalled()
  })

  it('dismisses the modal when cancel is pressed', () => {
    let instance = renderer.create(
      <Compose {...defaultProps} />
    ).getInstance()

    instance.cancelCompose()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('toggles the send to all', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('compose-message.send-all-toggle') || {}
    toggle.props.onValueChange(true)

    expect(tree.getInstance().state.sendToAll).toBeTruthy()
  })

  it('deletes a recipient from state', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    )
    let instance = tree.getInstance()

    instance.setState({
      recipients: [
        {
          id: '1',
          name: 'Donald Trump',
        },
      ],
    })

    instance._deleteRecipient('1')

    expect(instance.state.recipients.length).toBe(0)
  })
})
