export const nodeTextLength = (node: Node): number => {
  switch (node.nodeType) {
    case Node.ELEMENT_NODE:
    case Node.TEXT_NODE:
      return node.textContent?.length ?? 0;
    default:
      return 0;
  }
};

export const previousSiblingsTextLength = (node: Node): number => {
  let sibling = node.previousSibling;
  let length = 0;
  while (sibling) {
    length += nodeTextLength(sibling);
    sibling = sibling.previousSibling;
  }
  return length;
};

export const resolveOffsets = (
  element: Element,
  ...offsets: number[]
): Array<{ node: Text; offset: number }> => {
  let nextOffset = offsets.shift();
  const nodeIter = element.ownerDocument.createNodeIterator(
    element,
    NodeFilter.SHOW_TEXT
  );
  const results = [];

  let currentNode = nodeIter.nextNode() as Text | null;
  let textNode: Text | null = null;
  let length = 0;

  while (nextOffset !== undefined && currentNode) {
    textNode = currentNode;
    if (length + textNode.data.length > nextOffset) {
      results.push({ node: textNode, offset: nextOffset - length });
      nextOffset = offsets.shift();
    } else {
      currentNode = nodeIter.nextNode() as Text | null;
      length += textNode.data.length;
    }
  }

  while (nextOffset !== undefined && textNode && length === nextOffset) {
    results.push({ node: textNode, offset: textNode.data.length });
    nextOffset = offsets.shift();
  }

  if (nextOffset !== undefined) {
    console.error("Offset exceeds text length");
  }

  return results;
};
