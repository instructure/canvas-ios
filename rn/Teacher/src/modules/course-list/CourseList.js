import React, { Component, PropTypes } from 'react'
import {
  Dimensions,
} from 'react-native'
import i18n from 'format-message'
import { stateToProps } from './props'
import CoursesActions from './actions'
import { connect } from 'react-redux'
import CourseCard from './components/course-card/CourseCard'
import GridView from '../../common/components/grid-view/GridView'

const { width: deviceWidth } = Dimensions.get('window')

type State = {
  width: number,
  padding: number,
  numItems: number,
}

type Props = {
  width: number,
}

const PADDING_CHANGE_WIDTH = 450
const MAX_CARD_WIDTH = 310

export class CourseList extends Component<any, Props, State> {
  constructor (props: Props) {
    super(props)

    let width = props.width || deviceWidth

    this.state = {
      width: width,
      ...this.determineLayout(width),
    }
  }

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Edit',
          description: 'Shown at the top of the app to allow the user to edit their course list',
        }),
        id: 'edit',
        testID: 'e2e_rules',
      },
    ],
    leftButtons: [{
      title: i18n({
        default: 'Leave Feedback',
        description: 'Shown at the top of the app to allow the user to leave feedback',
      }),
      icon: require('../../images/feedback.png'),
    }],
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

  componentDidMount () {
    this.props.refreshCourses()
  }

  selectCourse (course: any) {
    this.props.navigator.push({
      screen: 'teacher.CourseDetails',
      passProps: { course },
    })
  }

  render (): React.Element<GridView> {
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
            key={rowData.course_code}
            onPress={() => this.selectCourse(rowData)}
          />
        }
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

export default connect(stateToProps, CoursesActions)(CourseList)
