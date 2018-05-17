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
import ListActions from './actions'
import CourseActions from '../../courses/actions'
import Images from '../../../images'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import { Text } from '../../../common/text'
import { isRegularDisplayMode } from '../../../routing/utils'
import type { TraitCollection } from '../../../routing/Navigator'

const { refreshCourse } = CourseActions
const { refreshAnnouncements } = ListActions

const Actions = {
  refreshAnnouncements,
  refreshCourse,
}

type State = AsyncState & {
  announcements: Discussion[],
  courseName: string,
  permissions: CoursePermissions,
  courseColor: string,
}

type OwnProps = {
  context: CanvasContext,
  contextID: string,
}

export type Props = OwnProps & State & typeof Actions & RefreshProps & NavigationProps

export class AnnouncementsList extends Component<Props, any> {
  componentWillMount () {
    this.onTraitCollectionChange()
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this.traitCollectionDidChange(traits) })
  }

  traitCollectionDidChange (traits: TraitCollection) {
    this.setState({ isRegularScreenDisplayMode: isRegularDisplayMode(traits) })
  }

  isRowSelected (item: Discussion): boolean {
    if (this.state && this.state.selectedRowID) {
      return this.state.isRegularScreenDisplayMode && this.state.selectedRowID === item.id
    }

    return false
  }

  render () {
    if (this.props.pending && !this.props.refreshing) {
      return <ActivityIndicatorView />
    }
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        title={i18n('Announcements')}
        subtitle={this.props.courseName}
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        rightBarButtons={ (this.props.permissions && this.props.permissions.create_announcement) && [
          {
            image: Images.add,
            testID: 'announcements.list.addButton',
            action: this.addAnnouncement,
            accessibilityLabel: i18n('New Announcement'),
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
            ListEmptyComponent={
              <ListEmptyComponent title={i18n('There are no announcements to display.')} />
            }
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: Discussion, index: number }) => {
    let lastReplyDateStr = i18n("{ date, date, 'MMM d'} at { date, time, short }", { date: new Date(item.delayed_post_at || item.last_reply_at) })
    const showDelayedText = item.delayed_post_at && new Date(item.delayed_post_at) > new Date()
    const subtitle = !showDelayedText ? i18n('Last post {lastReplyDateStr}', { lastReplyDateStr }) : lastReplyDateStr
    const selected = this.isRowSelected(item)

    return (
      <Row
        title={item.title || i18n('No Title')}
        border='bottom'
        height='auto'
        disclosureIndicator={true}
        testID={`announcements.list.announcement.row-${index}`}
        onPress={() => this.selectAnnouncement(item)}
        selected={selected}
      >
        <View style={style.subtitleContainer} testID={`announcements.list.announcement.row-${index}.subtitle.custom-container`}>
          {showDelayedText && <Text style={[style.subtitle, style.delay]}>{i18n('Delayed until: ')}</Text>}
          <Text style={style.subtitle}>{subtitle}</Text>
        </View>
      </Row>
    )
  }

  addAnnouncement = () => {
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/announcements/new`, { modal: true })
  }

  selectAnnouncement (announcement: Discussion) {
    this.setState({ selectedRowID: announcement.id })
    this.props.navigator.show(announcement.html_url, { modal: false }, {
      isAnnouncement: true,
    })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { context, contextID }: OwnProps): State {
  let announcements = []
  let pending = 0
  let error = null
  let courseName = ''
  let courseColor = ''
  let permissions = {}

  let origin: DiscussionOriginEntity = (context === 'courses') ? entities.courses : entities.groups

  if (entities &&
    origin &&
    origin[contextID] &&
    origin[contextID].announcements) {
    const entity = origin[contextID]
    const refs = entity.announcements.refs
    permissions = entity.permissions
    pending = entity.announcements.pending
    error = entity.announcements.error
    if (context === 'courses' && entity.course) {
      courseName = entity.course.name
      courseColor = entity.course.color
    } else if (entity.group) {
      courseName = entity.group.name
      courseColor = entity.group.color
      permissions = { create_announcement: true, create_discussion_topic: true }
    }

    announcements = refs
      .map(ref => entities.discussions[ref].data)
      .sort((a1, a2) => {
        if (a1.position === a2.position) return 0
        return a1.position > a2.position ? -1 : 1
      })
  }

  return {
    announcements,
    courseName,
    courseColor,
    pending,
    error,
    permissions,
  }
}

export const Refreshed = refresh(
  props => {
    props.refreshAnnouncements(props.context, props.contextID)
    if (props.context === 'courses') {
      props.refreshCourse(props.contextID) // this is the only way to get `create announcement` permissions
    }
  },
  props => props.announcements.length === 0 || Object.keys(props.permissions).length === 0,
  props => Boolean(props.pending)
)(AnnouncementsList)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<Props, any>)

const style = StyleSheet.create({
  subtitleContainer: {
    flex: 1,
    flexDirection: 'row',
  },
  subtitle: {
    color: '#8B969E',
    fontSize: 14,
    marginTop: 2,
  },

  delay: {
    fontWeight: '600',
  },
})
