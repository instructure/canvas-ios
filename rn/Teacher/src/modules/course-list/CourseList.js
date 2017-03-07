import React, { Component } from 'react'
import {
  Dimensions,
} from 'react-native'
import i18n from 'format-message'

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

export default class CourseList extends Component<any, Props, State> {
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

  selectCourse (course: any) {
    this.props.navigator.push({
      screen: 'teacher.CourseDetails',
      passProps: { course },
    })
  }

  render (): React.Element<GridView> {
    let courses = [{
      color: '#27B9CD',
      image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
      name: 'Biology 101',
      course_code: 'BIO 101',
      id: 1,
    }, {
      color: '#8F3E97',
      image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
      name: 'American Literature Psysicks foobar hello world 401',
      course_code: 'LIT 401',
      id: 2,
    }, {
      color: '#8F3E97',
      image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
      name: 'Foobar 102',
      course_code: 'FOO 102',
      id: 3,
    }]

    let cardStyles = {
      flex: 1,
      margin: this.state.padding,
    }

    return (
      <GridView
        onLayout={this.onLayout}
        style={{ padding: this.state.padding }}
        placeholderStyle={cardStyles}
        data={courses}
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
