/* @flow */

import { mapStateToProps, type AssignmentListProps } from '../map-state-to-props'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

test('map state to props should work', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()

  let state: AppState = {
    entities: {
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
          course: course,
        },
      },
      assignmentGroups: {
        [assignmentGroup.id]: assignmentGroup,
      },
    },
    favoriteCourses: [],
  }

  let props: AssignmentListProps = {
    courseID: course.id.toString(),
    course: {
      course,
      color: '#fff',
    },
    assignmentGroups: [],
    refreshAssignmentList: jest.fn(),
    nextPage: jest.fn(),
    pending: 0,
    navigator: template.navigator(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentGroups: [{
      assignments: [{
        id: 123455432,
        name: 'Assignments',
      }],
      id: 1,
      name: 'Learn React Native',
      position: 1,
    }],
    course: {
      assignmentGroups: {
        refs: [1],
      },
      course: {
        course_code: 'rn 101',
        id: 1,
        image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
        is_favorite: true,
        name: 'Learn React Native',
        short_name: 'rn',
      },
    },
    refs: [1],
  })
})
