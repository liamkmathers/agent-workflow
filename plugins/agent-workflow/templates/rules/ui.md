---
paths: components/**, app/**/*.tsx
---
- No native `<select>`, `<input type=date>`, or browser dialogs. Use the shared menu and picker components.
- Typography through the three font variables only. No hardcoded font-family.
- Motion under `prefers-reduced-motion`. Mount animations fade and rise; nothing bounces.
- Loading states are skeletons that crossfade into content, not spinners, unless the wait is under 300ms.
- Citations and sources are rendered inline and visible, never collapsed by default.
