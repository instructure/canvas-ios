// @flow

import React, { Component } from 'react'
import { Text } from 'react-native'
import refresh from '../refresh'
import renderer from 'react-test-renderer'

describe('refresh', () => {
  it('renders the refreshed component', () => {
    let Refreshed = refresh(() => {}, () => true)(Text)
    let tree = renderer.create(
      <Refreshed testID='test'>This is text</Refreshed>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('has all the correct statics', () => {
    class C extends Component {
      static yo = 'asdf'
    }
    let Refreshed = refresh(() => {}, () => true)(C)

    expect(Refreshed.yo).toEqual('asdf')
  })

  it('calls the refresh function if should refresh returns true', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => true)(Text)
    renderer.create(
      <Refreshed>This is text</Refreshed>
    )
    expect(refreshFunction).toHaveBeenCalled()
  })

  it('doesnt call the refresh function if should refresh return false', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => false)(Text)
    renderer.create(
      <Refreshed>This is text</Refreshed>
    )
    expect(refreshFunction).not.toHaveBeenCalled()
  })

  it('passes in the refresh function as a prop to the underlying component', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => true)(Text)
    let tree = renderer.create(
      <Refreshed>This is text</Refreshed>
    ).toJSON()
    tree.props.refresh()
    expect(refreshFunction).toHaveBeenCalled()
  })
})
