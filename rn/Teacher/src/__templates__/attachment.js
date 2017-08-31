/* @flow */

import template, { type Template } from '../utils/template'
import { file } from './file'

export const attachment: Template<Attachment> = template({
  ...file(),
  filename: 'Attachment 1.jpg',
  uri: 'file://somewhere/on/disk.jpg',
})
