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

/* eslint-disable flowtype/require-valid-file-annotation */
import 'react-native'
import React from 'react'
import { AddressBook, mapStateToProps, type Props } from '../AddressBook'
import { shallow } from 'enzyme'
import * as templates from '../../../__templates__/index'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')
  .mock('../../../common/TypeAheadSearch', () => 'TypeAheadSearch')
  .mock('../../../common/components/rows/Row', () => 'Row')

const u1 = templates.addressBookResult({
  id: '1',
})
const u2 = templates.addressBookResult({
  id: '2',
})

describe('AddressBook', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      onSelect: jest.fn(),
      context: 'course_1',
      name: 'Address Book Course',
      navigator: templates.navigator(),
      courseID: '1',
      permissions: {
        send_messages: true,
        send_messages_all: true,
      },
      getCoursePermissions: jest.fn(),
    }
  })

  it('renders', () => {
    expect(shallow(<AddressBook {...props} />)).toMatchSnapshot()
  })

  it('calls getCoursePermissions when rendered', () => {
    let newProps = {
      ...props,
      getCoursePermissions: jest.fn(),
      permissions: undefined,
    }
    shallow(<AddressBook {...newProps} />)
    expect(newProps.getCoursePermissions).toHaveBeenCalledWith('1')

    newProps = {
      ...props,
      getCoursePermissions: jest.fn(),
      permissions: {},
    }
    shallow(<AddressBook {...newProps} />)
    expect(newProps.getCoursePermissions).toHaveBeenCalledWith('1')

    newProps = {
      ...props,
      getCoursePermissions: jest.fn(),
      permissions: { permission: true },
    }
    shallow(<AddressBook {...newProps} />)
    expect(newProps.getCoursePermissions).toHaveBeenCalledWith('1') // no longer use the permissions from cache
  })

  it('renders "All in" row', () => {
    props.context = 'course_1'
    props.name = 'React Native for Dummies'
    const screen = shallow(<AddressBook {...props} />)
    const rows = screen.find('FlatList').props().data
    expect(rows).toHaveLength(1)
    expect(rows[0].name).toEqual('All in React Native for Dummies')
  })

  it('does not render "All in" row if there is a query', () => {
    props.context = 'course_1'
    props.name = 'React Native for Dummies'
    const screen = shallow(<AddressBook {...props} />)
    screen.instance()._queryChanged('changeText', 'this is a query')
    screen.update()
    const rows = screen.find('FlatList').props().data
    expect(rows).toHaveLength(0)
  })

  it('renders type ahead search results', () => {
    let results = [
      templates.addressBookResult({
        id: '1',
        name: 'John',
      }),
      templates.addressBookResult({
        id: '2',
        name: 'Jane',
        pronouns: 'She/Her',
      }),
    ]
    let screen = shallow(<AddressBook {...props} />)
    let search = shallow(screen.find('FlatList').prop('ListHeaderComponent'))
    search.prop('onRequestFinished')(results, null)
    screen.update()
    let list = screen.find('FlatList')
    let rows = list.prop('data')
    expect(rows).toHaveLength(results.length + 1) // + All row
    let row1 = shallow(list.prop('renderItem')({ item: rows[1], index: 1 }))
    expect(row1.prop('title')).toEqual('John')
    let row2 = shallow(list.prop('renderItem')({ item: rows[2], index: 2 }))
    expect(row2.prop('title')).toEqual('Jane (She/Her)')
  })

  it('renders next type ahead search results', () => {
    const screen = shallow(<AddressBook {...props} />)
    screen.instance()._requestStarted()
    screen.instance()._requestFinished([u1], null)
    screen.instance()._nextRequestFinished([u2], null)
    screen.update()
    const rows = screen.find('FlatList').props().data
    expect(rows).toHaveLength(3)
  })

  it('pushes next branch', () => {
    props.navigator.show = jest.fn()
    const teachers = templates.addressBookResult({
      id: 'course_1_teachers',
      name: 'Teachers',
    })
    const row = shallow(new AddressBook(props)._renderRow({ item: teachers }))
    row.simulate('press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/address-book',
      { modal: false },
      {
        onSelect: expect.any(Function),
        context: 'course_1_teachers',
        name: 'Teachers',
        courseID: '1',
      },
    )
  })

  it('selects item', () => {
    props.onSelect = jest.fn()
    const item = templates.addressBookResult({
      id: '1',
      name: 'E.T.C',
    })
    const row = shallow(new AddressBook(props)._renderRow({ item }))
    row.simulate('press')
    expect(props.onSelect).toHaveBeenCalledWith([item])
  })

  it('selects "All in" item', () => {
    props.context = 'course_1_teachers'
    props.name = 'Teachers'
    props.onSelect = jest.fn()
    const screen = shallow(<AddressBook {...props} />)
    screen.instance()._requestFinished([
      templates.addressBookResult({
        id: '1',
        name: 'Teachers 1',
        user_count: 55,
      }),
      templates.addressBookResult({
        id: '2',
        name: 'Teachers 2',
        user_count: 147,
      }),
    ])
    const list = screen.find('FlatList')
    const row = shallow(screen.instance()._renderRow({ item: list.props().data[0] }))
    row.simulate('press')
    expect(props.onSelect).toHaveBeenCalledWith([{
      id: 'course_1_teachers',
      name: 'Teachers',
      user_count: 202,
    }])
  })

  it('dismisses on cancel', () => {
    props.navigator.dismiss = jest.fn()
    const screen = shallow(<AddressBook {...props} />)
    const cancel = screen.find('Screen').props().rightBarButtons[0]
    cancel.action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls next on end reached', () => {
    const screen = shallow(<AddressBook {...props} />)
    let next = jest.fn()
    screen.instance().typeAhead = { next }
    const list = screen.find('FlatList')
    list.simulate('endReached')
    expect(next).toHaveBeenCalled()
  })

  it('give type ahead the correct params', () => {
    props.context = 'course_2'
    let tree = shallow(<AddressBook {...props} />)
    let typeahead = shallow(tree.find('FlatList').prop('ListHeaderComponent'))
    expect(typeahead.props().parameters('Malthael')).toEqual({
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
    const screen = shallow(<AddressBook {...props} />)
    const list = screen.find('FlatList')
    expect(list.props().data).toHaveLength(0)
  })

  it('doesnt include "All ..." buttons when the send_message_all is false', () => {
    props.permissions = {
      send_message_all: false,
    }
    const screen = shallow(<AddressBook {...props} />)
    const list = screen.find('FlatList')
    expect(list.props().data).toHaveLength(0)
  })

  it('doesnt include groups when the send_message is false', () => {
    props.permissions = {
      send_message: false,
    }
    let groupResult = templates.addressBookResult({ id: 'group_1' })

    const screen = shallow(<AddressBook {...props} />)
    screen.instance()._requestFinished([u1, u2, groupResult], null)
    screen.update()
    const rows = screen.find('FlatList').props().data
    expect(rows).toHaveLength(2)
  })
})

describe('map state to props', () => {
  it('returns the courseID', () => {
    let ownProps = {
      context: 'course_1',
    }
    expect(mapStateToProps(templates.appState(), ownProps).courseID).toEqual('1')
  })

  it('looks up the courseID from section', () => {
    let ownProps = {
      context: 'section_421',
    }
    let appState = templates.appState()
    appState.entities.sections['421'] = templates.section({ course_id: '1' })
    expect(mapStateToProps(appState, ownProps).courseID).toEqual('1')
  })

  it('uses the courseID instead of the context id to derive the course ID', () => {
    let ownProps = {
      context: 'section_421',
      courseID: '1',
    }
    let appState = templates.appState()
    expect(mapStateToProps(appState, ownProps).courseID).toEqual('1')
  })

  it('does not use group id as courseID', () => {
    let ownProps = {
      context: 'group_1',
    }
    expect(mapStateToProps(templates.appState(), ownProps).courseID).toBeNull()
  })

  it('returns the course permissions', () => {
    let ownProps = {
      context: 'course_1',
    }
    expect(mapStateToProps(templates.appState({
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
