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

import defaultFilterOptions, { updateFilterSelection, createFilter, oldCreateFilter } from '../filter-options'

describe('defaultFilterOptions', () => {
  it('has all of the default filter options', () => {
    expect(defaultFilterOptions()).toMatchObject([
      {
        type: 'all',
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'late',
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'not_submitted',
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'ungraded',
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'graded',
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'lessthan',
        prompt: true,
        selected: false,
        disabled: false,
        exclusive: true,
      },
      {
        type: 'morethan',
        prompt: true,
        selected: false,
        disabled: false,
        exclusive: true,
      },
    ])
  })

  it('selects an option when the option type is passed in', () => {
    expect(defaultFilterOptions('ungraded')).toMatchObject([
      {
        type: 'all',
        selected: false,
        disabled: true,
      },
      {
        type: 'late',
        selected: false,
        disabled: true,
      },
      {
        type: 'not_submitted',
        selected: false,
        disabled: true,
      },
      {
        type: 'ungraded',
        selected: true,
        disabled: false,
      },
      {
        type: 'graded',
        selected: false,
        disabled: true,
      },
      {
        type: 'lessthan',
        selected: false,
        disabled: true,
      },
      {
        type: 'morethan',
        selected: false,
        disabled: true,
      },
    ])
  })

  it('all just returns the item', () => {
    let all = defaultFilterOptions().find(option => option.type === 'all') || {}
    expect(all.filterFunc()).toEqual({
      states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
      late: null,
      scoredMoreThan: null,
      scoredLessThan: null,
      sectionIDs: [],
      gradingStatus: null,
    })
  })

  it('late works', () => {
    let late = defaultFilterOptions().find(option => option.type === 'late') || {}
    expect(late.filterFunc()).toEqual({
      late: true,
    })
  })

  it('not_submitted works', () => {
    let notSubmitted = defaultFilterOptions().find(option => option.type === 'not_submitted') || {}
    expect(notSubmitted.filterFunc()).toEqual({
      states: ['unsubmitted'],
    })
  })

  it('ungraded works', () => {
    let ungraded = defaultFilterOptions().find(option => option.type === 'ungraded') || {}
    expect(ungraded.filterFunc()).toEqual({
      gradingStatus: 'needs_grading',
    })
  })

  it('graded works', () => {
    let graded = defaultFilterOptions().find(option => option.type === 'graded') || {}
    expect(graded.filterFunc()).toEqual({
      states: ['graded'],
    })
  })

  it('lessthan works', () => {
    let lessThan = defaultFilterOptions().find(option => option.type === 'lessthan') || {}
    lessThan.promptValue = '10'
    expect(lessThan.filterFunc()).toEqual({
      scoredLessThan: 10,
    })
  })

  it('moreThan works', () => {
    let moreThan = defaultFilterOptions().find(option => option.type === 'morethan') || {}
    moreThan.promptValue = '10'
    expect(moreThan.filterFunc()).toEqual({
      scoredMoreThan: 10,
    })
  })
})

describe('updateFilterSelection', () => {
  it('disables exclusive options when an exclusive option is selected', () => {
    let updatedFilterOptions = updateFilterSelection(defaultFilterOptions(), 'graded')
    expect(updatedFilterOptions.every(option => {
      if (option.type === 'graded') {
        return option.selected && !option.disabled
      }
      return !option.selected && option.disabled
    }))
  })

  it('enables exclusive options when a selected exclusive option is unselected', () => {
    let updatedFilterOptions = updateFilterSelection(defaultFilterOptions('graded'), 'graded')
    expect(updatedFilterOptions.every(option => !option.disabled))
    expect(updatedFilterOptions.every(option => !option.selected))
  })

  it('doesnt disable other non exclusive options when an option is selected', () => {
    let extraOption = {
      type: 'yo',
      disabled: false,
      selected: false,
      exclusive: false,
      filterFunc: () => ({ sectionIDs: ['1'] }),
      title: () => '',
    }

    let updatedFilterOptions = updateFilterSelection([
      ...defaultFilterOptions(),
      extraOption,
    ], 'ungraded')
    expect(updatedFilterOptions.find(option => option.type === 'yo')).toEqual(extraOption)
  })

  it('doesnt disable exclusive options when a non exclusive option is selected', () => {
    let updatedFilterOptions = updateFilterSelection([
      ...defaultFilterOptions(),
      {
        type: 'yo',
        disabled: false,
        selected: false,
        exclusive: false,
        title: () => 'yo',
        filterFunc: () => ({ sectionIDs: ['1'] }),
      },
    ], 'graded')
    expect(updatedFilterOptions.every(option => !option.disabled))
  })

  it('attaches a promptValue when provided', () => {
    let filterOptions = updateFilterSelection(defaultFilterOptions(), 'lessthan', '10')
    let option = filterOptions.find(option => option.type === 'lessthan') || {}
    expect(option.promptValue).toEqual('10')
  })
})

