// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  NetInfo,
  AlertIOS,
} from 'react-native'
import { connect } from 'react-redux'
import type {
  SubmissionListProps,
  SubmissionProps,
  SubmissionDataProps,
} from './submission-prop-types'
import find from 'lodash/find'
import { mapStateToProps } from './map-state-to-props'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import SubmissionActions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import GroupActions from '../../groups/actions'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import SubmissionsHeader, { type SubmissionFilterOption, type SelectedSubmissionFilter } from '../SubmissionsHeader'
import Images from '../../../images'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'

type Props = SubmissionListProps & { navigator: Navigator } & RefreshProps
type State = {
  submissions: Array<SubmissionDataProps>,
  isConnected: boolean,
}

export class SubmissionList extends Component {
  props: Props
  state: State

  filterOptions: SubmissionFilterOption[]
  selectedFilter: ?SelectedSubmissionFilter

  constructor (props: Props) {
    super(props)

    this.state = {
      submissions: props.submissions || [],
      isConnected: true,
    }

    this.filterOptions = SubmissionsHeader.defaultFilterOptions()
  }

  componentWillMount = () => {
    const type = this.props.filterType
    if (type) {
      const filter = find(this.filterOptions, { type })
      if (filter) {
        this.selectedFilter = { filter }
      }
      this.updateSubmissions(this.props.submissions)
    }
    NetInfo.isConnected.fetch().then(this.setConnection)
    NetInfo.isConnected.addEventListener('change', this.setConnection)
  }

  componentWillUnmount = () => {
    NetInfo.isConnected.removeEventListener('change', this.setConnection)
  }

  componentWillReceiveProps = (newProps: Props) => {
    this.updateSubmissions(newProps.submissions)
  }

  setConnection = (isConnected: boolean) => {
    this.setState({ isConnected })
  }

  keyExtractor = (item: SubmissionProps) => {
    return item.userID
  }

  navigateToSubmission = (index: number) => (userID: string) => {
    if (!this.state.isConnected) {
      return AlertIOS.alert(i18n('No internet connection'), i18n('This action requires an internet connection.'))
    }

    const path = `/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submissions/${userID}`
    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { selectedFilter: this.selectedFilter, studentIndex: index }
    )
  }

  navigateToContextCard = (userID: string) => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${userID}`,
      { modal: true, modalPresentationStyle: 'currentContext' },
    )
  }

  renderRow = ({ item, index }: { item: SubmissionProps, index: number }) => {
    return (
      <SubmissionRow
        {...item}
        onAvatarPress={!this.props.groupAssignment && this.navigateToContextCard}
        onPress={this.navigateToSubmission(index)}
        anonymous={this.props.anonymous}
      />
    )
  }

  updateFilter = (filter: SelectedSubmissionFilter) => {
    this.selectedFilter = filter
    this.updateSubmissions(this.props.submissions)
  }

  clearFilter = () => {
    this.selectedFilter = null
    this.updateSubmissions(this.props.submissions)
  }

  updateSubmissions = (submissions: SubmissionDataProps[]) => {
    const selected = this.selectedFilter
    let filtered = submissions
    if (selected && selected.filter && selected.filter.filterFunc) {
      filtered = selected.filter.filterFunc(submissions, selected.metadata)
    }

    this.setState({
      submissions: filtered,
    })
  }

  openSettings = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submission_settings`, {
      modal: true,
    })
  }

  messageStudentsWho = () => {
    var subject = ''
    if (this.selectedFilter) {
      switch (this.selectedFilter.filter.type) {
        case 'all':
          subject = i18n('All submissions - {assignmentName}', { assignmentName: this.props.assignmentName })
          break
        case 'late':
          subject = i18n('Submitted late - {assignmentName}', { assignmentName: this.props.assignmentName })
          break
        case 'notsubmitted':
          subject = i18n("Haven't submitted yet - {assignmentName}", { assignmentName: this.props.assignmentName })
          break
        case 'notgraded':
          subject = i18n("Haven't been graded - {assignmentName}", { assignmentName: this.props.assignmentName })
          break
        case 'graded':
          subject = i18n('Graded - {assignmentName}', { assignmentName: this.props.assignmentName })
          break
        case 'lessthan':
          subject = i18n('Scored less than {score} - {assignmentName}', { score: this.selectedFilter.metadata || '', assignmentName: this.props.assignmentName })
          break
        case 'morethan':
          subject = i18n('Score more than {score} - {assignmentName}', { score: this.selectedFilter.metadata || '', assignmentName: this.props.assignmentName })
          break
        default:
          break
      }
    }
    this.props.navigator.show('/conversations/compose', { modal: true }, {
      recipients: this.state.submissions.map((submission) => {
        return { id: submission.userID, name: submission.name, avatar_url: submission.avatarURL }
      }),
      subject: subject,
      contextName: this.props.course ? this.props.course.name : null,
      contextCode: this.props.course ? `course_${this.props.course.id}` : null,
      canAddRecipients: false,
      onlySendIndividualMessages: true,
    })
  }

  render () {
    return (
      <Screen
        title={i18n('Submissions')}
        subtitle={this.props.courseName}
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        rightBarButtons={[
          {
            accessibilityLabel: i18n('Message students who'),
            image: Images.smallMail,
            testID: 'submission-list.message-who-btn',
            action: this.messageStudentsWho,
          },
          {
            accessibilityLabel: i18n('Submission Settings'),
            image: Images.course.settings,
            testID: 'submission-list.settings',
            action: this.openSettings,
          },
        ]}
      >
        { this.props.pending && !this.props.refreshing
          ? <ActivityIndicatorView />
          : <View style={styles.container}>
              <SubmissionsHeader
                filterOptions={this.filterOptions}
                selectedFilter={this.selectedFilter}
                onClearFilter={this.clearFilter}
                onSelectFilter={this.updateFilter}
                pointsPossible={this.props.pointsPossible}
                anonymous={this.props.anonymous}
                muted={this.props.muted}
              />
              { /* $FlowFixMe I seriously have no idea why this is complaining about flatlist not having some properties */ }
              <FlatList
                data={this.state.submissions}
                keyExtractor={this.keyExtractor}
                testID='submission-list'
                renderItem={this.renderRow}
                refreshing={this.props.refreshing}
                onRefresh={this.props.refresh}
                />
            </View>
        }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,

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
  if (props.groupAssignment && !props.groupAssignment.gradeIndividually) {
    props.refreshGroupsForCourse(props.courseID)
    props.refreshSubmissions(props.courseID, props.assignmentID, true)
  } else {
    props.refreshSubmissions(props.courseID, props.assignmentID, false)
    props.refreshEnrollments(props.courseID)
  }
}

export function shouldRefresh (props: SubmissionListProps): boolean {
  return props.submissions.every(({ submission }) => !submission)
}

const Refreshed = refresh(
  refreshSubmissionList,
  shouldRefresh,
  props => props.pending
)(SubmissionList)
const Connected = connect(mapStateToProps, {
  ...SubmissionActions,
  ...EnrollmentActions,
  ...GroupActions,
})(Refreshed)
export default (Connected: Component<any, SubmissionListProps, any>)
