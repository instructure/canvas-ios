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

/**
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  SectionList,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'

import { default as ListActions } from './actions'
import { default as EditActions } from '../edit/actions'
import refresh from '../../../utils/refresh'
import DiscusionsRow from './DiscussionsRow'
import SectionHeader from '../../../common/components/rows/SectionHeader'
import Screen from '../../../routing/Screen'
import Images from '../../../images'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'

const { refreshDiscussions } = ListActions
const { updateDiscussion, deleteDiscussion } = EditActions

const Actions = {
  refreshDiscussions,
  updateDiscussion,
  deleteDiscussion,
}

type OwnProps = {
  courseID: string,
}

type State = {
  discussions: Discussion[],
  courseColor: ?string,
  pending: boolean,
}

export type Props = State & typeof Actions & OwnProps & {
  navigator: Navigator,
}

const HEADERS = {
  'A_locked': i18n('Closed for Comments'),
  'B_discussion': i18n('Discussions'),
  'C_pinned': i18n('Pinned Discussions'),
}

export class DiscussionsList extends Component<any, Props, any> {

  renderRow = ({ item, index }: { item: Discussion, index: number }) => {
    return (
      <DiscusionsRow
        discussion={item}
        index={index}
        tintColor={this.props.courseColor}
        onPress={this._selectedDiscussion}
        onToggleDiscussionGrouping={this._onToggleDiscussionGrouping}
      />
    )
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader title={HEADERS[section.key]} sectionKey={HEADERS[section.key]} />
  }

  _selectedDiscussion = (discussion: Discussion) => {
    this.props.navigator.show(discussion.html_url)
  }

  _optionsForTogglingDiscussion = (discussion: Discussion) => {
    let lockOption = discussion.locked ? i18n('Open for comments') : i18n('Close for comments')
    let pinOption = discussion.pinned ? i18n('Unpin') : i18n('Pin')
    let options = [pinOption, lockOption]
    options.push(i18n('Delete'))
    options.push(i18n('Cancel'))
    return options
  }

  _onToggleDiscussionGrouping = (discussion: Discussion) => {
    let options = this._optionsForTogglingDiscussion(discussion)

    ActionSheetIOS.showActionSheetWithOptions({
      options: options,
      cancelButtonIndex: options.length - 1,
      destructiveButtonIndex: options.length - 2,
    }, (button) => {
      if (button === (options.length - 1)) return
      if (button === (options.length - 2)) {
        this._confirmDeleteDiscussion(discussion)
        return
      }

      let updatedDiscussion = { id: discussion.id, locked: discussion.locked, pinned: discussion.pinned }
      if (button === 0) { updatedDiscussion.pinned = !updatedDiscussion.pinned; updatedDiscussion.locked = false }
      if (button === 1) { updatedDiscussion.locked = !updatedDiscussion.locked; updatedDiscussion.pinned = false }

      this.props.updateDiscussion(this.props.courseID, updatedDiscussion)
    })
  }

  _sectionType (discussion: Discussion): string {
    let type: string = discussion.locked ? 'A_locked' : discussion.pinned ? 'C_pinned' : 'B_discussion'
    return type
  }

  _getData = () => {
    const sections = this.props.discussions.reduce((data, discussion) => {
      let type: string = this._sectionType(discussion)
      return {
        ...data,
        [type]: (data[type] || []).concat([discussion]),
      }
    }, {})

    let sortedSectionData = Object.keys(sections).map((key) => {
      return {
        key,
        data: this._sortSection(sections[key]),
      }
    }).sort((a, b) => {
      return a.key < b.key ? 1 : -1
    })

    return sortedSectionData
  }

  _sortSection (section: Discussion[]): Array<Discussion> {
    const sortBy = 'last_reply_at'
    return section.sort((a, b) => {
      const tieBreaker = a.title.toLowerCase() < b.title.toLowerCase() ? -1 : 1

      if (!a[sortBy] && !b[sortBy]) {
        return tieBreaker
      }
      if (!a[sortBy]) {
        return -1
      }
      if (!b[sortBy]) {
        return 1
      }

      return new Date(a[sortBy]) < new Date(b[sortBy]) ? 1 : -1
    })
  }

  render () {
    if (this.props.pending && !this.props.refreshing) {
      return <ActivityIndicatorView />
    }

    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
        rightBarButtons={[
          {
            image: Images.add,
            testID: 'discussions.list.add.button',
            accessibilityLabel: i18n('New Discussion'),
            action: this.addDiscussion,
          },
        ]}
        title={i18n('Discussions')}
        subtitle={this.props.courseName}>
        <View style={styles.container}>
          <SectionList
            sections={this._getData()}
            renderSectionHeader={this.renderSectionHeader}
            renderItem={this.renderRow}
            refreshing={Boolean(this.props.pending)}
            onRefresh={this.props.refresh}
            keyExtractor={(item, index) => item.id}
            testID='discussion-list.list'
          />
        </View>
      </Screen>
    )
  }

  addDiscussion = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/discussion_topics/new`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _confirmDeleteDiscussion = (discussion: Discussion) => {
    AlertIOS.alert(
      i18n('Are you sure you want to delete this discussion?'),
      null,
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('OK'), onPress: () => { this._deleteDiscussion(discussion) } },
      ],
    )
  }

  _deleteDiscussion = (discussion: Discussion) => {
    this.props.deleteDiscussion(this.props.courseID, discussion.id)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): State {
  let discussions = []
  let courseColor = null
  let courseName = null
  let pending = false
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.discussions) {
    const course = entities.courses[courseID]
    const refs = course.discussions.refs
    discussions = refs
      .map(ref => entities.discussions[ref].data)
    courseColor = course.color
    courseName = course.course.name
    pending = !!course.discussions.pending
  }

  return {
    pending,
    discussions,
    courseColor,
    courseName,
  }
}

const Refreshed = refresh(
  props => {
    props.refreshDiscussions(props.courseID)
  },
  props => props.discussions.length === 0,
  props => Boolean(props.pending)
)(DiscussionsList)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
