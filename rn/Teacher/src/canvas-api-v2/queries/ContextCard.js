//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

export default gql`query StudentContextCard($courseID: ID!, $userID: ID!) {
  course: legacyNode(type: Course, _id: $courseID) {
    ... on Course {
      id: _id
      name
      permissions {
        becomeUser
        manageGrades
        sendMessages
        viewAllGrades
        viewAnalytics
      }
      users: usersConnection(userIds: [$userID]) {
        edges {
          user: node {
            id: _id
            name
            short_name: shortName
            avatar_url: avatarUrl
            primary_email: email
            enrollments(courseId: $courseID) {
              last_activity_at: lastActivityAt
              type
              section {
                name
              }
              grades {
                current_grade: currentGrade
                current_score: currentScore
                override_grade: overrideGrade
                override_score: overrideScore
                unposted_current_grade: unpostedCurrentGrade
                unposted_current_score: unpostedCurrentScore
              }
            }
            analytics: summaryAnalytics(courseId: $courseID) {
              pageViews {
                total
                max
                level
              }
              participations {
                total
                max
                level
              }
              tardinessBreakdown {
                late
                missing
                onTime
                total
              }
            }
          }
        }
      }

      submissions: submissionsConnection(
        orderBy: [{field: gradedAt, direction: descending}]
        studentIds: [$userID]
      ) {
        edges {
          submission: node {
            id
            score
            grade
            excused
            submission_status: submissionStatus
            grading_status: gradingStatus
            user {
              id: _id
            }
            assignment {
              id: _id
              name
              html_url: htmlUrl
              points_possible: pointsPossible
              grading_type: gradingType
              submission_types: submissionTypes
              state
            }
          }
        }
        pageInfo {
          hasNextPage
        }
      }
    }
  }
}`
