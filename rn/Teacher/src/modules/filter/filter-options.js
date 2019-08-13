//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import i18n from 'format-message'

export type SubmissionFilterOption = {
  type: string,
  title: () => string,
  filterFunc: Function,
  selected: boolean,
  disabled: boolean,
  exclusive: boolean,
  prompt?: boolean,
  promptValue?: string,
}

export default function defaultFilterOptions (defaultFilterType?: string): Array<SubmissionFilterOption> {
  let filterOptions = [
    {
      type: 'all',
      title: () => i18n('All submissions'),
      filterFunc: () => ({
        states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
        late: null,
        scoredMoreThan: null,
        scoredLessThan: null,
        sectionIDs: [],
        gradingStatus: null,
      }),
      oldFilterFunc: (submission) => submission,
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'late',
      title: () => i18n('Submitted late'),
      filterFunc: () => ({
        late: true,
      }),
      oldFilterFunc: (submission) => submission.status === 'late',
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'not_submitted',
      title: () => i18n("Haven't submitted yet"),
      filterFunc: () => ({
        states: ['unsubmitted'],
      }),
      oldFilterFunc: (submission) => submission.grade === 'not_submitted',
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'ungraded',
      title: () => i18n("Haven't been graded"),
      filterFunc: () => ({
        states: ['submitted', 'pending_review', 'ungraded'],
        gradingStatus: 'needs_grading',
      }),
      oldFilterFunc: (submission) => submission.grade === 'ungraded',
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'graded',
      title: () => i18n('Graded'),
      filterFunc: () => ({
        states: ['graded'],
      }),
      oldFilterFunc: (submission) => submission.grade === 'excused' || (submission.grade !== 'not_submitted' && submission.grade !== 'ungraded'),
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'lessthan',
      title: function () {
        return this.promptValue
          ? i18n('Scored less than {promptValue}', { promptValue: this.promptValue })
          : i18n('Scored less than…')
      },
      filterFunc: function () {
        return {
          scoredLessThan: +this.promptValue,
        }
      },
      oldFilterFunc: function (submission: any) {
        return (submission.score !== null && submission.score !== undefined) && (submission.score < this.promptValue)
      },
      prompt: true,
      selected: false,
      disabled: false,
      exclusive: true,
    },
    {
      type: 'morethan',
      title: function () {
        return this.promptValue
          ? i18n('Scored more than {promptValue}', { promptValue: this.promptValue })
          : i18n('Scored more than…')
      },
      filterFunc: function () {
        return {
          scoredMoreThan: +this.promptValue,
        }
      },
      oldFilterFunc: function (submission: any) {
        return (submission.score !== null && submission.score !== undefined) && (submission.score > this.promptValue)
      },
      prompt: true,
      selected: false,
      disabled: false,
      exclusive: true,
    },
  ]

  if (defaultFilterType) {
    filterOptions = updateFilterSelection(filterOptions, defaultFilterType)
  }
  return filterOptions
}

export function updateFilterSelection (filterOptions: Array<SubmissionFilterOption>, selectedType: ?string, promptValue?: string): Array<SubmissionFilterOption> {
  let selectedOption = filterOptions.find(option => option.type === selectedType) || {}
  return filterOptions
    .map(option => {
      let optionCopy = { ...option }
      if (optionCopy.type === selectedOption.type) {
        optionCopy.selected = !selectedOption.selected
        optionCopy.disabled = false
        optionCopy.promptValue = promptValue
      } else if (selectedOption.exclusive && optionCopy.exclusive) {
        optionCopy.disabled = !selectedOption.selected
        optionCopy.selected = false
      }

      return optionCopy
    })
}

export function createFilter (filterOptions: Array<SubmissionFilterOption>): Function {
  let defaultFilter = {
    states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
    late: null,
    scoredMoreThan: null,
    scoredLessThan: null,
    sectionIDs: [],
    gradingStatus: null,
  }

  return filterOptions
    .filter(option => option.selected)
    .reduce((filter, option) => {
      if (option.filterFunc().sectionIDs != null) {
        filter.sectionIDs.push(...option.filterFunc().sectionIDs)
        return filter
      }

      return {
        ...filter,
        ...option.filterFunc(),
      }
    }, defaultFilter)
}

export function oldCreateFilter (filterOptions: Array<SubmissionFilterOption>): Function {
  let exclusiveFilter = filterOptions.find(option => option.exclusive && option.selected)
  let otherFilters = filterOptions.filter(option => !option.exclusive && option.selected)

  return (items) => {
    return items.filter(item => {
      if (otherFilters.length > 0 && !otherFilters.some(filter => filter.oldFilterFunc(item))) return false
      if (exclusiveFilter && !exclusiveFilter.oldFilterFunc(item, +exclusiveFilter.promptValue)) return false
      return true
    })
  }
}

export function joinTitles (filterOptions: Array<SubmissionFilterOption>): string {
  return filterOptions
    .filter(option => option.selected)
    .map(option => option.title())
    .join(', ')
}
