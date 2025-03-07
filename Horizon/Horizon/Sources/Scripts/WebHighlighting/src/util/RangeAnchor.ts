import { TextPosition } from "./TextPosition";
import { TextRange } from "./TextRange";
import { nodeFromXPath, xpathFromNode } from "./xpath";

export class RangeAnchor {
  root: Node;
  range: Range;

  constructor(root: Node, range: Range) {
    this.root = root;
    this.range = range;
  }

  static fromRange(root: Node, range: Range): RangeAnchor {
    return new RangeAnchor(root, range);
  }

  static fromSelector(
    root: Element,
    selector: RangeSelector
  ): RangeAnchor | null {
    if (!selector?.startContainer || !selector?.endContainer) {
      console.error("No start or end container in selector");
      return null;
    }
    const startContainer = nodeFromXPath(selector.startContainer, root);
    if (!startContainer) {
      console.error("Failed to resolve startContainer XPath");
      return null;
    }

    const endContainer = nodeFromXPath(selector.endContainer, root);
    if (!endContainer) {
      console.error("Failed to resolve endContainer XPath");
      return null;
    }

    const startPos = TextPosition.fromCharOffset(
      startContainer,
      selector.startOffset
    );
    const endPos = TextPosition.fromCharOffset(
      endContainer,
      selector.endOffset
    );

    if (!startPos || !endPos) {
      return null;
    }

    const range = new TextRange(startPos, endPos).toRange();
    return new RangeAnchor(root, range);
  }

  toRange(): Range {
    return this.range;
  }

  toSelector(): RangeSelector | null {
    const normalizedRange = TextRange.fromRange(this.range)?.toRange();
    const textRange = normalizedRange && TextRange.fromRange(normalizedRange);
    const startContainer =
      textRange && xpathFromNode(textRange.start.element, this.root);
    const endContainer =
      textRange && xpathFromNode(textRange.end.element, this.root);

    if (!startContainer || !endContainer) {
      return null;
    }

    return {
      startContainer,
      startOffset: textRange.start.offset,
      endContainer,
      endOffset: textRange.end.offset,
    };
  }
}
