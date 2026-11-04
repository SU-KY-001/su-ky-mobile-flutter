# ADR 0013: Material Symbols for light-weight icons

- Status: accepted
- Date: 2026-11-04

## Context

The bottom navigation icons looked heavy next to the lighter text. The
built-in `Icons.*` set is a static font with a single stroke weight, so
`IconThemeData.weight` has no effect on it and `*_outlined` variants cannot
get thinner.

## Decision

- Add `material_symbols_icons` (Apache-2.0, a variable font with a weight
  axis) as a direct dependency.
- The four `AppTab` icons use `Symbols.*`; the `NavigationBar` icon theme in
  `app_theme.dart` sets `weight` to `_navIconWeight` (currently 400, the font
  default; lower it for thinner strokes).
- Every other icon in the app uses `Symbols.*` too, so there is one icon set.
  Solid glyphs (play/pause in filled buttons, status check marks, stars) pass
  `fill: 1` at the call site.

## Consequences

+ One theme constant controls nav icon stroke weight.
- A second icon font ships with the app. Release size was not measured when
  this was written; check the release build size when this changes.
- Two icon sets coexist, so new nav-style icons must pick `Symbols`.

## Rollback

Restore the `Icons.*` constants in `AppTab`, drop `weight` from the icon theme
and remove the package from `pubspec.yaml`.
