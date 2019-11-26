import 'react-native'
import React from 'react'
import { shallow } from 'enzyme'
import CommentAttachment from '../CommentAttachment'
import * as template from '../../../../__templates__/'
import icon from '../../../../images/inst-icons'

describe('CommentAttachment', () => {
  let props
  beforeEach(() => {
    props = {
      from: 'them',
      attachment: template.attachment(),
    }
  })

  it('renders attachment', () => {
    props.attachment.display_name = 'screenshot.png'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.find('Image').prop('source')).toEqual(icon('paperclip'))
    expect(view.find('Text').children().text()).toEqual('screenshot.png')
  })

  it('renders theirs styles', () => {
    props.from = 'them'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.prop('style')[1].justifyContent).toEqual('flex-start')
  })

  it('renders mine styles', () => {
    props.from = 'me'
    let view = shallow(<CommentAttachment {...props} />)
    expect(view.prop('style')[1].justifyContent).toEqual('flex-end')
  })
})
