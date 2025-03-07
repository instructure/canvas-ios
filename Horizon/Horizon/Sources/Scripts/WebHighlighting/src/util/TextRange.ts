import { TextPosition } from "./TextPosition";
import { resolveOffsets } from "./utils";

export enum ResolveDirection {
  FORWARDS = 1,
  BACKWARDS = 2,
}

export class TextRange {
  public start: TextPosition;
  public end: TextPosition;

  constructor(start: TextPosition, end: TextPosition) {
    this.start = start;
    this.end = end;
  }

  toRange(): Range {
    let start: { node: Text; offset: number };
    let end: { node: Text; offset: number };

    if (
      this.start.element === this.end.element &&
      this.start.offset <= this.end.offset
    ) {
      [start, end] = resolveOffsets(
        this.start.element,
        this.start.offset,
        this.end.offset
      );
    } else {
      start = this.start.resolve({
        direction: ResolveDirection.FORWARDS,
      });
      end = this.end.resolve({ direction: ResolveDirection.BACKWARDS });
    }

    const range = new Range();
    range.setStart(start.node, start.offset);
    range.setEnd(end.node, end.offset);
    return range;
  }

  static fromRange(range: Range): TextRange | null {
    const start = TextPosition.fromPoint(
      range.startContainer,
      range.startOffset
    );
    const end = TextPosition.fromPoint(range.endContainer, range.endOffset);
    if (!start || !end) {
      return null;
    }
    return new TextRange(start, end);
  }

  static fromOffsets(root: Element, start: number, end: number): TextRange {
    return new TextRange(
      new TextPosition(root, start),
      new TextPosition(root, end)
    );
  }

  relativeTo(element: Element): TextRange {
    return new TextRange(
      this.start.relativeTo(element),
      this.end.relativeTo(element)
    );
  }
}