describe('createFilter', () => {
  it('works with an exclusive option selected', () => {
    let filterOptions = defaultFilterOptions('ungraded')
    let filter = createFilter(filterOptions)
    expect(filter).toEqual({
      late: null,
      scoredLessThan: null,
      scoredMoreThan: null,
      sectionIDs: [],
      states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
      gradingStatus: 'needs_grading',
    })
  })

  it('works with one non exclusive option selected', () => {
    let filterOptions = [{
      type: 'yo',
      selected: true,
      filterFunc: () => ({ sectionIDs: ['1'] }),
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }]
    let filter = createFilter(filterOptions)
    expect(filter).toEqual({
      late: null,
      scoredLessThan: null,
      scoredMoreThan: null,
      states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
      sectionIDs: ['1'],
      gradingStatus: null,
    })
  })

  it('works with multiple non exclusive options selected', () => {
    let filterOptions = [{
      type: 'yo',
      selected: true,
      filterFunc: () => ({ sectionIDs: ['1'] }),
      exclusive: false,
      disabled: false,
      title: () => 'yo',
    }, {
      type: 'ya',
      selected: true,
      filterFunc: () => ({ sectionIDs: ['2'] }),
      exclusive: false,
      disabled: false,
      title: () => 'ya',
    }]
    let filter = createFilter(filterOptions)
    expect(filter).toEqual({
      late: null,
      scoredLessThan: null,
      scoredMoreThan: null,
      states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
      sectionIDs: ['1', '2'],
      gradingStatus: null,
    })
  })

  it('works with exclusive and non exclusive options', () => {
    let filterOptions = [...defaultFilterOptions('late'), {
      type: 'yo',
      selected: true,
      filterFunc: () => ({ sectionIDs: ['1'] }),
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }, {
      type: 'ya',
      selected: true,
      filterFunc: () => ({ sectionIDs: ['2'] }),
      title: () => 'ya',
      disabled: false,
      exclusive: false,
    }]
    let filter = createFilter(filterOptions)
    expect(filter).toEqual({
      scoredLessThan: null,
      scoredMoreThan: null,
      states: ['submitted', 'unsubmitted', 'pending_review', 'graded', 'ungraded'],
      late: true,
      sectionIDs: ['1', '2'],
      gradingStatus: null,
    })
  })
})

describe('old', () => {
  it('all just returns the item', () => {
    let all = defaultFilterOptions().find(option => option.type === 'all') || {}
    let item = {}
    expect(all.oldFilterFunc(item)).toEqual(item)
  })

  it('late works', () => {
    let late = defaultFilterOptions().find(option => option.type === 'late') || {}
    expect(late.oldFilterFunc({})).toBeFalsy()
    expect(late.oldFilterFunc({ status: 'late' })).toBeTruthy()
  })

  it('not_submitted works', () => {
    let notSubmitted = defaultFilterOptions().find(option => option.type === 'not_submitted') || {}
    expect(notSubmitted.oldFilterFunc({})).toBeFalsy()
    expect(notSubmitted.oldFilterFunc({ grade: 'not_submitted' })).toBeTruthy()
  })

  it('ungraded works', () => {
    let ungraded = defaultFilterOptions().find(option => option.type === 'ungraded') || {}
    expect(ungraded.oldFilterFunc({})).toBeFalsy()
    expect(ungraded.oldFilterFunc({ grade: 'ungraded' })).toBeTruthy()
  })

  it('graded works', () => {
    let graded = defaultFilterOptions().find(option => option.type === 'graded') || {}
    expect(graded.oldFilterFunc({ grade: 'not_submitted' })).toBeFalsy()
    expect(graded.oldFilterFunc({ grade: 'ungraded' })).toBeFalsy()
    expect(graded.oldFilterFunc({ grade: 'excused' })).toBeTruthy()
    expect(graded.oldFilterFunc({ grade: 'A+' })).toBeTruthy()
  })

  it('lessthan works', () => {
    let lessThan = defaultFilterOptions().find(option => option.type === 'lessthan') || {}
    lessThan.promptValue = '10'
    expect(lessThan.oldFilterFunc({})).toBeFalsy()
    expect(lessThan.oldFilterFunc({ score: 11 })).toBeFalsy()
    expect(lessThan.oldFilterFunc({ score: 9 })).toBeTruthy()
  })

  it('moreThan works', () => {
    let moreThan = defaultFilterOptions().find(option => option.type === 'morethan') || {}
    moreThan.promptValue = '10'
    expect(moreThan.oldFilterFunc({})).toBeFalsy()
    expect(moreThan.oldFilterFunc({ score: 9 })).toBeFalsy()
    expect(moreThan.oldFilterFunc({ score: 11 })).toBeTruthy()
  })
})

