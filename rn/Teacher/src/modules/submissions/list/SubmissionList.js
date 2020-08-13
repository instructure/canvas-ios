//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
} from 'react-native'
import type {
  SubmissionListProps,
  SubmissionProps,
} from './submission-prop-types'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import SubmissionsHeader from '../SubmissionsHeader'
import defaultFilterOptions, { type SubmissionFilterOption, createFilter, joinTitles, oldCreateFilter } from '../../filter/filter-options'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import { graphql } from 'react-apollo'
import query from '../../../canvas-api-v2/queries/SubmissionList'
import icon from '../../../images/inst-icons'
import ExperimentalFeature from '../../../common/ExperimentalFeature'
import { createStyleSheet } from '../../../common/stylesheet'
import localeSort from '../../../utils/locale-sort'

type Props = SubmissionListProps & { navigator: Navigator } & RefreshProps
type State = {
  filterOptions: SubmissionFilterOption[],
  filter: Function,
  didFetchFlags: boolean,
}

export class SubmissionList extends Component<Props, State> {
  constructor (props: Props) {
    super(props)
    let filterOptions = [ ...defaultFilterOptions(this.props.filterType), ...this.props.sections.map(createFilterFromSection) ]
    let filter = createFilter(filterOptions)

    this.state = {
      filterOptions,
      filter,
      refreshing: false,
      didFetchFlags: false,
    }
  }

  componentWillReceiveProps = (newProps: Props) => {
    let sectionsWithNoFilter = newProps.sections.filter(section => this.state.filterOptions.find(option => option.type === `section.${section.id}`) == null)
    if (sectionsWithNoFilter.length > 0) {
      let filterOptions = [ ...this.state.filterOptions, ...sectionsWithNoFilter.map(createFilterFromSection) ]
      let filter = createFilter(filterOptions)
      this.setState({
        filterOptions,
        filter,
      })
    }
  }

  keyExtractor = (item: SubmissionProps) => {
    return item.userID
  }

  navigateToSubmission = (index: number) => (userID: string) => {
    const path = `/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submissions/${userID}`
    let filter = ExperimentalFeature.graphqlSpeedGrader.isEnabled
      ? this.state.filter
      : oldCreateFilter(this.state.filterOptions)
    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      {
        filter: filter,
        studentIndex: index,
        onDismiss: this.refresh.bind(null, false),
      }
    )
  }

  navigateToContextCard = (userID: string) => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${userID}`,
      { modal: true },
    )
  }

  renderRow = ({ item, index }: { item: SubmissionProps, index: number }) => {
    let group
    if (this.props.isGroupGradedAssignment) {
      let userID = item.user.id
      group = this.props.groups.find(group => group.members.nodes.find(({ user }) => user.id === userID))
    }

    return (
      <SubmissionRow
        submission={item}
        user={item.user}
        group={group}
        onAvatarPress={!this.props.groupAssignment ? this.navigateToContextCard : undefined}
        onPress={this.navigateToSubmission(index)}
        anonymous={this.props.anonymous}
        gradingType={this.props.gradingType}
      />
    )
  }

  applyFilter = (filterOptions: Array<SubmissionFilterOption>): void => {
    let filter = createFilter(filterOptions)
    this.setState({
      filterOptions,
      filter,
    })
    this.props.refetch({
      assignmentID: this.props.assignmentID,
      ...filter,
    })
  }

  openPostPolicy = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/post_policy`, {
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
      recipients: this.props.submissions.map(({ user }) => user),
      subject: subject,
      contextName: this.props.courseName,
      contextCode: `course_${this.props.courseID}`,
      canAddRecipients: false,
      onlySendIndividualMessages: true,
    })
  }

  refresh = async (triggerRefreshIndicator = true) => {
    if (triggerRefreshIndicator) {
      this.setState({ refreshing: true })
    }
    await this.props.refetch({
      assignmentID: this.props.assignmentID,
      ...this.state.filter,
    })
    this.setState({ refreshing: false })
  }

  render () {
    let rightBarButtons = [
      {
        accessibilityLabel: i18n('Message students who'),
        image: icon('email', 'solid'),
        testID: 'submission-list.message-who-btn',
        action: this.messageStudentsWho,
        width: 20,
        height: 20,
      },
      {
        image: icon('eye', 'solid'),
        testID: 'SubmissionsList.postpolicy',
        action: this.openPostPolicy,
        accessibilityLabel: i18n('Grade post policy'),
        width: 20,
        height: 20,
      },
    ]

    return (
      <Screen
        title={i18n('Submissions')}
        subtitle={this.props.assignmentName}
        navBarColor={this.props.courseColor}
        navBarStyle='context'
        rightBarButtons={rightBarButtons}
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
              navigator={this.props.navigator}
            />
            <FlatList
              data={this.props.submissions}
              keyExtractor={this.keyExtractor}
              testID='submission-list'
              renderItem={this.renderRow}
              refreshing={this.state.refreshing}
              onRefresh={this.refresh}
              ItemSeparatorComponent={RowSeparator}
              ListFooterComponent={RowSeparator}
              ListEmptyComponent={
                <ListEmptyComponent title={i18n('No results')} />
              }
              windowSize={31}
            />
          </View>
        }
      </Screen>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,

  },
  header: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
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
    color: colors.textDarkest,
  },
  filterButton: {
    marginBottom: 1,
  },
}))

