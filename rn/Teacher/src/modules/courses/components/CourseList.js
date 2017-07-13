// @flow

import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { View } from 'react-native'
import CourseCard from './CourseCard'
import GridView from '../../../common/components/GridView'
import type { CourseProps } from '../course-prop-types'

type State = {
  width: number,
  padding: number,
  numItems: number,
}

type Props = {
  width: number,
  selectCourse: (course: Course) => void,
  header?: React.Element<*>,
  courses: Array<CourseProps>,
  error?: string,
  pending: number,
  onCoursePreferencesPressed: (courseId: string) => void,
  onRefresh: Function,
}

const PADDING_CHANGE_WIDTH = 450
const MAX_CARD_WIDTH = 295

export default class CourseList extends Component {
  props: Props
  state: State

  constructor (props: Props) {
    super(props)

    this.state = {
      width: props.width,
      ...this.determineLayout(props.width),
    }
  }

  determineLayout (width: number): {padding: number, numItems: number} {
    let newPadding = width > PADDING_CHANGE_WIDTH ? 12 : 8
    let newNumItems = Math.ceil(width / (MAX_CARD_WIDTH + newPadding * 2))
    return {
      padding: newPadding,
      numItems: newNumItems,
    }
  }

  onLayout = (event: any) => {
    if (event.nativeEvent.layout.width !== this.state.width) {
      this.setState(this.determineLayout(event.nativeEvent.layout.width))
    }
  }

  renderHeader = () => {
    return (
      <View style={{ paddingHorizontal: this.state.padding, marginTop: this.state.padding }}>
        {this.props.header}
      </View>
    )
  }

  render () {
    let cardStyles = {
      flex: 1,
      margin: this.state.padding,
    }

    return (
      <GridView
        onLayout={this.onLayout}
        showsVerticalScrollIndicator={false}
        style={{ marginHorizontal: this.state.padding, overflow: 'visible' }}
        placeholderStyle={cardStyles}
        data={this.props.courses}
        itemsPerRow={this.state.numItems}
        renderItem={(rowData: CourseProps) =>
          <CourseCard
            style={cardStyles}
            course={rowData}
            color={rowData.color}
            key={`${rowData.course_code}_${rowData.id}`}
            onPress={this.props.selectCourse}
            onCoursePreferencesPressed={this.props.onCoursePreferencesPressed}
          />
        }
        renderHeader={this.renderHeader}
        onRefresh={this.props.onRefresh}
      />
    )
  }
}

const coursePropsShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  color: PropTypes.string,
  image_download_url: PropTypes.string,
})

CourseList.propTypes = {
  courses: PropTypes.arrayOf(coursePropsShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}
