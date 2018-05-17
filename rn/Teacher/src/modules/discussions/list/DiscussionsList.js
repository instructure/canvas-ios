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
import CourseActions from '@modules/courses/actions'
import refresh from '@utils/refresh'
import DiscusionsRow from './DiscussionsRow'
import SectionHeader from '@common/components/rows/SectionHeader'
import Screen from '@routing/Screen'
import Images from '@images'
import ActivityIndicatorView from '@common/components/ActivityIndicatorView'
import ListEmptyComponent from '@common/components/ListEmptyComponent'
import { isRegularDisplayMode } from '../../../routing/utils'
import type { TraitCollection } from '../../../routing/Navigator'

const { refreshCourse } = CourseActions
const { refreshDiscussions } = ListActions
const { updateDiscussion, deleteDiscussion } = EditActions

const Actions = {
  refreshDiscussions,
  updateDiscussion,
  deleteDiscussion,
  refreshCourse,
}

type OwnProps = {
  context: CanvasContext,
  contextID: string,
}

type State = {
  discussions: Discussion[],
  courseColor: ?string,
  pending: boolean,
  permissions?: CoursePermissions,
  selectedRowID: ?string,
}

export type Props = State & typeof Actions & OwnProps & {
  navigator: Navigator,
}

export class DiscussionsList extends Component<Props, any> {
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

  renderRow = ({ item, index }: { item: Discussion, index: number }) => {
    const selected = this.isRowSelected(item)
    return (
      <DiscusionsRow
        discussion={item}
        index={index}
        tintColor={this.props.courseColor}
        onPress={this._selectedDiscussion}
        onToggleDiscussionGrouping={this._onToggleDiscussionGrouping}
        selected={selected}
      />
    )
  }

  renderSectionHeader = ({ section }: any) => {
    const HEADERS = {
      'A_locked': i18n('Closed for Comments'),
      'B_discussion': i18n('Discussions'),
      'C_pinned': i18n('Pinned Discussions'),
    }
    return <SectionHeader title={HEADERS[section.key]} sectionKey={HEADERS[section.key]} />
  }

  _selectedDiscussion = (discussion: Discussion) => {
    this.setState({ selectedRowID: discussion.id })
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

      this.props.updateDiscussion(this.props.context, this.props.contextID, updatedDiscussion)
    })
  }

  _sectionType (discussion: Discussion): string {
    let type: string = discussion.pinned ? 'C_pinned' : discussion.locked ? 'A_locked' : 'B_discussion'
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
        data: this._sortSection(sections[key], key),
      }
    }).sort((a, b) => {
      return a.key < b.key ? 1 : -1
    })

    return sortedSectionData
  }

  _sortSection (section: Discussion[], key: string): Array<Discussion> {
    const sortBy = 'last_reply_at'
    return section.sort((a, b) => {
      if (key === 'C_pinned') {
        return a.position - b.position
      }

      if (!a[sortBy] && !b[sortBy]) {
        return 0 // preserve api order
      }
      if (!a[sortBy]) {
        return -1
      }
      if (!b[sortBy]) {
        return 1
      }

      return Date.parse(b[sortBy]) - Date.parse(a[sortBy])
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
        drawUnderNavBar
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        rightBarButtons={(this.props.permissions && this.props.permissions.create_discussion_topic) && [
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
            ListEmptyComponent={
              <ListEmptyComponent title={i18n('There are no discussions to display.')} />
            }
          />
        </View>
      </Screen>
    )
  }

  addDiscussion = () => {
    this.props.navigator.show(`/${this.props.context}/${this.props.contextID}/discussion_topics/new`, { modal: true, modalPresentationStyle: 'formsheet' })
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
    this.props.deleteDiscussion(this.props.context, this.props.contextID, discussion.id)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { context, contextID }: OwnProps): State {
  let discussions = []
  let courseColor = null
  let courseName = null
  let pending = false
  let refs: EntityRefs = []
  let userGroups = []
  let permissions = {
  }

  if (entities && entities.discussions) {
    if (context === 'courses' &&
      entities.courses &&
      entities.courses[contextID]) {
      const course = entities.courses[contextID]
      refs = course.discussions.refs
      courseColor = course.color
      courseName = course.course.name
      permissions = course.permissions || permissions
      pending = !!course.discussions.pending
      userGroups = entities.groups && Object.keys(entities.groups) || []
    } else if (context === 'groups' &&
      entities.groups &&
      entities.groups[contextID]) {
      const group: GroupState & GroupContentState = entities.groups[contextID]
      permissions.create_announcement = true
      permissions.create_discussion_topic = true
      refs = group.discussions && group.discussions.refs ? group.discussions.refs : []
      courseName = group.group.name
      courseColor = group.color
    }

    discussions = refs.map(ref => entities.discussions[ref].data)

    //  check for discussions that (have group discussion children) should be re-directed to a group discussion
    discussions = discussions.map(d => {
      if (d.group_category_id && d.group_topic_children) {
        let groupDiscussion = null
        d.group_topic_children.forEach(groupChildDiscussion => {
          if (userGroups.includes(groupChildDiscussion.group_id)) {
            groupDiscussion = groupChildDiscussion
          }
        })
        if (groupDiscussion) {
          return { ...d, html_url: `/groups/${groupDiscussion.group_id}/discussion_topics/${groupDiscussion.id}` }
        }
      }
      return d
    })
  }

  return {
    pending,
    discussions,
    courseColor,
    courseName,
    permissions,
    selectedRowID: null,
  }
}

const Refreshed = refresh(
  props => {
    props.refreshDiscussions(props.context, props.contextID)
    if (props.context === 'courses') {
      props.refreshCourse(props.contextID) // this is the only way to get `create discussion` permissions
    }
  },
  () => true,
  props => Boolean(props.pending)
)(DiscussionsList)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<Props, any>)
