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
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { mapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import SubmissionBreakdownGraphSection from './components/SubmissionBreakdownGraphSection'
import SubmissionType from './components/SubmissionType'
import AssignmentSection from './components/AssignmentSection'
import i18n from 'format-message'
import { Heading1, Text } from '../../common/text'
import WebContainer from '../../common/components/WebContainer'
import DescriptionDefaultView from '../../common/components/DescriptionDefaultView'
import PublishedIcon from './components/PublishedIcon'
import AssignmentDates from './components/AssignmentDates'
import colors from '../../common/colors'
import { RefreshableScrollView } from '../../common/components/RefreshableList'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'
import refresh from '../../utils/refresh'
import AssignmentActions from '../assignments/actions'
import Images from '../../images'
import Screen from '../../routing/Screen'
import RCTSFSafariViewController from 'react-native-sfsafariviewcontroller'
import { getSessionlessLaunchURL } from 'canvas-api'
import { ERROR_TITLE, parseErrorMessage } from '../../redux/middleware/error-handler'

import {
  View,
  StyleSheet,
  TouchableOpacity,
  TouchableHighlight,
  Alert,
} from 'react-native'

export class AssignmentDetails extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps

  render () {
    const assignment = this.props.assignmentDetails

    let assignmentPoints = i18n('pts')

    let sectionTitleDue = i18n('Due')

    let sectionTitleSubmissionTypes = i18n('Submission Types')

    let sectionTitleSubmissions = i18n('Submissions')

    let submissionTypes = assignment.submission_types || []
    let noSubmissions = submissionTypes.includes('none')
    let noSubmissionsMessage = i18n('Tap to view submissions list.')
    let submissionContainerAccessibilityTraits = noSubmissions ? {
      accessibilityTraits: 'button',
      accessibilityLabel: noSubmissionsMessage,
      accessible: noSubmissions,
    } : {}

    const isExternalTool = submissionTypes.includes('external_tool')

    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        title={i18n('Assignment Details')}
        subtitle={this.props.courseName}
        testID='assignment-details'
        rightBarButtons={[
          {
            title: i18n('Edit'),
            testID: 'assignment-details.edit-btn',
            action: this.editAssignment,
          },
        ]}
      >
        <RefreshableScrollView
          refreshing={Boolean(this.props.pending)}
          onRefresh={this.props.refresh}
        >
          <AssignmentSection isFirstRow={true} style={style.topContainer}>
            <Heading1 testID='assignment-details.assignment-name-lbl'>{assignment.name}</Heading1>
            <View style={style.pointsContainer}>
              <Text style={style.points} testID='assignment-details.points-possible-lbl'>{assignment.points_possible} {assignmentPoints}</Text>
              <PublishedIcon published={assignment.published} style={style.publishedIcon} />
            </View>
          </AssignmentSection>

          <AssignmentSection
            title={sectionTitleDue}
            accessibilityLabel={i18n('Due Dates, Double tap for details.')}
            testID='assignment-details.assignment-section.due'
            image={Images.assignments.calendar}
            showDisclosureIndicator={true}
            onPress={this.viewDueDateDetails}>
            <AssignmentDates assignment={assignment}/>
          </AssignmentSection>

          <AssignmentSection
           title={sectionTitleSubmissionTypes}
           testID='assignment-details.assignment-section.submission-type'
           onPress={isExternalTool && this.launchExternalTool}
           showDisclosureIndicator={isExternalTool}
         >
            <SubmissionType data={assignment.submission_types} />
          </AssignmentSection>

          <View style={style.section}>
            <Text style={style.header} testID='assignment-details.assignment-section.submissions-title-lbl'>{sectionTitleSubmissions}</Text>
            <View style={style.submissions} {...submissionContainerAccessibilityTraits}>
              <View style={{ flex: 1, justifyContent: 'flex-start', flexDirection: 'row' }}>
                <SubmissionBreakdownGraphSection submissionTypes={assignment.submission_types} onPress={this.onSubmissionDialPress} courseID={this.props.courseID} assignmentID={this.props.assignmentID} style={style.submission}/>
              </View>
              <TouchableOpacity
                testID='assignment-details.assignment-section.submissions'
                accessibilityLabel={i18n('View all submissions')}
                accessibilityTraits='button'
                accessible={!noSubmissions}
                onPress={() => this.viewSubmissions()}
                style={{
                  justifyContent: 'center',
                  width: 44,
                  alignItems: 'flex-end',
                  marginTop: 8,
                  marginBottom: 8,
                }}
              >
                <DisclosureIndicator />
              </TouchableOpacity>
            </View>
          </View>

          <View style={style.section}>
            <Text style={style.header} testID='assignment-details.description-section-title-lbl'>{i18n('Description')}</Text>
            {this.checkAssignmentDescription(assignment.description)}
          </View>

          { isExternalTool &&
            <TouchableHighlight
              onPress={this.launchExternalTool}
              style={style.launchExternalToolButton}
              accessible={true}
              accessibilityLabel={i18n('Launch External Tool')}
              accessibilityTraits='button'
              testID='assignment-details.launch-external-tool.button'
            >
              <View style={style.launchExternalToolButtonContainer}>
                <Text style={style.launchExternalToolButtonTitle}>{i18n('Launch External Tool')}</Text>
              </View>
            </TouchableHighlight>
          }

        </RefreshableScrollView>
      </Screen>
    )
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  editAssignment = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentDetails.id}/edit`, { modal: true })
  }

  viewDueDateDetails = () => {
    const route = `/courses/${this.props.courseID}/assignments/${this.props.assignmentDetails.id}/due_dates`
    this.props.navigator.show(route, { modal: false })
  }

  viewAllSubmissions = () => {
    this.viewSubmissions()
  }

  viewSubmissions = (filterType: ?string) => {
    const { courseID, assignmentDetails } = this.props
    if (filterType) {
      this.props.navigator.show(`/courses/${courseID}/assignments/${assignmentDetails.id}/submissions`, { modal: false }, { filterType })
    } else {
      this.props.navigator.show(`/courses/${courseID}/assignments/${assignmentDetails.id}/submissions`)
    }
  }

  checkAssignmentDescription (description: ?string) {
    if (description) {
      return (<WebContainer style={{ flex: 1 }} html={description} testID='assignment-details.description-section-info-lbl' scrollEnabled={false} navigator={this.props.navigator}/>)
    } else {
      return (<DescriptionDefaultView testID='assignment-details.description-default-view'/>)
    }
  }

  launchExternalTool = async () => {
    try {
      const url = await this.props.getSessionlessLaunchURL(this.props.courseID, {
        assignment: this.props.assignmentDetails,
      })
      url && RCTSFSafariViewController.open(url)
    } catch (e) {
      Alert.alert(ERROR_TITLE, parseErrorMessage(e))
    }
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  topContainer: {
    paddingTop: 14,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: 17,
  },
  loadingContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  pointsContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  publishedIcon: {
    marginLeft: 14,
  },
  submissions: {
    flex: 1,
    flexDirection: 'row',
  },
  submission: {
    marginTop: global.style.defaultPadding / 2,
  },
  points: {
    fontWeight: '500',
    color: colors.grey4,
  },
  header: {
    color: colors.grey4,
    fontWeight: '500',
    fontSize: 16,
    marginBottom: 4,
  },
  section: {
    flex: 1,
    paddingTop: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
    backgroundColor: 'white',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.grey2,
  },
  launchExternalToolButton: {
    flex: 1,
    backgroundColor: '#008EE2',
    height: 51,
    borderRadius: 4,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding,
    marginLeft: global.style.defaultPadding,
    marginRight: global.style.defaultPadding,
  },
  launchExternalToolButtonContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 4,
    backgroundColor: '#008EE2',
  },
  launchExternalToolButtonTitle: {
    color: 'white',
    fontWeight: '600',
  },
})

const assignementDetailsShape = PropTypes.shape({
  id: PropTypes.string,
  name: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  created_at: PropTypes.string,
  updated_at: PropTypes.string,
  due_at: PropTypes.string,
  lock_at: PropTypes.string,
  unlock_at: PropTypes.string,
  has_overrides: PropTypes.bool,
  course_id: PropTypes.string,
  published: PropTypes.bool,
  unpublishable: PropTypes.bool,
})

AssignmentDetails.propTypes = {
  assignmentDetails: assignementDetailsShape,
  pending: PropTypes.number,
  error: PropTypes.string,
}

const mergeProps = (stateProps, dispatchProps, ownProps) => ({
  ...stateProps,
  ...dispatchProps,
  ...ownProps,
  getSessionlessLaunchURL,
})

let Refreshed = refresh(
  props => props.refreshAssignmentDetails(props.courseID, props.assignmentID),
  props => !props.assignmentDetails,
  props => Boolean(props.pending)
)(AssignmentDetails)
let Connected = connect(mapStateToProps, AssignmentActions, mergeProps)(Refreshed)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
