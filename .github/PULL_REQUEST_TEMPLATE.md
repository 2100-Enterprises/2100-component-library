# Add fade-in animations to StatComponent and AccordionItemComponent

## Changes
- Adds `animate-fade-in` CSS keyframe animation (0.5s, easing-out)
- Applied to StatComponent root with staggered delays on VALUE/CHANGE/HINT
- Applied to AccordionItemComponent body content
- Added 4 CSS custom properties for animation timing

## Visual behavior
- Content fades in from below (10px translateY) with opacity transition
- StatComponent elements reveal sequentially (100ms gaps)
- AccordionItem content fades when opened

## Testing
Open `http://localhost:3000/portal/admin` to verify animations.
