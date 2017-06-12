/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'
import i18n from 'format-message'
import moment from 'moment'

import Screen from '../../../routing/Screen'
import refresh from '../../../utils/refresh'
import Row from '../../../common/components/rows/Row'
import Actions from './actions'
import Images from '../../../images'

type State = AsyncState & {
  announcements: Discussion[],
}

type OwnProps = {
  courseID: string,
}

export type Props = OwnProps & State & Actions & RefreshProps & NavigationProps

export class AnnouncementsList extends Component<any, Props, any> {

  render () {
    return (
      <Screen
        title={i18n('Announcements')}
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
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item }: { item: Discussion }) => {
    return (
      <Row
        title={item.title}
        subtitle={moment(item.posted_at).format(`MMM D [${i18n('at')}] h:mm A`)}
        border='bottom'
        height='auto'
        disclosureIndicator={true}
      />
    )
  }

  addAnnouncement = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/announcements/new`, { modal: true })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): State {
  let announcements = []
  let pending = 0
  let error = null
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].announcements &&
    entities.discussions) {
    const course = entities.courses[courseID]
    const refs = course.announcements.refs
    pending = course.announcements.pending
    error = course.announcements.error
    announcements = refs
      .map(ref => entities.discussions[ref].data)
  }
  return {
    announcements,
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
