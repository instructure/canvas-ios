//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */
import 'react-native'
import React from 'react'
import { AddressBook, mapStateToProps, type Props } from '../AddressBook'
// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../__templates__/addressBook'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')
  .mock('../../../common/TypeAheadSearch', () => 'TypeAheadSearch')
  .mock('../../../common/components/rows/Row', () => 'Row')

const u1 = template.addressBookResult({
  id: '1',
})
const u2 = template.addressBookResult({
  id: '2',
})

describe('AddressBook', () => {
  let props: Props
  beforeEach(() => {
    jest.resetAllMocks()
    props = {
      onSelect: jest.fn(),
      context: 'course_1',
      name: 'Address Book Course',
      navigator: template.navigator(),
      courseID: '1',
      permissions: {
        send_messages: true,
        send_messages_all: true,
      },
      getCoursePermissions: jest.fn(),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('calls getCoursePermissions when rendered and no permissions are available', () => {
    let newProps = {
      ...props,
      permissions: undefined,
    }
    testRender(newProps)
    expect(newProps.getCoursePermissions).toHaveBeenCalledWith('1')
  })

  it('renders "All in" row', () => {
    props.context = 'course_1'
    props.name = 'React Native for Dummies'
    const screen = render(props)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(1)
    expect(rows[0].props.title).toEqual('All in React Native for Dummies')
  })

  it('does not render "All in" row if there is a query', () => {
    props.context = 'course_1'
    props.name = 'React Native for Dummies'
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onChangeText('this is a query')
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(0)
  })

  it('renders type ahead search results', () => {
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([u1, u2], null)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(3)
  })

  it('renders next type ahead search results', () => {
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestStarted()
    typeahead.props.onRequestFinished([u1], null)
    typeahead.props.onNextRequestFinished([u2], null)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(3)
  })

  it('pushes next branch', () => {
    props.navigator.show = jest.fn()
    const teachers = template.addressBookResult({
      id: 'course_1_teachers',
      name: 'Teachers',
    })
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([teachers], null)
    const row: any = explore(screen.toJSON()).selectByID('course_1_teachers')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/address-book',
      { modal: false },
      {
        onSelect: expect.any(Function),
        context: 'course_1_teachers',
        name: 'Teachers',
      },
    )
  })

  it('selects item', () => {
    props.onSelect = jest.fn()
    const item = template.addressBookResult({
      id: '1',
      name: 'E.T.C',
    })
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([item], null)
    const row: any = explore(screen.toJSON()).selectByID('1')
    row.props.onPress()
    expect(props.onSelect).toHaveBeenCalledWith([item])
  })

  it('selects "All in" item', () => {
    props.context = 'course_1_teachers'
    props.name = 'Teachers'
    props.onSelect = jest.fn()
    const screen = render(props)
    const row: any = explore(screen.toJSON()).query(({ type }) => type === 'Row')[0]
    row.props.onPress()
    expect(props.onSelect).toHaveBeenCalledWith([{
      id: 'course_1_teachers',
      name: 'Teachers',
    }])
  })

  it('dismisses on cancel', () => {
    props.navigator.dismiss = jest.fn()
    const cancel: any = explore(render(props).toJSON()).selectRightBarButton('address-book.cancel')
    cancel.action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls next on end reached', () => {
    const mock = jest.fn()
    const createNodeMock = ({ type }) => {
      if (type === 'TypeAheadSearch') {
        return {
          next: mock,
        }
      }
    }
    const screen = render(props, { createNodeMock })
    const list: any = explore(screen.toJSON()).selectByType('RCTScrollView')
    list.props.onEndReached()
    expect(mock).toHaveBeenCalled()
  })

  it('give type ahead the correct params', () => {
    props.context = 'course_2'
    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    expect(typeahead.props.parameters('Malthael')).toEqual({
      context: 'course_2',
      search: 'Malthael',
      synthetic_contexts: 1,
      per_page: 10,
      skip_visibility_checks: 1,
    })
  })

  it('doesnt include "All ..." buttons when the send_message is false', () => {
    props.permissions = {
      send_message: false,
    }
    testRender(props)
  })

  it('doesnt include "All ..." buttons when the send_message_all is false', () => {
    props.permissions = {
      send_message_all: false,
    }
    testRender(props)
  })

  it('doesnt include groups when the send_message is false', () => {
    props.permissions = {
      send_message: false,
    }
    let groupResult = template.addressBookResult({ id: 'group_1' })

    const screen = render(props)
    const typeahead: any = explore(screen.toJSON()).selectByType('TypeAheadSearch')
    typeahead.props.onRequestFinished([u1, u2, groupResult], null)
    const rows: any[] = explore(screen.toJSON()).query(({ type }) => type === 'Row')
    expect(rows).toHaveLength(2)
  })

  function render (props: Props, options: Object = {}) {
    return renderer.create(
      <AddressBook {...props} />, options
    )
  }

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }
})

describe('map state to props', () => {
  it('returns the courseID', () => {
    let ownProps = {
      context: 'course_1',
    }
    expect(mapStateToProps(template.appState(), ownProps).courseID).toEqual('1')
  })

  it('returns the course permissions', () => {
    let ownProps = {
      context: 'course_1',
    }
    expect(mapStateToProps(template.appState({
      entities: {
        courses: {
          '1': {
            permissions: { send_message: false },
          },
        },
      },
    }), ownProps).permissions).toEqual({
      send_message: false,
    })
  })
})
