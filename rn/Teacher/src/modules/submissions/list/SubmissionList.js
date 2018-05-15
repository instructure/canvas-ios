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
} from './submission-prop-types'
import { mapStateToProps } from './map-state-to-props'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import SubmissionActions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import SectionActions from '../../assignee-picker/actions'
import GroupActions from '../../groups/actions'
import CourseActions from '../../courses/actions'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import SubmissionsHeader from '../SubmissionsHeader'
import defaultFilterOptions, { type SubmissionFilterOption, createFilter, joinTitles } from '../../filter/filter-options'
import Images from '../../../images'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'

type Props = SubmissionListProps & { navigator: Navigator } & RefreshProps
type State = {
  isConnected: boolean,
  filterOptions: SubmissionFilterOption[],
  filter: Function,
}

export class SubmissionList extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    let filterOptions = [ ...defaultFilterOptions(this.props.filterType), ...this.props.sections.map(createFilterFromSection) ]
    let filter = createFilter(filterOptions)

    this.state = {
      isConnected: true,
      filterOptions,
      filter,
    }
  }

  componentWillMount = () => {
    NetInfo.isConnected.fetch().then(this.setConnection)
    NetInfo.isConnected.addEventListener('change', this.setConnection)
  }

  componentWillUnmount = () => {
    NetInfo.isConnected.removeEventListener('change', this.setConnection)
  }

  componentWillReceiveProps = (newProps: Props) => {
    if (this.props.sections.length !== newProps.sections.length) {
      let filterOptions = [ ...this.state.filterOptions, ...newProps.sections.map(createFilterFromSection) ]
      let filter = createFilter(filterOptions)
      this.setState({
        filterOptions,
        filter,
      })
    }
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
      { filter: this.state.filter, studentIndex: index }
    )
  }

  navigateToContextCard = (userID: string) => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${userID}`,
      { modal: true },
    )
  }

  renderRow = ({ item, index }: { item: SubmissionProps, index: number }) => {
    return (
      <SubmissionRow
        {...item}
        onAvatarPress={!this.props.groupAssignment ? this.navigateToContextCard : undefined}
        onPress={this.navigateToSubmission(index)}
        anonymous={this.props.anonymous}
        gradingType={this.props.gradingType}
      />
    )
  }

  applyFilter = (filterOptions: Array<SubmissionFilterOption>): void => {
    this.setState({
      filterOptions,
      filter: createFilter(filterOptions),
    })
  }

  openSettings = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submission_settings`, {
      modal: true,
    })
  }

  messageStudentsWho = () => {
    var subject = ''
    let jointTitles = joinTitles(this.state.filterOptions)
    if (jointTitles) {
      subject = `${jointTitles} - ${this.props.assignmentName}`
    }

    this.props.navigator.show('/conversations/compose', { modal: true }, {
      recipients: this.state.filter(this.props.submissions).map((submission) => {
        return { id: submission.userID, name: submission.name, avatar_url: submission.avatarURL }
      }),
      subject: subject,
      contextName: this.props.courseName,
      contextCode: `course_${this.props.courseID}`,
      canAddRecipients: false,
      onlySendIndividualMessages: true,
    })
  }

  render () {
    return (
      <Screen
        title={i18n('Submissions')}
        subtitle={this.props.assignmentName}
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
              filterOptions={this.state.filterOptions}
              applyFilter={this.applyFilter}
              filterPromptMessage={i18n('Out of {points, number}', { points: this.props.pointsPossible })}
              initialFilterType={this.props.filterType}
              pointsPossible={this.props.pointsPossible}
              anonymous={this.props.anonymous}
              muted={this.props.muted}
              navigator={this.props.navigator}
            />
            <FlatList
              data={this.state.filter(this.props.submissions)}
              keyExtractor={this.keyExtractor}
              testID='submission-list'
              renderItem={this.renderRow}
              refreshing={this.props.refreshing}
              onRefresh={this.props.refresh}
              ItemSeparatorComponent={RowSeparator}
              ListFooterComponent={RowSeparator}
              ListEmptyComponent={
                <ListEmptyComponent title={i18n('No results')} />
              }
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
  props.refreshSections(props.courseID)
  props.getCourseEnabledFeatures(props.courseID)

  if (props.isMissingGroupsData || props.isGroupGradedAssignment) {
    props.refreshGroupsForCourse(props.courseID)
    props.refreshSubmissions(props.courseID, props.assignmentID, true)
  } else {
    props.refreshSubmissions(props.courseID, props.assignmentID, false)
    props.refreshEnrollments(props.courseID)
  }
}

export function shouldRefresh (props: SubmissionListProps): boolean {
  return props.submissions.every(({ submission }) => !submission) || props.sections.length === 0
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
  ...SectionActions,
  ...CourseActions,
})(Refreshed)
export default (Connected: Component<SubmissionListProps, any>)

function createFilterFromSection (section) {
  return {
    type: `section.${section.id}`,
    title: () => section.name,
    disabled: false,
    selected: false,
    exclusive: false,
    filterFunc: (submission) => {
      if (!submission || !submission.allSectionIDs) return false
      return submission.allSectionIDs.includes(section.id)
    },
  }
}
