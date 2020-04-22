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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import {
  View,
} from 'react-native'

import i18n from 'format-message'
import { LinkButton } from '../../common/buttons'
import { Heading1, Text } from '../../common/text'
import { createStyleSheet } from '../../common/stylesheet'
import { joinTitles } from '../filter/filter-options'

export type SubmissionsHeaderProps = {
  filterOptions: SubmissionFilterOption[],
  selectedFilter?: ?SelectedSubmissionFilter,
  onSelectFilter: Function,
  navigator: Navigator,
}

export default class SubmissionsHeader extends Component<SubmissionsHeaderProps, any> {
  navigateToFilter = () => {
    this.props.navigator.show('/filter', {
      modal: true,
    }, { ...this.props })
  }

  render () {
    let title = joinTitles(this.props.filterOptions) || i18n('All Submissions')

    let subTitle = ''
    if (this.props.anonymous) {
      subTitle = i18n('Anonymous grading')
    }

    return (<View style={styles.headerWrapper}>
      <View style={styles.header}>
        <Heading1 numberOfLines={1}>
          { title }
        </Heading1>
        {!!subTitle && <Text testID='SubmissionsHeader.subtitle' style={styles.subtitle}>{subTitle}</Text>}
      </View>
      { this.renderFilterButton() }
    </View>)
  }

  renderFilterButton = () => {
    let title = i18n('Filter')
    let onPress = this.navigateToFilter

    let selected = this.props.filterOptions.filter(option => option.selected)
    if (selected.length > 0) {
      title = i18n('Filter ({numSelected, number})', { numSelected: selected.length })
    }

    let accessibilityLabel = i18n('Filter Submissions. ({numSelected, number}) selected.', { numSelected: selected.length })

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

const styles = createStyleSheet((colors, vars) => ({
  headerWrapper: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
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
  subtitle: {
    color: colors.textDark,
    fontSize: 14,
    fontWeight: '500',
  },
  filterButton: {
    marginBottom: 1,
    width: 'auto',
  },
}))
