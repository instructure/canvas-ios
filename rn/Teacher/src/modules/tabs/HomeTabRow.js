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

import React from 'react'
import 'react-native'

import i18n from 'format-message'
import FeatureRow from '../../common/components/rows/FeatureRow'

type Props = {
  tab: Tab,
  defaultView: ?string,
  onPress: Function,
  selected: ?boolean,
}

export default class CourseDetailsHomeTab extends React.Component<Props, any> {
  onPress = () => {
    const tab = this.props.tab
    this.props.onPress(tab)
  }

  subtitle = (): ?string => {
    switch (this.props.defaultView) {
      case 'assignments': return i18n('Assignments')
      case 'feed': return i18n('Recent Activity')
      case 'wiki': return i18n('Front Page')
      case 'modules': return i18n('Course Modules')
      case 'syllabus': return i18n('Syllabus')
      default: return null
    }
  }

  // Notice that CourseDetailsTab.js has a safe area around it, but this doesn't
  // There is a rendering issue that causes the containing scroll view to freak out.
  // We decided that because this tab is only shown in the student app and the student app doesn't support landscape, we don't
  // Need to have the safe area here, and that consequently fixed the layout issue.
  render () {
    const tab = this.props.tab
    return (
      <FeatureRow
        title={tab.label}
        subtitle={this.subtitle()}
        onPress={this.onPress}
        disclosureIndicator
        selected={this.props.selected}
        testID={`courses-details.${tab.id}-cell`}
      />
    )
  }
}
