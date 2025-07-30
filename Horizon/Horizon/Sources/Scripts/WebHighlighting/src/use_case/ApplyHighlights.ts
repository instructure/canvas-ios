import { RangeAnchor } from "../util/RangeAnchor";

export default function applyHighlights(highlights: [NotebookTextSelection]) {
  clearHighlights();
  highlights.forEach(addHighlight);
}

// *********************** Private *********************** //

const highlightClassName = "notebook-highlight";

export const addHighlight = (notebookTextSelection: NotebookTextSelection) => {
  let parent = document.getElementById("parent-container");
  if (!parent) return;

  let range = RangeAnchor.fromSelector(
    parent,
    notebookTextSelection.range
  )?.toRange();
  if (!range) return;

  const textNodeSpans = getHighlightRange(range);
  for (const textNode of textNodeSpans) {
    const parent = textNode.parentNode as HTMLElement;

    const highlightElement = createHighlightElement({
      textContent: textNode.textContent,
      notebookTextSelection,
    });

    if (!highlightElement) return;
    highlightElement.appendChild(createFlagIcon(notebookTextSelection));
    parent.replaceChild(highlightElement, textNode);
  }
};

function createFlagIcon(notebookTextSelection: NotebookTextSelection): Node {
  const flagSpan = document.createElement("span");
  flagSpan.innerHTML =
    `
    <div style="display: flex; align-items: center; justify-content: center; position: absolute; left: 0px; top: 0px; border-radius: 50%; transform: translate(-50%, -50%); width: 16px; height: 16px; background-color: ` +
    notebookTextSelection.borderColor +
    `; z-index: 100;">
      <svg viewBox="0 -960 960 960" rotate="0" width="12" height="12" aria-hidden="true" role="presentation" focusable="false" class="css-f8fjsy-inlineSVG-svgIcon" style="width: 12px; height: 12px;">
        <g role="presentation">
          <path fill="#FFFFFF" d="` +
    notebookTextSelection.iconSVG +
    `">
          </path>
        </g>
      </svg>
    </div>`;
  return flagSpan;
}

function clearHighlights() {
  const elements = document.getElementsByClassName(highlightClassName);
  while (elements.length) {
    const element = elements[0];
    element.replaceWith(...element.childNodes);
  }
}

// Find all of the text nodes in the range and group them into spans
const getHighlightRange = (range: Range): Text[] => {
  const textNodes = wholeTextNodesInRange(range);
  const whitespace = /^\s*$/;

  // Filter out text nodes that consist only of whitespace
  return textNodes.filter((node) => {
    const parentElement = node.parentElement;
    return (
      (parentElement?.childNodes.length === 1 &&
        parentElement?.tagName === "SPAN") ||
      !whitespace.test(node.data)
    );
  });
};

const wholeTextNodesInRange = (range: Range): Text[] => {
  if (range.collapsed) {
    return [];
  }

  let root = range.commonAncestorContainer as Node | null;
  if (root && root.nodeType !== Node.ELEMENT_NODE) {
    root = root.parentElement;
  }
  if (!root) {
    return [];
  }

  const textNodes = [];
  const nodeIter = root?.ownerDocument?.createNodeIterator(
    root,
    NodeFilter.SHOW_TEXT // Only return `Text` nodes.
  );
  let node: Node | null = nodeIter?.nextNode() || null;

  while (node) {
    if (!isNodeInRange(range, node)) {
      node = nodeIter?.nextNode() || null;
      continue;
    }

    const text = node as Text;

    if (text === range.startContainer && range.startOffset > 0) {
      text.splitText(range.startOffset);
      node = nodeIter?.nextNode() || null;
      continue;
    }

    if (text === range.endContainer && range.endOffset < text.data.length) {
      text.splitText(range.endOffset);
    }

    textNodes.push(text);
    node = nodeIter?.nextNode() || null;
  }

  return textNodes;
};

const isNodeInRange = (range: Range, node: Node) => {
  try {
    const length = node.nodeValue?.length ?? node.childNodes.length;
    return (
      range.comparePoint(node, 0) <= 0 && range.comparePoint(node, length) >= 0
    );
  } catch {
    return false;
  }
};

// Notify the native code that a highlight has been tapped
const notifyiOSOfHighlightTap = (
  notebookTextSelection: NotebookTextSelection
) => {
  const messageHandlers = window.webkit?.messageHandlers;
  if (!messageHandlers) return;
  messageHandlers.notebookHighlightTap.postMessage(
    JSON.stringify(notebookTextSelection)
  );
};

// Given our text to wrap and the notebookTextSelection object, wrap the text in a span with the appropriate styles
// Applies an onclick handler to call when a highlight is tapped
const createHighlightElement = ({
  textContent,
  notebookTextSelection,
}: {
  textContent: string | undefined | null;
  notebookTextSelection: NotebookTextSelection;
}): HTMLElement | null => {
  if (!textContent) return null;

  const span = document.createElement("span");
  span.classList.add(highlightClassName);
  span.onclick = () => notifyiOSOfHighlightTap(notebookTextSelection);
  span.style.cssText = buildHighlightStyle(notebookTextSelection);
  span.textContent = textContent;

  return span;
};

// Given the NotebookTextSelection, build the CSS to apply to the highlights
export const buildHighlightStyle = (
  notebookTextSelection: NotebookTextSelection
): string =>
  `position: relative;
   padding: 0px;
   border-top: none;
   border-right: none;
   border-bottom: 1px solid ${notebookTextSelection.borderColor};
   background-color: ${notebookTextSelection.backgroundColor};`;
