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
import ConversationRow from '../ConversationRow'
import { shallow } from 'enzyme'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

const template = {
  ...require('../../../../__templates__/conversations'),
}

describe('ConversationRow', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      conversation: template.conversation({ id: '1' }),
      drawsTopLine: true,
      onPress: jest.fn(),
    }
  })

  it('hides unread indicator', () => {
    props.conversation.workflow_state = 'read'
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.unreadIndicator"]').exists()).toEqual(false)
  })

  it('shows unread indicator', () => {
    props.conversation.workflow_state = 'unread'
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.unreadIndicator"]').exists()).toEqual(true)
  })

  it('shows starred', () => {
    props.conversation.starred = true
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.starredIndicator"]').exists()).toEqual(true)
  })

  it('hides starred', () => {
    props.conversation.starred = false
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.starredIndicator"]').exists()).toEqual(false)
  })

  it('renders with more than 6 participant names', () => {
    props.conversation.participants = Array(8).fill().map((e, i) => ({ id: i.toString(), name: i.toString() }))
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.names"]').prop('children')).toEqual('0, 2, 3, 4, 5 + 2 more')
  })

  it('renders participant names', () => {
    props.conversation.participants = [
      { id: '11', name: 'Graydon' },
      { id: '12', name: 'James' },
      { id: '13', name: 'Josh' },
    ]
    let tree = shallow(<ConversationRow {...props} />)
    let expected = 'Graydon, James, Josh'
    expect(tree.find('[testID="ConversationRow.1.names"]').prop('children')).toEqual(expected)
  })

  it('renders participant names with pronouns', () => {
    props.conversation.participants = [
      { id: '11', name: 'Graydon', pronouns: 'He/Him' },
      { id: '12', name: 'James', pronouns: 'They/Them' },
      { id: '13', name: 'Josh', pronouns: 'She/Her' },
    ]
    let tree = shallow(<ConversationRow {...props} />)
    let expected = 'Graydon (He/Him), James (They/Them), Josh (She/Her)'
    expect(tree.find('[testID="ConversationRow.1.names"]').prop('children')).toEqual(expected)
  })

  it('handles on press', () => {
    const tree = shallow(<ConversationRow {...props} />)
    tree.find('[testID="inbox.conversation-1"]').simulate('Press')
    expect(props.onPress).toHaveBeenCalledWith('1')
  })

  it('renders the correct date', async () => {
    let authored = new Date('2016-02-01T11:49:37-07:00')
    let messaged = new Date('2017-02-01T11:49:37-07:00')
    let authoredAt = '2/1/2016'
    let messagedAt = '2/1/2017'
    props.conversation.last_authored_message_at = authored
    props.conversation.last_message_at = messaged
    props.conversation.properties = ['last_author']
    let tree = shallow(<ConversationRow {...props} />)
    expect(tree.find('[testID="ConversationRow.1.date"]').prop('children')).toEqual(authoredAt)

    props.conversation.last_authored_message_at = null
    await tree.setProps(props)
    expect(tree.find('[testID="ConversationRow.1.date"]').prop('children')).toEqual(messagedAt)

    props.properties = null
    props.conversation.last_message_at = null
    props.conversation.last_authored_message_at = authored
    await tree.setProps(props)
    expect(tree.find('[testID="ConversationRow.1.date"]').prop('children')).toEqual(authoredAt)

    props.conversation.properties = []
    props.conversation.last_message_at = messaged
    await tree.setProps(props)
    expect(tree.find('[testID="ConversationRow.1.date"]').prop('children')).toEqual(messagedAt)
  })
})

