# 0002 — Sử Kế reference screens

Implement the five supplied screenshots with feature-first ConsumerWidget views,
Riverpod view models and go_router route wiring. Local ARB resources contain all
screen copy in Vietnamese and English. The initial locale is Vietnamese to match
the reference. Shared design tokens and presentation widgets live in shared/.

The shared AudioViewModel simulates playback position, seeking, play/pause,
favorites, bookmarks, speed and a sleep timer in memory. There is no audio engine,
account authentication, OAuth, download or sharing backend in this UI task.
Unsupported account/service actions show a localized demo notice.

Artwork is extracted from the user-provided home reference; no screenshot is used
as a screen background. Original low-resolution crops may appear soft when large.
Inter is supplied locally by the user from Google Fonts. Register the static
18pt fonts as the Inter family at weights 400, 500, 600, 700 and 800, plus italic.
Keep the SIL Open Font License with the assets. Both the app theme and explicit
component typography use Inter, and widget previews load the same font files.

Home and search replace the primary location. Detail, player and login are pushed
so Back returns to the origin. Playback state survives those route changes.
