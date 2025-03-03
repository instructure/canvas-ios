import {
  nodeTextLength,
  previousSiblingsTextLength,
  resolveOffsets,
} from "./utils";
import { ResolveDirection } from "./TextRange";

export class TextPosition {
  public element: Element;
  public offset: number;

  constructor(element: Element, offset: number) {
    if (offset < 0) {
      console.error("Offset is invalid");
    }

    this.element = element;
    this.offset = offset;
  }

  resolve(options: { direction?: ResolveDirection } = {}): {
    node: Text;
    offset: number;
  } {
    try {
      return resolveOffsets(this.element, this.offset)[0];
    } catch (err) {
      if (this.offset === 0 && options.direction !== undefined) {
        const tw = document.createTreeWalker(
          this.element.getRootNode(),
          NodeFilter.SHOW_TEXT
        );
        tw.currentNode = this.element;
        const forwards = options.direction === ResolveDirection.FORWARDS;
        const text = forwards
          ? (tw.nextNode() as Text | null)
          : (tw.previousNode() as Text | null);
        if (!text) {
          throw err;
        }
        return { node: text, offset: forwards ? 0 : text.data.length };
      }
      throw err;
    }
  }

  static fromCharOffset(node: Node, offset: number): TextPosition | null {
    switch (node.nodeType) {
      case Node.TEXT_NODE:
        return TextPosition.fromPoint(node, offset);
      case Node.ELEMENT_NODE:
        return new TextPosition(node as Element, offset);
      default:
        console.error("Node is not an element or text node");
        return null;
    }
  }

  static fromPoint(node: Node, offset: number): TextPosition | null {
    switch (node.nodeType) {
      case Node.TEXT_NODE: {
        if (offset < 0 || offset > (node as Text).data.length) {
          console.error("Text node offset is out of range");
          return null;
        }

        if (!node.parentElement) {
          console.error("Text node has no parent");
          return null;
        }

        const textOffset = previousSiblingsTextLength(node) + offset;

        return new TextPosition(node.parentElement, textOffset);
      }
      case Node.ELEMENT_NODE: {
        if (offset < 0 || offset > node.childNodes.length) {
          console.error("Child node offset is out of range");
          return null;
        }

        let textOffset = 0;
        for (let i = 0; i < offset; i++) {
          textOffset += nodeTextLength(node.childNodes[i]);
        }

        return new TextPosition(node as Element, textOffset);
      }
      default:
        console.error("Point is not in an element or text node");
        return null;
    }
  }

  relativeTo(parent: Element): TextPosition {
    if (!parent.contains(this.element)) {
      throw new Error("Parent is not an ancestor of current element");
    }

    let el = this.element;
    let offset = this.offset;
    while (el !== parent) {
      offset += previousSiblingsTextLength(el);
      if (el.parentElement) {
        el = el.parentElement;
      }
    }

    return new TextPosition(el, offset);
  }
}
