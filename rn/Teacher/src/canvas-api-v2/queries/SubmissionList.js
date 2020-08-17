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

// @flow
import gql from 'graphql-tag'

export default gql`query SubmissionList($assignmentID: ID!, $states: [SubmissionState!], $late: Boolean, $scoredMoreThan: Float, $scoredLessThan: Float, $sectionIDs: [ID!], $gradingStatus: SubmissionGradingStatus) {
  assignment(id: $assignmentID) {
    id
    name
    pointsPossible
    gradeGroupStudentsIndividually
    anonymousGrading
    gradingType

    groupSet {
      id
      groups: groupsConnection {
        nodes {
          id: _id
          name
          members: membersConnection {
            nodes {
              user {
                id: _id
              }
            }
          }
        }
      }
    }

    course {
      name

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
          score
          late
          missing
          excused
          submittedAt
          gradingStatus
          gradeMatchesCurrentSubmission
          state
          postedAt

          user {
            id: _id
            avatarUrl
            name
            pronouns
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
          score
          late
          missing
          excused
          submittedAt
          gradingStatus
          gradeMatchesCurrentSubmission
          state
          postedAt

          user {
            id: _id
            avatarUrl
            name
          }
        }
      }
    }
  }
}`
