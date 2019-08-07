// @flow
import gql from 'graphql-tag'

export default gql`query SubmissionList($assignmentID: ID!, $states: [SubmissionState!], $late: Boolean, $scoredMoreThan: Float, $scoredLessThan: Float, $sectionIDs: [ID!], $gradingStatus: SubmissionGradingStatus) {
  assignment(id: $assignmentID) {
    name
    pointsPossible
    gradeGroupStudentsIndividually
    anonymousGrading
    muted
    gradingType

    groupSet {
      id
    }

    course {
      name

      groups: groupsConnection {
        edges {
          group: node {
            id: _id
            name
            members: membersConnection {
              edges {
                member: node {
                  user {
                    id: _id
                  }
                }
              }
            }
          }
        }
      }

      sections: sectionsConnection {
        edges{
          section: node {
            id: _id
            name
          }
        }
      }
    }

    submissions: submissionsConnection(
      filter: {
        states: $states
        late: $late
        scoredMoreThan: $scoredMoreThan
        scoredLessThan: $scoredLessThan
        sectionIds: $sectionIDs
        gradingStatus: $gradingStatus
      }
      orderBy: {
        field: username
      }
    ) {
      edges {
        submission: node {
          grade
          late
          missing
          excused
          submittedAt
          gradingStatus
          gradeMatchesCurrentSubmission
          state

          user {
            id: _id
            avatarUrl
            name
          }
        }
      }
    }

    groupedSubmissions: groupSubmissionsConnection(
      filter: {
        states: $states
        late: $late
        scoredMoreThan: $scoredMoreThan
        scoredLessThan: $scoredLessThan
        sectionIds: $sectionIDs
        gradingStatus: $gradingStatus
      }
      orderBy: {
        field: username
      }
    ) {
      edges {
        submission: node {
          grade
          late
          missing
          excused
          submittedAt
          gradingStatus
          gradeMatchesCurrentSubmission
          state

          user {
            id: _id
          }
        }
      }
    }
  }
}`
