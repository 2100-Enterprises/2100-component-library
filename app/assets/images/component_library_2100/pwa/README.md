# Shared PWA brand icons

The 2100 app icon (paper "C" on brand ink) at the sizes a Progressive Web App needs,
so every 2100 app installs with the same home-screen identity on iOS and Android.

| File | Size | `purpose` |
|---|---|---|
| `icon-192.png` | 192×192 | `any` |
| `icon-384.png` | 384×384 | `any` |
| `icon-512.png` | 512×512 | `any` |
| `icon-192-maskable.png` | 192×192 | `maskable` |
| `icon-512-maskable.png` | 512×512 | `maskable` |

The maskable variants keep the glyph inside the central 80% safe zone on the matching
ink background, so Android's circle/squircle mask never clips it.

## Use in a host app

These are served through the asset pipeline (Propshaft). Reference them from your
`app/views/pwa/manifest.json.erb` with `asset_path` so the fingerprinted URLs resolve:

```erb
"icons": [
  { "src": "<%= asset_path("component_library_2100/pwa/icon-192.png") %>", "sizes": "192x192", "type": "image/png", "purpose": "any" },
  { "src": "<%= asset_path("component_library_2100/pwa/icon-512.png") %>", "sizes": "512x512", "type": "image/png", "purpose": "any" },
  { "src": "<%= asset_path("component_library_2100/pwa/icon-192-maskable.png") %>", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
  { "src": "<%= asset_path("component_library_2100/pwa/icon-512-maskable.png") %>", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
]
```

The head tags, service worker and install banner that go with them are in the main README's
[Progressive Web App](../../../../../README.md#progressive-web-app) section.
