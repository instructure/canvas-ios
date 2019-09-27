//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
          submissionType

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

          turnitinData {
            target {
              __typename
              ...on Submission {
                _id
              }
              ...on File {
                _id
              }
            }
            status
            score
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
                submissionType

                attachments {
                  id
                  _id
                  url
                  displayName
                  thumbnailUrl
                  mimeClass
                }

                turnitinData {
                  target {
                    __typename
                    ...on Submission {
                      _id
                    }
                    ...on File {
                      _id
                    }
                  }
                  status
                  score
                }
              }
            }
          }
        }
      }
    }
  }
}`
