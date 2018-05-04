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
import { FlatList, Image } from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Screen from '../../../routing/Screen'
import AssigneePickerActions from '../../assignee-picker/actions'
import Row from '../../../common/components/rows/Row'
import images from '../../../images'
import colors from '../../../common/colors'

type OwnProps = {
  courseID: string,
  updateSelectedSections: (string[]) => void,
  currentSelectedSections: string[],
}
type ActionProps = {
  refreshSections: typeof AssigneePickerActions.refreshSections,
}
type DataProps = {
  sections: Section[],
  courseName: string,
}
type Props = OwnProps & NavigationProps & ActionProps & DataProps

type State = {
  selectedSections: string[],
}

export class SectionSelector extends Component<Props, State> {
  state = {
    selectedSections: this.props.currentSelectedSections,
  }

  componentDidMount () {
    this.props.refreshSections(this.props.courseID)
  }

  render () {
    return (
      <Screen
        title={i18n('{courseName} Sections', { courseName: this.props.courseName })}
      >
        <FlatList
          data={this.props.sections}
          renderItem={this.renderSection}
          extraData={this.state}
        />
      </Screen>
    )
  }

  renderSection = ({ item: section }: { item: Section }) => {
    return (
      <Row
        title={section.name}
        border='bottom'
        identifier={section.id}
        onPress={this.pressSection}
        accessories={this.state.selectedSections.includes(section.id) &&
          <Image source={images.check} style={{ tintColor: colors.checkmarkGreen }} />
        }
      />
    )
  }

  pressSection = (id: string) => {
    this.setState(({ selectedSections }) => {
      let newSelections = []
      if (selectedSections.includes(id)) {
        newSelections = selectedSections.filter(sid => sid !== id)
      } else {
        newSelections = [...selectedSections, id]
      }

      this.props.updateSelectedSections(newSelections)
      return {
        selectedSections: newSelections,
      }
    })
  }

  donePressed = () => {
    this.props.navigator.dismiss()
  }
}

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): DataProps {
  return {
    sections: Object.values(entities.sections)
      // $FlowFixMe
      .filter((section: Section) => section.course_id === courseID),
    courseName: entities.courses[courseID].course.name,
  }
}

const Connected = connect(mapStateToProps, AssigneePickerActions)(SectionSelector)
export default Connected
