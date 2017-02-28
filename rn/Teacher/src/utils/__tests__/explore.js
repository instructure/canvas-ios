// @flow

import explore from '../explore'

let {
  describe,
  it,
  expect,
} = global

describe('ComponentExplorer', () => {
  it('should find object by prop', () => {
    const obj = {
      props: {
        text: 'foo',
      },
    }

    expect(explore(obj).selectByProp('text', 'foo')).toEqual(obj)
  })

  it('should find nested object by prop', () => {
    const obj = {
      child: {
        props: {
          text: 'foo',
        },
      },
    }

    expect(explore(obj).selectByProp('text', 'foo')).toEqual(obj.child)
  })

  it('should find object in array by prop', () => {
    const obj = {
      children: [
        { props: { text: 'foo' } },
      ],
    }

    expect(explore(obj).selectByProp('text', 'foo')).toEqual(obj.children[0])
  })

  it('should return null if prop does not exist', () => {
    let obj = {}
    expect(explore(obj).selectByProp('foo', 'bar')).toBeNull()

    obj = { children: [{}] }
    expect(explore(obj).selectByProp('foo', 'bar')).toBeNull()
  })
})
