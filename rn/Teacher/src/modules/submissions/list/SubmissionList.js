// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import type {
  SubmissionListProps,
  SubmissionProps,
} from './submission-prop-types'
import { mapStateToProps } from './map-state-to-props'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import SubmissionActions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import refresh from '../../../utils/refresh'
import { LinkButton } from '../../../common/buttons'
import { Heading1 } from '../../../common/text'
import { route } from '../../../routing'

type Props = SubmissionListProps & NavProps & RefreshProps

export class SubmissionList extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)

    props.navigator.setTitle({
      title: i18n({
        default: 'Submissions',
        description: 'Title for the list of submissions for an assignment',
      }),
    })

    if (props.courseColor) {
      const color: string = props.courseColor
      props.navigator.setStyle({
        navBarBackgroundColor: color,
      })
    }
  }

  keyExtractor = (item: SubmissionProps) => {
    return item.userID
  }

  navigateToSubmission = (userID: string) => {
    if (!global.V03) { return } // such features

    let destination = route(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submissions/${userID}`)
    this.props.navigator.showModal({
      ...destination,
      navigatorStyle: {
        navBarHidden: true,
        statusBarHidden: true,
        statusBarHideWithNavBar: true,
      },
    })
  }

  renderRow = ({ item }: { item: SubmissionProps }) => {
    return <SubmissionRow {...item} onPress={this.navigateToSubmission} />
  }

  chooseFilter = () => {
    console.log('filter the submissions')
  }

  render () {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Heading1
            style={styles.headerTitle}
            >
            { i18n('All Submissions') }
          </Heading1>
          <LinkButton
            testID='submission-list.filter'
            onPress={this.chooseFilter}
            style={styles.filterButton}
            accessibilityLabel={i18n('Filter Submissions')}
            >
            { i18n('Filter') }
          </LinkButton>
        </View>
        <FlatList
          data={this.props.submissions}
          keyExtractor={this.keyExtractor}
          testID='submission-list'
          renderItem={this.renderRow}
          refreshing={this.props.pending}
          onRefresh={this.props.refresh}
          />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
  },
  filterButton: {
    marginBottom: 1,
  },
})

export function refreshSubmissionList (props: SubmissionListProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
}

export function shouldRefresh (props: SubmissionListProps): boolean {
  return props.shouldRefresh
}

const Refreshed = refresh(
  refreshSubmissionList,
  shouldRefresh,
  props => props.pending
)(SubmissionList)
const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions })(Refreshed)
export default (Connected: Component<any, SubmissionListProps, any>)
