/**
* @flow
*/

import React, { Component, PropTypes } from 'react'
import { connect } from 'react-redux'
import { mapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import Submission from './components/Submission'
import SubmissionType from './components/SubmissionType'
import AssignmentSection from './components/AssignmentSection'
import i18n from 'format-message'
import { Heading1, Text } from '../../common/text'
import WebContainer from '../../common/components/WebContainer'
import PublishedIcon from './components/PublishedIcon'
import AssignmentDates from './components/AssignmentDates'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import colors from '../../common/colors'
import { RefreshableScrollView } from '../../common/components/RefreshableList'
import refresh from '../../utils/refresh'
import AssignmentActions from '../assignments/actions'
import { route } from '../../routing'
import Images from '../../images'

const { V02 } = global

import {
  View,
  StyleSheet,
} from 'react-native'

export class AssignmentDetails extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Edit',
          description: 'Shown at the top of the app to allow the user to edit',
        }),
        id: 'edit',
        testID: 'e2e_rules',
      },
    ],
  }

  constructor (props: AssignmentDetailsProps) {
    super(props)
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  componentDidMount () {
    if (!this.props.pending && !this.props.assignmentDetails) {
      this.props.refreshAssignmentDetails(this.props.courseID, this.props.assignmentID)
    }

    this.props.navigator.setTitle({
      title: i18n({
        default: 'Assignment Details',
        description: 'Title of Assignment details screen',
      }),
    })
  }

  render (): React.Element<View> {
    const assignment = this.props.assignmentDetails

    if (!this.props.refreshing && (this.props.pending || !assignment)) {
      return (<View style={style.loadingContainer}><ActivityIndicatorView height={44} /></View>)
    }

    let assignmentPoints = i18n({
      default: 'pts',
      description: 'Assignment Details points for given assignment',
    })

    let sectionTitleDue = i18n({
      default: 'Due',
      description: 'Assignment Details Section title for when assignment is due',
    })

    let sectionTitleSubmissionTypes = i18n({
      default: 'Submission Types',
      description: 'Assignment Details Section title for types of submission, (i.e. online, text, upload, etc)',
    })

    let sectionTitleSubmissions = i18n({
      default: 'Submissions',
      description: 'Assignment Details Section title for info on submissions',
    })

    let sectionTitleInstructions = i18n({
      default: 'Instructions',
      description: 'Assignment Details Section title for assignment instructions',
    })

    let descriptionElement = <View />
    if (assignment.description) {
      descriptionElement = (<AssignmentSection title={sectionTitleInstructions} >
                              <WebContainer style={{ flex: 1 }} html={assignment.description}/>
                            </AssignmentSection>)
    }

    return (
      <RefreshableScrollView
        refreshing={this.props.refreshing}
        onRefresh={this.props.refresh}
      >
        <AssignmentSection isFirstRow={true} style={style.topContainer}>
        <Heading1>{assignment.name}</Heading1>

        <View style={style.pointsContainer}>
          <Text style={style.points}>{assignment.points_possible} {assignmentPoints}</Text>
          <PublishedIcon published={assignment.published} style={style.publishedIcon} />
        </View>

        </AssignmentSection>

        <AssignmentSection
          title={sectionTitleDue}
          image={Images.assignments.calendar}
          showDisclosureIndicator={true}
          onPress={this.viewDueDateDetails} >
          <AssignmentDates assignment={assignment} />
        </AssignmentSection>

        <AssignmentSection title={sectionTitleSubmissionTypes}>
          <SubmissionType data={assignment.submission_types} />
        </AssignmentSection>

        <AssignmentSection
          title={sectionTitleSubmissions}
          onPress={this.viewSubmissions}
          showDisclosureIndicator>
          <Submission data={[assignment.needs_grading_count]} style={style.submission}/>
        </AssignmentSection>

        {descriptionElement}

      </RefreshableScrollView>
    )
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'edit':
            this.editAssignment()
            break
        }
        break
    }
  }

  editAssignment () {
    let destination = route(`/courses/${this.props.courseID}/assignments/${this.props.assignmentDetails.id}/edit`)
    this.props.navigator.showModal({
      ...destination,
      animationType: 'slide-up',
    })
  }

  viewDueDateDetails = () => {
    let destination = route(`/courses/${this.props.courseID}/assignments/${this.props.assignmentDetails.id}/due_dates`)
    this.props.navigator.push(destination)
  }

  viewSubmissions = () => {
    if (V02) {
      const { courseID, assignmentDetails } = this.props
      let destination = route(`/courses/${courseID}/assignments/${assignmentDetails.id}/submissions`)
      this.props.navigator.push(destination)
    }
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  topContainer: {
    paddingTop: 2,
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
  submission: {
    marginRight: 40,
  },
  points: {
    fontSize: 16,
    fontFamily: '.SFUIDisplay-medium',
    color: colors.grey4,
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

let Refreshed = refresh(
  props => props.refreshAssignmentList(props.courseID),
  props => !props.assignmentDetails,
  props => Boolean(props.pending)
)(AssignmentDetails)
let Connected = connect(mapStateToProps, AssignmentActions)(Refreshed)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
