const getNodeName = (node: Node): string => {
  const nodeName = node.nodeName.toLowerCase()
  return nodeName === "#text" ? "text()" : nodeName
}

function getNodePosition(node: Node): number {
  let pos = 0
  let tmp: Node | null = node
  while (tmp) {
    if (tmp.nodeName === node.nodeName) {
      pos += 1
    }
    tmp = tmp.previousSibling
  }
  return pos
}

const getPathSegment = (node: Node): string => {
  const name = getNodeName(node)
  const pos = getNodePosition(node)
  return `${name}[${pos}]`
}

export const xpathFromNode = (node: Node, root: Node) => {
  let xpath = ""

  let elem: Node | null = node
  while (elem !== root) {
    if (!elem) {
      console.error("Node is not a descendant of root")
      return
    }
    xpath = `${getPathSegment(elem)}/${xpath}`
    elem = elem.parentNode
  }
  xpath = `/${xpath}`
  xpath = xpath.replace(/\/$/, "") // Remove trailing slash

  return xpath
}

const nthChildOfType = (
  element: Element,
  nodeName: string,
  index: number,
): Element | null => {
  const name = nodeName.toUpperCase()

  let matchIndex = -1
  for (let i = 0; i < element.children.length; i++) {
    const child = element.children[i]
    if (child.nodeName.toUpperCase() === name) {
      ++matchIndex
      if (matchIndex === index) {
        return child
      }
    }
  }

  return null
}

const evaluateSimpleXPath = (xpath: string, root: Element): Element | null => {
  const isSimpleXPath = xpath.match(/^(\/[A-Za-z0-9-]+(\[[0-9]+])?)+$/) !== null
  if (!isSimpleXPath) {
    console.error("Expression is not a simple XPath")
    return null
  }

  const segments = xpath.split("/")
  let element = root

  // Remove leading empty segment. The regex above validates that the XPath
  // has at least two segments, with the first being empty and the others non-empty.
  segments.shift()

  for (const segment of segments) {
    let elementName: string
    let elementIndex: number

    const separatorPos = segment.indexOf("[")
    if (separatorPos !== -1) {
      elementName = segment.slice(0, separatorPos)

      const indexStr = segment.slice(separatorPos + 1, segment.indexOf("]"))
      elementIndex = Number.parseInt(indexStr) - 1
      if (elementIndex < 0) {
        return null
      }
    } else {
      elementName = segment
      elementIndex = 0
    }

    const child = nthChildOfType(element, elementName, elementIndex)
    if (!child) {
      return null
    }

    element = child
  }

  return element
}

export const nodeFromXPath = (
  xpath: string,
  root: Element = document.body,
): Node | null => {
  try {
    return evaluateSimpleXPath(xpath, root)
  } catch {
    return document.evaluate(
      `.${xpath}`,
      root,
      null /* namespaceResolver */,
      XPathResult.FIRST_ORDERED_NODE_TYPE,
      null /* result */,
    ).singleNodeValue
  }
}
