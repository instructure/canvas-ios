// @flow

import React, { Component, PropTypes } from 'react'
import { View } from 'react-native'
import CourseCard from './CourseCard'
import GridView from '../../../common/components/grid-view/GridView'

type State = {
  width: number,
  padding: number,
  numItems: number,
}

type Props = {
  width: number,
  selectCourse: (course: Course) => void,
  header?: React.Element<*>,
  customColors: { [string]: string },
  courses: Array<Course>,
  error?: string,
  pending: number,
}

const PADDING_CHANGE_WIDTH = 450
const MAX_CARD_WIDTH = 310

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

  selectCourse (course: any) {
    this.props.selectCourse(course)
  }

  renderHeader = () => {
    return (
      <View style={{ paddingHorizontal: this.state.padding }}>
        {this.props.header}
      </View>
    )
  }

  render (): React.Element<*> {
    let cardStyles = {
      flex: 1,
      margin: this.state.padding,
    }

    return (
      <GridView
        onLayout={this.onLayout}
        style={{ padding: this.state.padding }}
        placeholderStyle={cardStyles}
        data={this.props.courses}
        itemsPerRow={this.state.numItems}
        renderItem={(rowData: Course) =>
          <CourseCard
            style={cardStyles}
            course={rowData}
            color={this.props.customColors[rowData.id.toString()]}
            key={rowData.course_code}
            onPress={() => this.selectCourse(rowData)}
          />
        }
        renderHeader={this.renderHeader}
      />
    )
  }
}

const courseListShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  color: PropTypes.string,
  image_download_url: PropTypes.string,
}).isRequired

CourseList.propTypes = {
  courses: PropTypes.arrayOf(courseListShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}
