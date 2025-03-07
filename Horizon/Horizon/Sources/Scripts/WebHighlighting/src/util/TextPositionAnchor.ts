import { TextRange } from "./TextRange";

export class TextPositionAnchor {
  root: Element;
  start: number;
  end: number;

  constructor(root: Element, start: number, end: number) {
    this.root = root;
    this.start = start;
    this.end = end;
  }

  static fromRange(root: Element, range: Range): TextPositionAnchor | null {
    const textRange = TextRange.fromRange(range)?.relativeTo(root);
    if (!textRange) return null;
    return new TextPositionAnchor(
      root,
      textRange.start.offset,
      textRange.end.offset
    );
  }

  static fromSelector(
    root: Element,
    selector: TextPositionSelector
  ): TextPositionAnchor {
    return new TextPositionAnchor(root, selector.start, selector.end);
  }

  toSelector(): TextPositionSelector {
    return {
      start: this.start,
      end: this.end,
    };
  }

  toRange(): Range {
    return TextRange.fromOffsets(this.root, this.start, this.end).toRange();
  }
}
