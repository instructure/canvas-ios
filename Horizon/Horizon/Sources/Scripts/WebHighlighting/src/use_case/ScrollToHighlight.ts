export default function scrollToHighlight(notebookTextSelection: NotebookTextSelection) {
  const targetStart = notebookTextSelection.textPosition.start.toString();
  const targetEnd = notebookTextSelection.textPosition.end.toString();

  const highlightElements = document.getElementsByClassName("notebook-highlight");

  for (let i = 0; i < highlightElements.length; i++) {
    const element = highlightElements[i] as HTMLElement;
    const elementStart = element.getAttribute("data-text-start");
    const elementEnd = element.getAttribute("data-text-end");

    if (elementStart === targetStart && elementEnd === targetEnd) {
      element.scrollIntoView({
        behavior: "smooth",
        block: "center"
      });
      return;
    }
  }
}
