//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import React from 'react'
import 'react-native'
import { SafeAreaView } from 'react-native'

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
      <SafeAreaView>
        <FeatureRow
          title={tab.label}
          subtitle={this.subtitle()}
          onPress={this.onPress}
          disclosureIndicator
          selected={this.props.selected}
          testID={`courses-details.${tab.id}-cell`}
        />
      </SafeAreaView>
    )
  }
}
