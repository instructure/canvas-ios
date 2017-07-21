/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import LinkModal from '../LinkModal'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')

const defaultProps = {
  visible: true,
  linkUpdated: jest.fn(),
  linkCreated: jest.fn(),
  onCancel: jest.fn(),
}

describe('LinkModal', () => {
  it('renders', () => {
    expect(
      renderer.create(
        <LinkModal {...defaultProps} />
      )
    ).toMatchSnapshot()
  })

  it('triggers link created', () => {
    const props = {
      ...defaultProps,
      title: null,
      url: null,
      linkCreated: jest.fn(),
    }
    const component = renderer.create(
      <LinkModal {...props} />
    )

    fill(component, 'title created', 'url created')
    pressOK(component)

    expect(props.linkCreated).toHaveBeenCalledWith('http://url created', 'title created')
  })

  it('triggers link updated', () => {
    const props = {
      ...defaultProps,
      title: 'Google',
      url: 'http://google.com',
      linkUpdated: jest.fn(),
    }
    const component = renderer.create(
      <LinkModal {...props} />
    )

    fill(component, 'Googley Goo')
    pressOK(component)

    expect(props.linkUpdated).toHaveBeenCalledWith('http://google.com', 'Googley Goo')
  })

  it('triggers on press cancel', () => {
    const onCancel = jest.fn()
    const tree = renderer.create(
      <LinkModal {...defaultProps} onCancel={onCancel} />
    ).toJSON()

    const cancel: any = explore(tree).selectByID('rich-text-editor.link-modal.cancelButton')
    cancel.props.onPress()

    expect(onCancel).toHaveBeenCalled()
  })

  function fill (component: any, title: ?string, url: ?string) {
    if (title) {
      const titleInput: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.titleInput')
      titleInput.props.onChangeText(title)
    }

    if (url) {
      const urlInput: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.urlInput')
      urlInput.props.onChangeText(url)
    }
  }

  function pressOK (component: any) {
    const ok: any = explore(component.toJSON()).selectByID('rich-text-editor.link-modal.okButton')
    ok.props.onPress()
  }
})
