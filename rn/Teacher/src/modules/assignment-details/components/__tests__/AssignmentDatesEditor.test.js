//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { Alert } from 'react-native'
import React from 'react'
import AssignmentDatesEditor, { type StagedAssignmentDate } from '../AssignmentDatesEditor'
import renderer from 'react-test-renderer'

jest.mock('../../../../routing')
jest.mock('LayoutAnimation')

jest.mock('Alert', () => {
  return {
    alert: jest.fn(),
  }
})

const template = {
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../assignee-picker/__template__/Assignee'),
  ...require('../__template__/StagedAssignmentDate'),
}

beforeEach(() => {
  jest.resetAllMocks()
})

describe('function tests', () => {
  it('assigneesFromDate should work', () => {
    let base: StagedAssignmentDate = {
      id: 'base',
      base: true,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(studentIds)).toMatchObject([{
      dataId: '34234',
      id: 'student-34234',
      name: '--',
      type: 'student',
    }])

    let section: StagedAssignmentDate = {
      id: '2343',
      base: false,
      course_section_id: '23432',
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(section)).toMatchObject([{
      dataId: '23432',
      id: 'section-23432',
      name: '--',
      type: 'section',
    }])

    let group: StagedAssignmentDate = {
      id: '2343',
      base: false,
      group_id: '23432',
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }

    expect(AssignmentDatesEditor.assigneesFromDate(group)).toMatchObject([{
      dataId: '23432',
      id: 'group-23432',
      name: '--',
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }])

    let section = template.sectionAssignee()
    let group = template.groupAssignee()

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [section])
    expect(result).toMatchObject([{
      base: false,
      course_section_id: '1234',
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }])

    // Anytime there are updated dates from assignees, the ids should be different
    expect(result[0].id).not.toEqual(date.id)

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [group])
    expect(result).toMatchObject([{
      base: false,
      group_id: '1234',
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    }])

    result = AssignmentDatesEditor.updateDateWithAssignees(date, [])
    expect(result).toMatchObject([{
      base: false,
      validAssignees: false,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
      course_section_id: '12345',
    },
    {
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
    })

    expect(result[1]).toMatchObject({
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
      student_ids: ['444444', '555555'],
    })

    expect(result[2]).toMatchObject({
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
      course_section_id: '12345',
    })

    expect(result[3]).toMatchObject({
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
      course_section_id: '111111',
    })

    expect(result[4]).toMatchObject({
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
      group_id: '222222',
    })

    expect(result[5]).toMatchObject({
      base: false,
      validAssignees: true,
      validDueDate: true,
      validLockDates: true,
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
    // $FlowFixMe
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

  test('modify date type should work', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' }), template.assignmentDueDate({ base: false, id: '98765' })],
    })
    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    const dateOne = editor.state.dates[0]
    // let dateTwo = editor.state.dates[1]
    editor.modifyDate(dateOne, 'due_at')
    expect(editor.state.dates[0]).toMatchObject({
      modifyType: 'due_at',
    })

    editor.modifyDate(dateOne, 'due_at')
    expect(editor.state.dates[0]).toMatchObject({
      modifyType: 'none',
    })
  })

  test('remove date type should work', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' }), template.assignmentDueDate({ base: false, id: '98765' })],
    })
    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    const dateOne = editor.state.dates[0]
    editor.removeDateType(dateOne, 'due_at')
    expect(editor.state.dates[0]).toMatchObject({
      due_at: null,
    })
  })

  test('update date should work', () => {
    const assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' }), template.assignmentDueDate({ base: false, id: '98765' })],
    })
    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    const dateOne = editor.state.dates[0]
    const now = new Date()
    editor.updateDate(dateOne, 'due_at', now)
    expect(editor.state.dates[0]).toMatchObject({
      due_at: now.toISOString(),
    })
  })

  test('check DueDates should work', () => {
    var assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' })],
    })
    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    expect(editor.checkDueDate(editor.state.dates[0])).toBeTruthy()

    assignment.all_dates = [template.assignmentDueDate({
      due_at: '2017-06-01T07:59:00Z',
      lock_at: '2017-06-01T05:59:00Z',
    })]
    expect(editor.checkDueDate(assignment.all_dates[0])).toBeFalsy()

    assignment.all_dates = [template.assignmentDueDate({
      due_at: null,
      unlock_at: '2017-06-01T05:59:00Z',
      lock_at: '2017-06-01T07:59:00Z',
    })]
    expect(editor.checkDueDate(assignment.all_dates[0])).toBeTruthy()
  })

  test('check LockDates should work', () => {
    var assignment = template.assignment({
      all_dates: [template.assignmentDueDate({ base: true, id: 'base' })],
    })
    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()

    expect(editor.checkLockDates(editor.state.dates[0])).toBeTruthy()

    assignment.all_dates = [template.assignmentDueDate({
      due_at: '2017-06-01T07:59:00Z',
      lock_at: null,
      unlock_at: null,
    })]
    expect(editor.checkLockDates(assignment.all_dates[0])).toBeTruthy()

    assignment.all_dates = [template.assignmentDueDate({
      due_at: '2017-06-01T07:59:00Z',
      lock_at: '2017-06-01T05:59:00Z',
      unlock_at: null,
    })]
    expect(editor.checkLockDates(assignment.all_dates[0])).toBeTruthy()

    assignment.all_dates = [template.assignmentDueDate({
      due_at: null,
      unlock_at: '2017-06-01T07:59:00Z',
      lock_at: '2017-06-01T05:59:00Z',
    })]
    expect(editor.checkLockDates(assignment.all_dates[0])).toBeFalsy()
  })

  test('validator should be false with no assignees', () => {
    const assignment = template.assignment({
      all_dates: [{
        ...template.assignmentDueDate({ base: false, id: 'none' }),
        student_ids: null,
        course_section_id: null,
        group_id: null,
      }],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validAssignees).toBeFalsy()
  })

  test('validator should be false when due date is after lock date in base', () => {
    const assignment = template.assignment({
      all_dates: [{
        ...template.assignmentDueDate({
          base: true,
          id: 'none',
          due_at: '2017-06-01T07:59:00Z',
          lock_at: '2017-06-01T05:59:00Z',
        }),
      }],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validDueDate).toBeFalsy()
  })

  test('validator should be false when due date is before unlock date', () => {
    const assignment = template.assignment({
      all_dates: [{
        ...template.assignmentDueDate({
          base: true,
          id: 'none',
          due_at: '2017-06-01T05:59:00Z',
          unlock_at: '2017-06-01T07:59:00Z',
        }),
      }],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validDueDate).toBeFalsy()
  })

  test('validator should be false when lock date is before unlock date', () => {
    const assignment = template.assignment({
      all_dates: [{
        ...template.assignmentDueDate({
          base: true,
          id: 'none',
          lock_at: '2017-06-01T05:59:00Z',
          unlock_at: '2017-06-01T07:59:00Z',
        }),
      }],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validLockDates).toBeFalsy()
  })

  test('validator should be false when unlock date is after lock date not base', () => {
    const assignment = template.assignment({
      overrides: [
        {
          id: '1',
          group_id: '1',
          course_section_id: '1',
          student_ids: ['1'],
        },
      ],
      all_dates: [
        template.assignmentDueDate({
          base: false,
          id: '1',
          unlock_at: '2017-06-01T07:59:00Z',
          lock_at: '2017-06-01T05:59:00Z',
        }),
      ],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validLockDates).toBeFalsy()
  })

  test('validator should be false when due date is after lock date not base', () => {
    const assignment = template.assignment({
      overrides: [
        {
          id: '1',
          group_id: '1',
          course_section_id: '1',
          student_ids: ['1'],
        },
      ],
      all_dates: [
        template.assignmentDueDate({
          base: false,
          id: '1',
          due_at: '2017-06-01T07:59:00Z',
          lock_at: '2017-06-01T05:59:00Z',
        }),
      ],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validDueDate).toBeFalsy()
  })

  test('validator should be false when both assignees and dates are invalid', () => {
    const assignment = template.assignment({
      all_dates: [{
        ...template.assignmentDueDate({
          base: false,
          id: 'none',
          due_at: '2017-06-01T05:59:59Z',
          lock_at: '2017-06-01T05:59:00Z',
          student_ids: [],
        }),
      }],
    })

    const editor = renderer.create(
      <AssignmentDatesEditor assignment={assignment} />
    ).getInstance()
    expect(editor.validate()).toBeFalsy()
    expect(editor.state.validAssignees).toBeFalsy()
    expect(editor.state.validDueDate).toBeFalsy()
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
    const show = jest.fn((url, options, additionalProps) => {
      callback = additionalProps.callback
    })

    const navigator = template.navigator({
      show,
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
    expect(show).toHaveBeenCalled()
    let student = template.enrollmentAssignee()
    let section = template.sectionAssignee()
    let group = template.groupAssignee()
    callback([student, section, group])
    expect(tree.toJSON()).toMatchSnapshot()
  })
})
