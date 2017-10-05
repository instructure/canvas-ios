//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'

import i18n from 'format-message'
import { LinkButton } from '../../common/buttons'
import { Heading1, Text } from '../../common/text'
import colors from '../../common/colors'

type SubmissionFilterOptionType = 'all' | 'late' | 'notsubmitted' | 'notgraded' | 'graded' | 'lessthan' | 'morethan' | 'cancel'

export type SubmissionFilterOption = {
  type: SubmissionFilterOptionType,
  title: string,
  filterFunc?: Function,
}

export type SelectedSubmissionFilter = {
  filter: SubmissionFilterOption,
  metadata?: ?any,
}

export type SubmissionsHeaderProps = {
  filterOptions: SubmissionFilterOption[],
  selectedFilter?: ?SelectedSubmissionFilter,
  onClearFilter: Function,
  onSelectFilter: Function,
}

const anonymousSubtitle = i18n('Anonymous grading')
const mutedSubtitle = i18n('Grades muted')
const bothSubtitle = i18n('Grades muted, Anonymous grading')

export default class SubmissionsHeader extends Component<any, SubmissionsHeaderProps, any> {

  chooseFilter = () => {
    const options = this.props.filterOptions.map((option) => option.title)
    ActionSheetIOS.showActionSheetWithOptions({
      options,
      cancelButtonIndex: options.length - 1,
      title: i18n('Filter by:'),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    const prompt = (title: string, callback: Function) => {
      let message = i18n('Out of {count}', { count: this.props.pointsPossible || 0 })
      AlertIOS.prompt(
        title,
        message,
        callback,
        'plain-text',
        '',
        'numeric'
      )
    }

    const filter = this.props.filterOptions[index]
    const selectedFilter: SelectedSubmissionFilter = {
      filter: filter,
    }

    switch (filter.type) {
      case 'lessthan':
      case 'morethan':
        prompt(filter.title, (text) => {
          selectedFilter.metadata = text
          this.props.onSelectFilter(selectedFilter)
        })
        return
      case 'cancel':
        break
      default:
        this.props.onSelectFilter(selectedFilter)
        break
    }
  }

  clearFilter = () => {
    this.props.onClearFilter()
  }

  render () {
    let title = i18n('All Submissions')
    const selected = this.props.selectedFilter
    if (selected && selected.filter && selected.filter.type !== 'all') {
      title = selected.filter.title
    }

    let subTitle = ''
    if (this.props.muted && this.props.anonymous) {
      subTitle = bothSubtitle
    } else if (this.props.muted) {
      subTitle = mutedSubtitle
    } else if (this.props.anonymous) {
      subTitle = anonymousSubtitle
    }

    return (<View style={styles.headerWrapper}>
              <View style={styles.header}>
                <Heading1
                  style={styles.headerTitle}
                  >
                  { title }
                </Heading1>
                { this.renderFilterButton() }
              </View>
              {!!subTitle && <Text style={styles.subtitle}>{subTitle}</Text>}
            </View>)
  }

  renderFilterButton = () => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Submissions')
    let onPress = this.chooseFilter
    const selected = this.props.selectedFilter

    if (selected &&
        selected.filter &&
        selected.filter.type !== 'all' &&
        selected.filter.type !== 'cancel') {
      title = i18n('Clear Filter')
      accessibilityLabel = i18n('Clear Filter Submissions')
      onPress = this.clearFilter
    }

    return (<LinkButton
              testID='submission-list.filter'
              onPress={onPress}
              style={styles.filterButton}
              accessibilityLabel={ accessibilityLabel }
              >
              { title }
            </LinkButton>)
  }

  // This assumes using some flavor of SubmissionRowDataProps to back the rows in a submission list
  static defaultFilterOptions (): SubmissionFilterOption[] {
    return [
      {
        type: 'all',
        title: i18n('All submissions'),
      },
      {
        type: 'late',
        title: i18n('Submitted late'),
        filterFunc: (submissions: any) => submissions.filter((s) => s.status === 'late'),
      },
      {
        type: 'notsubmitted',
        title: i18n("Haven't submitted yet"),
        filterFunc: (submissions: any) => submissions.filter((s) => s.grade === 'not_submitted'),
      },
      {
        type: 'notgraded',
        title: i18n("Haven't been graded"),
        filterFunc: (submissions: any) => submissions.filter((s) => s.grade === 'ungraded'),
      },
      {
        type: 'graded',
        title: i18n('Graded'),
        filterFunc: (submissions: any) => submissions.filter((s) => s.grade === 'excused' || (s.grade !== 'not_submitted' && s.grade !== 'ungraded')),
      },
      {
        type: 'lessthan',
        title: i18n('Scored less than…'),
        filterFunc: (submissions: any, metadata: any) => submissions.filter((s) => {
          return (s.score !== null && s.score !== undefined) && (s.score < Number(metadata))
        }),
      },
      {
        type: 'morethan',
        title: i18n('Scored more than…'),
        filterFunc: (submissions: any, metadata: any) => submissions.filter((s) => {
          return (s.score !== null && s.score !== undefined) && (s.score > Number(metadata))
        }),
      },
      {
        type: 'cancel',
        title: i18n('Cancel'),
      },
    ]
  }
}

export function messageStudentsWhoSubject (selectedFilter: ?SelectedSubmissionFilter, assignmentName: string): string {
  if (!selectedFilter) {
    return i18n('All submissions - {assignmentName}', { assignmentName })
  }
  var subject = ''
  switch (selectedFilter.filter.type) {
    case 'all':
      subject = i18n('All submissions - {assignmentName}', { assignmentName })
      break
    case 'late':
      subject = i18n('Submitted late - {assignmentName}', { assignmentName })
      break
    case 'notsubmitted':
      subject = i18n("Haven't submitted yet - {assignmentName}", { assignmentName })
      break
    case 'notgraded':
      subject = i18n("Haven't been graded - {assignmentName}", { assignmentName })
      break
    case 'graded':
      subject = i18n('Graded - {assignmentName}', { assignmentName })
      break
    case 'lessthan':
      subject = i18n('Scored less than {score} - {assignmentName}', { score: selectedFilter.metadata || '', assignmentName })
      break
    case 'morethan':
      subject = i18n('Score more than {score} - {assignmentName}', { score: selectedFilter.metadata || '', assignmentName })
      break
  }

  return subject
}

const styles = StyleSheet.create({
  headerWrapper: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
    height: 'auto',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
    flex: 1,
  },
  subtitle: {
    color: colors.grey4,
    fontSize: 14,
    fontWeight: '500',
  },
  filterButton: {
    marginBottom: 1,
    width: 'auto',
  },
})
