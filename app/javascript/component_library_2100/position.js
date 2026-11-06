// Places a fixed-position element (a popover in the top layer) beside an anchor.
//
//   place(button, menu, { placement: "bottom-start", offset: 4 })
//
// placement is "<side>" or "<side>-<start|end>", with side one of top, bottom, left, right.
// It flips to the opposite side when the element would leave the viewport, then clamps.
const OPPOSITE = { top: "bottom", bottom: "top", left: "right", right: "left" }

function coords(side, align, anchor, box, offset) {
  if (side === "top" || side === "bottom") {
    return {
      top: side === "top" ? anchor.top - box.height - offset : anchor.bottom + offset,
      left: align === "start" ? anchor.left : align === "end" ? anchor.right - box.width : anchor.left + (anchor.width - box.width) / 2
    }
  }

  return {
    left: side === "left" ? anchor.left - box.width - offset : anchor.right + offset,
    top: align === "start" ? anchor.top : align === "end" ? anchor.bottom - box.height : anchor.top + (anchor.height - box.height) / 2
  }
}

function overflows(side, position, box, viewport, padding) {
  if (side === "top") return position.top < padding
  if (side === "bottom") return position.top + box.height > viewport.height - padding
  if (side === "left") return position.left < padding
  return position.left + box.width > viewport.width - padding
}

export function place(anchorElement, floating, { placement = "bottom", offset = 4, padding = 4 } = {}) {
  const anchor = anchorElement.getBoundingClientRect()
  const box = floating.getBoundingClientRect()
  const viewport = { width: document.documentElement.clientWidth, height: document.documentElement.clientHeight }

  let [side, align = "center"] = placement.split("-")
  let position = coords(side, align, anchor, box, offset)

  if (overflows(side, position, box, viewport, padding)) {
    const flipped = coords(OPPOSITE[side], align, anchor, box, offset)
    if (!overflows(OPPOSITE[side], flipped, box, viewport, padding)) position = flipped
  }

  const clamp = (value, max) => Math.max(padding, Math.min(value, max))
  floating.style.top = `${clamp(position.top, viewport.height - box.height - padding)}px`
  floating.style.left = `${clamp(position.left, viewport.width - box.width - padding)}px`
}
