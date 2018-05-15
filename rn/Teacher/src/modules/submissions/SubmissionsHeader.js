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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import { LinkButton } from '../../common/buttons'
import { Heading1, Text } from '../../common/text'
import colors from '../../common/colors'
import { joinTitles } from '../filter/filter-options'

export type SubmissionsHeaderProps = {
  filterOptions: SubmissionFilterOption[],
  selectedFilter?: ?SelectedSubmissionFilter,
  onSelectFilter: Function,
  navigator: Navigator,
}

const anonymousSubtitle = i18n('Anonymous grading')
const mutedSubtitle = i18n('Grades muted')
const bothSubtitle = i18n('Grades muted, Anonymous grading')

export default class SubmissionsHeader extends Component<SubmissionsHeaderProps, any> {
  navigateToFilter = () => {
    this.props.navigator.show('/filter', {
      modal: true,
    }, { ...this.props })
  }

  render () {
    let title = joinTitles(this.props.filterOptions) || i18n('All Submissions')

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
          numberOfLines={1}
          style={styles.headerTitle}
        >
          { title }
        </Heading1>
        {!!subTitle && <Text style={styles.subtitle}>{subTitle}</Text>}
      </View>
      { this.renderFilterButton() }
    </View>)
  }

  renderFilterButton = () => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Submissions')
    let onPress = this.navigateToFilter

    let selected = this.props.filterOptions.filter(option => option.selected)
    if (selected.length > 0) {
      title = i18n('Filter ({numSelected, number})', { numSelected: selected.length })
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
}

const styles = StyleSheet.create({
  headerWrapper: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
    height: 'auto',
  },
  header: {
    flex: 1,
    flexDirection: 'column',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
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
