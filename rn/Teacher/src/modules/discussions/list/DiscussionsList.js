/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  SectionList,
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
      />
    )
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader>{HEADERS[section.key]}</SectionHeader>
  }

  _selectedDiscussion = (discussion: Discussion) => {
    this.props.navigator.show(discussion.html_url)
  }

  _getData = () => {
    const sections = this.props.discussions.reduce((data, discussion) => {
      let type: string = discussion.locked ? 'A_locked' : discussion.pinned ? 'C_pinned' : 'B_discussion'
      return {
        ...data,
        [type]: (data[type] || []).concat([discussion]),
      }
    }, {})

    let sortedSectionData = Object.keys(sections).map((key) => {
      return {
        key,
        data: this._sortSectionByKey(sections[key], key),
      }
    }).sort((a, b) => {
      return a.key < b.key ? 1 : -1
    })

    return sortedSectionData
  }

  _sortSectionByKey (section: Discussion[], key: string): Array<Discussion> {
    const sortBy = key === 'A_locked' ? 'lock_at' : 'due_at'
    return section.sort((a, b) => {
      const tieBreaker = a.title.toLowerCase() < b.title.toLowerCase() ? -1 : 1
      let aAssignment = a.assignment || {}
      let bAssignment = b.assignment || {}

      if (!aAssignment[sortBy] && !bAssignment[sortBy]) {
        return tieBreaker
      }
      if (!aAssignment[sortBy]) {
        return 1
      }
      if (!bAssignment[sortBy]) {
        return -1
      }

      const x = new Date(aAssignment[sortBy]) < new Date(bAssignment[sortBy]) ? -1 : 1
      return x === 0 ? tieBreaker : x
    })
  }

  render (): React.Element<View> {
    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
        title={i18n({
          default: 'Discussions',
        })}
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
