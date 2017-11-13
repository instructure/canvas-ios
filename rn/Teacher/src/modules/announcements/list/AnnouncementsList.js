//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'
import i18n from 'format-message'

import Screen from '../../../routing/Screen'
import refresh from '../../../utils/refresh'
import Row from '../../../common/components/rows/Row'
import Actions from './actions'
import Images from '../../../images'
import RowSeparator from '../../../common/components/rows/RowSeparator'

type State = AsyncState & {
  announcements: Discussion[],
  courseName: string,
}

type OwnProps = {
  courseID: string,
}

export type Props = OwnProps & State & typeof Actions & RefreshProps & NavigationProps

export class AnnouncementsList extends Component<any, Props, any> {

  render () {
    return (
      <Screen
        navBarStyle='dark'
        title={i18n('Announcements')}
        subtitle={this.props.courseName}
        rightBarButtons={[
          {
            image: Images.add,
            testID: 'announcements.list.addButton',
            action: this.addAnnouncement,
          },
        ]}
      >
        <View style={styles.container}>
          <FlatList
            data={this.props.announcements}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.id}
            testID='announcements.list.list'
            refreshing={Boolean(this.props.pending)}
            onRefresh={this.props.refresh}
            ItemSeparatorComponent={RowSeparator}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: Discussion, index: number }) => {
    return (
      <Row
        title={item.title || i18n('No Title')}
        subtitle={i18n("{ date, date, 'MMM d'} at { date, time, short }", { date: new Date(item.delayed_post_at || item.posted_at) })}
        border='bottom'
        height='auto'
        disclosureIndicator={true}
        testID={`announcements.list.announcement.row-${index}`}
        onPress={this.selectAnnouncement(item)}
      />
    )
  }

  addAnnouncement = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/announcements/new`, { modal: true })
  }

  selectAnnouncement (announcement: Discussion) {
    return () => this.props.navigator.show(announcement.html_url, { modal: false }, {
      isAnnouncement: true,
    })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): State {
  let announcements = []
  let pending = 0
  let error = null
  let courseName = ''
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].announcements &&
    entities.discussions) {
    const course = entities.courses[courseID]
    const refs = course.announcements.refs
    pending = course.announcements.pending
    error = course.announcements.error
    if (course.course) {
      courseName = course.course.name
    }
    announcements = refs
      .map(ref => entities.discussions[ref].data)
  }
  return {
    announcements,
    courseName,
    pending,
    error,
  }
}

const Refreshed = refresh(
  props => {
    props.refreshAnnouncements(props.courseID)
  },
  props => props.announcements.length === 0,
  props => Boolean(props.pending)
)(AnnouncementsList)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