describe('updateFilterSelection', () => {
  it('disables exclusive options when an exclusive option is selected', () => {
    let updatedFilterOptions = updateFilterSelection(defaultFilterOptions(), 'graded')
    expect(updatedFilterOptions.every(option => {
      if (option.type === 'graded') {
        return option.selected && !option.disabled
      }
      return !option.selected && option.disabled
    }))
  })

  it('enables exclusive options when a selected exclusive option is unselected', () => {
    let updatedFilterOptions = updateFilterSelection(defaultFilterOptions('graded'), 'graded')
    expect(updatedFilterOptions.every(option => !option.disabled))
    expect(updatedFilterOptions.every(option => !option.selected))
  })

  it('doesnt disable other non exclusive options when an option is selected', () => {
    let extraOption = {
      type: 'yo',
      disabled: false,
      selected: false,
      exclusive: false,
      oldFilterFunc: () => true,
      title: () => '',
    }

    let updatedFilterOptions = updateFilterSelection([
      ...defaultFilterOptions(),
      extraOption,
    ], 'ungraded')
    expect(updatedFilterOptions.find(option => option.type === 'yo')).toEqual(extraOption)
  })

  it('doesnt disable exclusive options when a non exclusive option is selected', () => {
    let updatedFilterOptions = updateFilterSelection([
      ...defaultFilterOptions(),
      {
        type: 'yo',
        disabled: false,
        selected: false,
        exclusive: false,
        title: () => 'yo',
        oldFilterFunc: () => true,
      },
    ], 'graded')
    expect(updatedFilterOptions.every(option => !option.disabled))
  })

  it('attaches a promptValue when provided', () => {
    let filterOptions = updateFilterSelection(defaultFilterOptions(), 'lessthan', '10')
    let option = filterOptions.find(option => option.type === 'lessthan') || {}
    expect(option.promptValue).toEqual('10')
  })
})

describe('oldCreateFilter', () => {
  it('works with an exclusive option selected', () => {
    let filterOptions = defaultFilterOptions('ungraded')
    let filter = oldCreateFilter(filterOptions)
    let items = [{
      grade: 'ungraded',
    }, {
      grade: 'yo',
    }]
    expect(filter(items)).toEqual([
      { grade: 'ungraded' },
    ])
  })

  it('works with one non exclusive option selected', () => {
    let filterOptions = [{
      type: 'yo',
      selected: true,
      oldFilterFunc: (item) => item.score === 'yo',
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }]
    let filter = oldCreateFilter(filterOptions)
    let items = [{
      score: 'yo',
    }, {
      score: 'ya',
    }]
    expect(filter(items)).toEqual([
      { score: 'yo' },
    ])
  })

  it('works with multiple non exclusive options selected', () => {
    let filterOptions = [{
      type: 'yo',
      selected: true,
      oldFilterFunc: (item) => item.score === 'yo',
      exclusive: false,
      disabled: false,
      title: () => 'yo',
    }, {
      type: 'ya',
      selected: true,
      oldFilterFunc: (item) => item.score === 'ya',
      exclusive: false,
      disabled: false,
      title: () => 'ya',
    }]
    let filter = oldCreateFilter(filterOptions)
    let items = [{
      score: 'yo',
    }, {
      score: 'ya',
    }]
    expect(filter(items)).toEqual([
      { score: 'yo' },
      { score: 'ya' },
    ])
  })

  it('works with exclusive and non exclusive options', () => {
    let filterOptions = [...defaultFilterOptions('late'), {
      type: 'yo',
      selected: true,
      oldFilterFunc: (item) => item.score === 'yo',
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }, {
      type: 'ya',
      selected: true,
      oldFilterFunc: (item) => item.score === 'ya',
      title: () => 'ya',
      disabled: false,
      exclusive: false,
    }]
    let filter = oldCreateFilter(filterOptions)
    let items = [{
      score: 'yo',
      status: 'late',
    }, {
      score: 'ya',
    }]
    expect(filter(items)).toEqual([{
      status: 'late',
      score: 'yo',
    }])
  })
})
