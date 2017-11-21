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

// @flow

import defaultFilterOptions, { updateFilterSelection, createFilter } from '../filter-options'

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
    let item = {}
    expect(all.filterFunc(item)).toEqual(item)
  })

  it('late works', () => {
    let late = defaultFilterOptions().find(option => option.type === 'late') || {}
    expect(late.filterFunc({})).toBeFalsy()
    expect(late.filterFunc({ status: 'late' })).toBeTruthy()
  })

  it('not_submitted works', () => {
    let notSubmitted = defaultFilterOptions().find(option => option.type === 'not_submitted') || {}
    expect(notSubmitted.filterFunc({})).toBeFalsy()
    expect(notSubmitted.filterFunc({ grade: 'not_submitted' })).toBeTruthy()
  })

  it('ungraded works', () => {
    let ungraded = defaultFilterOptions().find(option => option.type === 'ungraded') || {}
    expect(ungraded.filterFunc({})).toBeFalsy()
    expect(ungraded.filterFunc({ grade: 'ungraded' })).toBeTruthy()
  })

  it('graded works', () => {
    let graded = defaultFilterOptions().find(option => option.type === 'graded') || {}
    expect(graded.filterFunc({ grade: 'not_submitted' })).toBeFalsy()
    expect(graded.filterFunc({ grade: 'ungraded' })).toBeFalsy()
    expect(graded.filterFunc({ grade: 'excused' })).toBeTruthy()
    expect(graded.filterFunc({ grade: 'A+' })).toBeTruthy()
  })

  it('lessthan works', () => {
    let lessThan = defaultFilterOptions().find(option => option.type === 'lessthan') || {}
    lessThan.promptValue = '10'
    expect(lessThan.filterFunc({})).toBeFalsy()
    expect(lessThan.filterFunc({ score: 11 })).toBeFalsy()
    expect(lessThan.filterFunc({ score: 9 })).toBeTruthy()
  })

  it('moreThan works', () => {
    let moreThan = defaultFilterOptions().find(option => option.type === 'morethan') || {}
    moreThan.promptValue = '10'
    expect(moreThan.filterFunc({})).toBeFalsy()
    expect(moreThan.filterFunc({ score: 9 })).toBeFalsy()
    expect(moreThan.filterFunc({ score: 11 })).toBeTruthy()
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
      filterFunc: () => true,
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
        filterFunc: () => true,
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
      filterFunc: (item) => item.score === 'yo',
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }]
    let filter = createFilter(filterOptions)
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
      filterFunc: (item) => item.score === 'yo',
      exclusive: false,
      disabled: false,
      title: () => 'yo',
    }, {
      type: 'ya',
      selected: true,
      filterFunc: (item) => item.score === 'ya',
      exclusive: false,
      disabled: false,
      title: () => 'ya',
    }]
    let filter = createFilter(filterOptions)
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
      filterFunc: (item) => item.score === 'yo',
      title: () => 'yo',
      disabled: false,
      exclusive: false,
    }, {
      type: 'ya',
      selected: true,
      filterFunc: (item) => item.score === 'ya',
      title: () => 'ya',
      disabled: false,
      exclusive: false,
    }]
    let filter = createFilter(filterOptions)
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
