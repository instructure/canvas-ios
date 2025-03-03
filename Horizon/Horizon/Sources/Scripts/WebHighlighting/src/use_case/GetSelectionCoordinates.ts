import { RangeAnchor } from "../util/RangeAnchor";
import { TextPositionAnchor } from "../util/TextPositionAnchor";

export default function getSelectionCoordinates(): NotebookTextSelection {
  const selection = window.getSelection();
  const range = selection?.getRangeAt(0);
  const parentRef = document.getElementById("parent-container");

  const rangeAnchor =
    parentRef && range ? RangeAnchor.fromRange(parentRef, range) : null;

  const textAnchor =
    parentRef && range ? TextPositionAnchor.fromRange(parentRef, range) : null;

  return {
    selectedText: selection?.toString(),
    textPosition: textAnchor?.toSelector(),
    range: rangeAnchor?.toSelector(),
  } as NotebookTextSelection;
}
