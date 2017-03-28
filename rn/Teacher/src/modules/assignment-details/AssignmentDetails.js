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
import { formattedDate } from '../../utils/dateUtils'
import { formattedDueDate } from '../../common/formatters'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import {
  View,
  StyleSheet,
  ScrollView,
} from 'react-native'

export class AssignmentDetails extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps

  componentDidMount () {
    if (!this.props.pending && !this.props.assignmentDetails) {
      this.props.refreshAssignmentDetails(this.props.courseID, this.props.assignmentID)
    }

    this.props.navigator.setTitle({
      title: i18n({
        default: 'Assignment Details',
        description: 'Title of Assignment details screen',
      }),
      subtitle: '',
      navigatorStyle: {
        navBarTextColor: '#fff',
        navBarSubtitleTextColor: '#fff',
      },
    })
  }

  render (): React.Element<View> {
    const assignment = this.props.assignmentDetails

    if (this.props.pending || !assignment) {
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

    let sectionTitleAvailable = i18n({
      default: 'Available',
      description: 'Assignment Details Section title for when assignment is available',
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

    return <ScrollView>
      <AssignmentSection isFirstRow={true} style={style.topContainer}>
      <Heading1>{assignment.name}</Heading1>

        <View style={style.pointsContainer}>
          <Text style={{ fontWeight: '500', fontSize: 16 }}>{assignment.points_possible} {assignmentPoints}</Text>
          <PublishedIcon published={assignment.published} style={style.publishedIcon} />
        </View>

      </AssignmentSection>

      <AssignmentSection title={sectionTitleDue}>
        <Text>{formattedDueDate(assignment)}</Text>
      </AssignmentSection>

      <AssignmentSection title={sectionTitleAvailable}>
        <Text style={style.container}>{this.formattedAvailableDate(assignment)}</Text>
      </AssignmentSection>

      <AssignmentSection title={sectionTitleSubmissionTypes}>
        <SubmissionType data={assignment.submission_types} />
      </AssignmentSection>

      <AssignmentSection title={sectionTitleSubmissions}>
        <Submission data={[assignment.needs_grading_count]} style={style.submission}/>
      </AssignmentSection>

      <AssignmentSection title={sectionTitleInstructions} >
        <WebContainer style={{ flex: 1 }} html={assignment.description}/>
      </AssignmentSection>

    </ScrollView>
  }

  formattedAvailableDate (assignment: Assignment): string {
    let lockAt = new Date(assignment.lock_at)
    let now = new Date()
    if (lockAt <= now) {
      return i18n({ default: 'Closed', description: 'Assignment is closed for submissions' })
    } else {
      let end = formattedDate(assignment.lock_at, 'LL')
      let start = formattedDate(assignment.unlock_at, 'LL')
      return `${start} - ${end}`
    }
  }
}

const PADDING = 16

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  topContainer: {
    paddingTop: 2,
    paddingLeft: PADDING,
    paddingRight: PADDING,
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
    marginTop: 10,
    marginBottom: -15,
  },
  publishedIcon: {
    marginLeft: 14,
  },
  submission: {
    marginRight: 40,
  },
})

const assignementDetailsShape = PropTypes.shape({
  id: PropTypes.number,
  name: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  created_at: PropTypes.string,
  updated_at: PropTypes.string,
  due_at: PropTypes.string,
  lock_at: PropTypes.string,
  unlock_at: PropTypes.string,
  has_overrides: PropTypes.bool,
  course_id: PropTypes.number,
  published: PropTypes.bool,
  unpublishable: PropTypes.bool,
})

AssignmentDetails.propTypes = {
  assignmentDetails: assignementDetailsShape,
  pending: PropTypes.number,
  error: PropTypes.string,
}

let Connected = connect(mapStateToProps, undefined)(AssignmentDetails)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
