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

    expect(explore(obj).selectByProp('text', 'foo')[0]).toEqual(obj)
  })

  it('should find object in array by prop', () => {
    const obj = {
      children: [
        { props: { text: 'foo' } },
      ],
    }

    expect(explore(obj).selectByProp('text', 'foo')).toEqual([obj.children[0]])
  })

  it('should be empty if prop does not exist', () => {
    let obj = {}
    expect(explore(obj).selectByProp('foo', 'bar')).toHaveLength(0)

    obj = { children: [{}] }
    expect(explore(obj).selectByProp('foo', 'bar')).toHaveLength(0)
  })

  it('should find object with query', () => {
    let obj = {}
    const query = (item) => item.foo === 'bar'
    expect(explore(obj).query(query)).toHaveLength(0)

    obj.foo = 'bar'
    expect(explore(obj).query(query)[0]).toEqual(obj)
  })

  it('should find children with query', () => {
    const obj = {
      children: [
        { type: 'bar' },
        { type: 'foo' },
        { type: 'foo' },
      ],
    }
    const query = (item) => {
      return item.type === 'foo'
    }

    const results = explore(obj).query(query)
    expect(results).toHaveLength(2)
    expect(results).toMatchObject([{ type: 'foo' }, { type: 'foo' }])
  })
})
