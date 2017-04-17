/**
 * @flow
 */

import { Alert } from 'react-native'
import React from 'react'
import AssignmentDatesEditor from '../AssignmentDatesEditor'
import renderer from 'react-test-renderer'

jest.mock('../../../../routing')

jest.mock('Alert', () => {
  return {
    alert: jest.fn(),
  }
})

const template = {
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../__templates__/react-native-navigation'),
  ...require('../../../assignee-picker/__template__/Assignee'),
  ...require('../__template__/StagedAssignmentDate'),
}

type StagedAssignmentDate = {
  id: string, // Will be the id, or base if it's a base date for everyone. If it's a new date, will have a uuid
  isNew?: boolean, // Is it a new date, meaning it hasn't been pushed to the server yet
  base: boolean,
  title?: string,
  due_at?: ?string,
  unlock_at?: ?string,
  lock_at?: ?string,
  student_ids?: ?string[],
  course_section_id?: ?string,
  group_id?: ?string,
  valid: boolean,
}

beforeEach(() => {
  jest.resetAllMocks()
})

describe('function tests', () => {
  it('assigneesFromDate should work', () => {
    let base: StagedAssignmentDate = {
      id: 'base',
      base: true,
      valid: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(base)).toMatchObject([{
      id: 'everyone',
      type: 'everyone',
      dataId: 'everyone',
      name: 'Everyone',
    }])

    let studentIds: StagedAssignmentDate = {
      id: '2343',
      base: false,
      student_ids: ['34234'],
      valid: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(studentIds)).toMatchObject([{
      dataId: '34234',
      id: 'student-34234',
      name: 'student',
      type: 'student',
    }])

    let section: StagedAssignmentDate = {
      id: '2343',
      base: false,
      course_section_id: '23432',
      valid: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(section)).toMatchObject([{
      dataId: '23432',
      id: 'section-23432',
      name: 'Section',
      type: 'section',
    }])

    let group: StagedAssignmentDate = {
      id: '2343',
      base: false,
      group_id: '23432',
      valid: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(group)).toMatchObject([{
      dataId: '23432',
      id: 'group-23432',
      name: 'Group',
      type: 'group',
    }])
  })

  it('assigneesFromDate should work', () => {
    // $FlowFixMe
    let assignment: Assignment = {
      id: '12345',
    }
    let date = '2017-07-01T05:59:00Z'
    let base: StagedAssignmentDate = {
      id: 'base',
      base: true,
      valid: true,
      due_at: date,
      lock_at: date,
      unlock_at: date,
    }

    expect(AssignmentDatesEditor.updateAssignmentWithDates(assignment, [base])).toMatchObject({
      id: assignment.id,
      due_at: date,
      lock_at: date,
      unlock_at: date,
      overrides: [],
    })

    let studentIds: StagedAssignmentDate = {
      id: '12345',
      base: false,
      valid: true,
      due_at: date,
      lock_at: date,
      unlock_at: date,
      student_ids: ['12345'],
    }

    expect(AssignmentDatesEditor.updateAssignmentWithDates(assignment, [studentIds])).toMatchObject({
      id: assignment.id,
      overrides: [{
        due_at: date,
        unlock_at: date,
        lock_at: date,
        student_ids: ['12345'],
        id: '12345',
      }],
    })

    let section: StagedAssignmentDate = {
      id: '12345',
      base: false,
      valid: true,
      due_at: date,
      lock_at: date,
      unlock_at: date,
      course_section_id: '12345',
    }

    expect(AssignmentDatesEditor.updateAssignmentWithDates(assignment, [section])).toMatchObject({
      id: assignment.id,
      overrides: [{
        due_at: date,
        unlock_at: date,
        lock_at: date,
        course_section_id: '12345',
        id: '12345',
      }],
    })

    let group: StagedAssignmentDate = {
      id: '12345',
      base: false,
      valid: true,
      due_at: date,
      lock_at: date,
      unlock_at: date,
      group_id: '12345',
    }

    expect(AssignmentDatesEditor.updateAssignmentWithDates(assignment, [group])).toMatchObject({
      id: assignment.id,
      overrides: [{
        due_at: date,
        unlock_at: date,
        lock_at: date,
        group_id: '12345',
        id: '12345',
      }],
    })

    expect(AssignmentDatesEditor.updateAssignmentWithDates(assignment, [section, studentIds])).toMatchObject({
      id: assignment.id,
      overrides: [{
        due_at: date,
        unlock_at: date,
        lock_at: date,
        course_section_id: '12345',
        id: '12345',
      },
      {
        due_at: date,
        unlock_at: date,
        lock_at: date,
        student_ids: ['12345'],
        id: '12345',
      }],
    })
  })

  test('updateDateWithAssignees should work', () => {
    let everyone = template.everyoneAssignee()
    let date = template.stagedAssignmentDate()
    let result = AssignmentDatesEditor.updateDateWithAssignees(date, [everyone])
    expect(result).toMatchObject([{
      base: true,
      id: 'base',
      title: 'Everyone',
      'valid': true,
    }])

    let section = template.sectionAssignee()
    let group = template.groupAssignee()

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [section])
    expect(result).toMatchObject([{
      base: false,
      course_section_id: '1234',
      valid: true,
    }])

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [group])
    expect(result).toMatchObject([{
      base: false,
      group_id: '1234',
      valid: true,
    }])

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [])
    expect(result).toMatchObject([{
      base: false,
      valid: false,
    }])
  })

  test('updateDateWithAssignees should work with multiple sections', () => {
    let date = template.stagedAssignmentDate()
    let sectionOne = template.sectionAssignee({
      dataId: '12345',
    })

    let sectionTwo = template.sectionAssignee({
      dataId: '111111',
    })

    let assignees = [sectionOne, sectionTwo]
    let result = AssignmentDatesEditor.updateDateWithAssignees(date, assignees)
    expect(result).toMatchObject([{
      base: false,
      valid: true,
      course_section_id: '12345',
    },
    {
      base: false,
      valid: true,
      course_section_id: '111111',
    },
    ])
  })

  test('updateDateWithAssignees should work with multiple everything', () => {
    let date = template.stagedAssignmentDate()
    let sectionOne = template.sectionAssignee({
      dataId: '12345',
    })

    let sectionTwo = template.sectionAssignee({
      dataId: '111111',
    })

    let groupOne = template.groupAssignee({
      dataId: '222222',
    })

    let groupTwo = template.groupAssignee({
      dataId: '333333',
    })

    let studentOne = template.enrollmentAssignee({
      dataId: '444444',
    })

    let studentTwo = template.enrollmentAssignee({
      dataId: '555555',
    })

    let everyone = template.everyoneAssignee()

    let assignees = [sectionOne, sectionTwo, groupOne, groupTwo, studentOne, studentTwo, everyone]
    let result = AssignmentDatesEditor.updateDateWithAssignees(date, assignees)
    expect(result[0]).toMatchObject({
      base: true,
      id: 'base',
      valid: true,
    })

    expect(result[1]).toMatchObject({
      base: false,
      valid: true,
      student_ids: ['444444', '555555'],
    })

    expect(result[2]).toMatchObject({
      base: false,
      valid: true,
      course_section_id: '12345',
    })

    expect(result[3]).toMatchObject({
      base: false,
      valid: true,
      course_section_id: '111111',
    })

    expect(result[4]).toMatchObject({
      base: false,
      valid: true,
      group_id: '222222',
    })

    expect(result[5]).toMatchObject({
      base: false,
      valid: true,
      group_id: '333333',
    })
  })

  test('removing dates should work', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' }), template.assignmentDueDate({ base: false, id: '98765' })],
    })
    let editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    let onPress = jest.fn()
    Alert.alert = jest.fn((title, message, buttons) => {
      onPress = buttons[0].onPress
    })

    let dateOne = editor.state.dates[0]
    let dateTwo = editor.state.dates[1]
    editor.removeDate(dateTwo)
    onPress()
    expect(editor.state.dates.length).toEqual(1)
    editor.removeDate(dateOne)
    onPress()
    expect(editor.state.dates.length).toEqual(1)
  })
})

describe('snapshots!', () => {
  test('render with multiple due dates', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true }), template.assignmentDueDate({ base: false })],
    })
    let tree = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  test('render with single due date', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true })],
    })
    let tree = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  test('doing stuff with selecting assignees', () => {
    let callback = () => {}
    const showModal = jest.fn(({ passProps }) => {
      callback = passProps.callback
    })

    const navigator = template.navigator({
      showModal,
    })
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true })],
    })
    let tree = renderer.create(
      <AssignmentDatesEditor assignment={assignment} navigator={navigator} />
    )
    let editor = tree.getInstance()
    let date = editor.state.dates[0]
    editor.selectAssignees(date)
    expect(showModal).toHaveBeenCalled()
    let student = template.enrollmentAssignee()
    let section = template.sectionAssignee()
    let group = template.groupAssignee()
    callback([student, section, group])
    expect(tree.toJSON()).toMatchSnapshot()
  })
})
