import gql from 'graphql-tag'

export default gql`query SpeedGrader($assignmentID: ID!, $states: [SubmissionState!], $late: Boolean, $scoredMoreThan: Float, $scoredLessThan: Float, $sectionIDs: [ID!], $gradingStatus: SubmissionGradingStatus) {
  assignment(id: $assignmentID) {
    gradeGroupStudentsIndividually
    anonymizeStudents
    submissionTypes

    groupSet {
      id
    }

    course {
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
          id
          _id
          missing
          late
          state
          submittedAt
          attempt

          attachments {
            id
            _id
            url
            displayName
            thumbnailUrl
            mimeClass
          }

          user {
            id: _id
            name
            avatarUrl
          }

          comments: commentsConnection(filter: { allComments: true }) {
            nodes {
              _id
              createdAt
              comment

              author {
                _id
                name
                avatarUrl
              }

              mediaObject {
                _id
                mediaType
                title

                mediaSources {
                  url
                }
              }
            }
          }

          submissionHistory: submissionHistoriesConnection {
            edges {
              submission: node {
                rootId
                missing
                late
                state
                submittedAt
                attempt

                attachments {
                  id
                  _id
                  url
                  displayName
                  thumbnailUrl
                  mimeClass
                }
              }
            }
          }
        }
      }
    }
  }
}`
