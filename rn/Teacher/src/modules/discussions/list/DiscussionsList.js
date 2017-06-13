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
} from 'react-native'
import i18n from 'format-message'

import Actions from './actions'
import refresh from '../../../utils/refresh'
import DiscusionsRow from './DiscussionsRow'
import { SectionHeader } from '../../../common/text'
import Screen from '../../../routing/Screen'

type OwnProps = {
  courseID: string,
}

type State = {
  discussions: Discussion[],
  courseColor: ?string,
}

export type Props = State & typeof Actions & {
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
    return <SectionHeader>{HEADERS[section.key]}</SectionHeader>
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
      if (button === (options.length - 2)) return
      let updatedDiscussion = Object.assign({}, discussion)

      if (button === 0) { updatedDiscussion.pinned = !updatedDiscussion.pinned; updatedDiscussion.locked = false }
      if (button === 1) { updatedDiscussion.locked = !updatedDiscussion.locked; updatedDiscussion.pinned = false }

      this.props.updateDiscussion(updatedDiscussion, discussion, this.props.courseID)
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
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
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
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): State {
  let discussions = []
  let courseColor = null
  let courseName = null
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
  }

  return {
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
