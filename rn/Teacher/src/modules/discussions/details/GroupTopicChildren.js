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

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  TouchableOpacity,
  Text,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import api from '../../../canvas-api'
import i18n from 'format-message'

export default class GroupTopicChildren extends Component {
  static defaultProps = {
    getGroupsForCourse: api.getGroupsForCourse,
  }

  state = {
    groups: null,
  }

  constructor (props) {
    super(props)
    this.getGroups(props)
  }

  componentWillReceiveProps (nextProps) {
    this.getGroups(nextProps)
  }

  async getGroups (props) {
    if (props.courseID == null) return
    try {
      let { data } = await props.getGroupsForCourse(props.courseID)
      let groups = props.topicChildren.reduce((groups, { id, group_id }) => {
        let group = data.find(({ id }) => id === group_id)
        if (group) {
          groups.push({
            ...group,
            discussion_id: id,
          })
        }
        return groups
      }, [])
      this.setState({ groups })
    } catch (e) {
      this.setState({ groups: null })
    }
  }

  onPress (group) {
    this.props.navigator.show(`/groups/${group.id}/discussion_topics/${group.discussion_id}`)
  }

  render () {
    let { courseColor } = this.props
    let backgroundColor = courseColor ? `${courseColor}33` : `rgba(245, 245, 245, 0.8)`
    return (
      <View style={[style.container, { backgroundColor }]}>
        <Text style={style.header}>{i18n('Since this is a group discussion, each group has its own conversation for this topic. Here are the discussions you have access to.')}</Text>
        { this.state.groups && this.state.groups.map(group => {
          return (
            <TouchableOpacity
              key={group.id}
              style={{ flex: 1 }}
              onPress={() => { this.onPress(group) }}
              testID={`GroupTopicChildren.group-${group.id}.button`}
            >
              <View style={style.row}>
                <Text testID={`GroupTopicChildren.group-${group.id}.label`} style={style.rowTitle}>{group.name}</Text>
                <DisclosureIndicator />
              </View>
            </TouchableOpacity>
          )
        })}
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    borderRadius: 8,
    paddingBottom: 12,
  },
  header: {
    lineHeight: 23,
    fontWeight: '600',
    padding: 12,
    fontSize: 16,
  },
  row: {
    padding: 12,
    paddingRight: 16,
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  rowTitle: {
    fontSize: 16,
    fontWeight: '700',
  },
})
