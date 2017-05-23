// @flow

import React, { Component } from 'react'
import { Text } from 'react-native'
import refresh from '../refresh'
import renderer from 'react-test-renderer'
import setProps from '../../../test/helpers/setProps'

describe('refresh', () => {
  it('renders the refreshed component', () => {
    let Refreshed = refresh(() => {}, () => true, () => false)(Text)
    let tree = renderer.create(
      <Refreshed testID='test'>This is text</Refreshed>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('has all the correct statics', () => {
    class C extends Component {
      static yo = 'asdf'
    }
    let Refreshed = refresh(() => {}, () => true, () => false)(C)

    expect(Refreshed.yo).toEqual('asdf')
  })

  it('calls the refresh function if should refresh returns true', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => true, () => false)(Text)
    renderer.create(
      <Refreshed>This is text</Refreshed>
    )
    expect(refreshFunction).toHaveBeenCalled()
  })

  it('doesnt call the refresh function if should refresh return false', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => false, () => false)(Text)
    renderer.create(
      <Refreshed>This is text</Refreshed>
    )
    expect(refreshFunction).not.toHaveBeenCalled()
  })

  it('passes in the refresh function as a prop to the underlying component', () => {
    let refreshFunction = jest.fn()
    let Refreshed = refresh(refreshFunction, () => true, () => false)(Text)
    let tree = renderer.create(
      <Refreshed>This is text</Refreshed>
    ).toJSON()
    tree.props.refresh()
    expect(refreshFunction).toHaveBeenCalled()
  })

  it('can be refreshed', async () => {
    let pending = 0
    let fetchData = jest.fn((props) => {
      pending = 1
    })
    let Refreshed = refresh(fetchData, () => false, () => Boolean(pending))(Text)

    let component = renderer.create(
      <Refreshed>Some moar text</Refreshed>
    )

    let tree = component.toJSON()
    expect(tree).toMatchSnapshot()

    tree.props.refresh()
    expect(fetchData).toHaveBeenCalled()

    tree = component.toJSON()
    expect(tree).toMatchSnapshot()

    setProps(component, { pending: 0 })
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()

    component.getInstance().setState({
      refreshing: false,
    })
    setProps(component, { pending: 0 })
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()
  })
})