export function props (props) {
  if (props.data.loading) {
    return {
      isGroupGradedAssignment: false,
      pointsPossible: 100,
      pending: true,
      submissions: [],
      anonymous: false,
      gradingType: 'points',
      sections: [],
    }
  }

  let assignment = props.data.assignment
  let course = assignment.course
  let sections = course.sections.edges.map(({ section }) => section)
  let submissions = assignment.submissions && assignment.submissions.edges.map(({ submission }) => submission)

  let groupSet = assignment.groupSet
  let isGroupGradedAssignment = groupSet && groupSet.id && !assignment.gradeGroupStudentsIndividually
  let groups = groupSet?.groups.nodes ?? []
  let groupedSubmissions = assignment.groupedSubmissions?.edges
    .map(({ submission }) => submission)
    .sort((s1, s2) => {
      let group1 = groups.find(group => group.members.nodes.find(({ user }) => user.id === s1.user.id))
      let name1 = group1?.name ?? s1.user.name

      let group2 = groups.find(group => group.members.nodes.find(({ user }) => user.id === s2.user.id))
      let name2 = group2?.name ?? s2.user.name
      return localeSort(name1, name2)
    }) ?? []
  return {
    isGroupGradedAssignment,
    courseName: course.name,
    pointsPossible: assignment.pointsPossible,
    pending: false,
    submissions: isGroupGradedAssignment ? groupedSubmissions : submissions,
    anonymous: assignment.anonymousGrading,
    assignmentName: assignment.name,
    gradingType: assignment.gradingType,
    sections,
    groups,
    refetch: props.data.refetch,
  }
}

export default graphql(query, {
  options: ({ assignmentID, filterType }) => {
    let filterOptions = defaultFilterOptions(filterType)
    let filter = createFilter(filterOptions)
    return {
      variables: {
        assignmentID,
        ...filter,
      },
    }
  },
  fetchPolicy: 'cache-and-network',
  props,
})(SubmissionList)

export function createFilterFromSection (section) {
  return {
    type: `section.${section.id}`,
    title: () => section.name,
    disabled: false,
    selected: false,
    exclusive: false,
    getFilter: () => {
      return {
        sectionIDs: [section.id],
      }
    },
    // need this for speedgrader
    filterFunc: (submission) => {
      if (!submission || !submission.allSectionIDs) return false
      return submission.allSectionIDs.includes(section.id)
    },
  }
}
