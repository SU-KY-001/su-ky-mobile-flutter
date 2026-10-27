# AGENTS.md — lib/app/

App-wide wiring only.
- `app.dart`: `MaterialApp.router`, theme, config injection.
- `router/app_routes.dart`: ALL path constants. `router/app_router.dart`: ALL
  `GoRoute`s. Add a route = add constant + route; features expose only screen
  widgets.
- `theme/`: `ThemeData` only. Colors/spacing come from the theme, not widgets.
- Imports `features/*` and `core/*`; is imported by `main.dart` only.
- Auth/redirect guards go in `GoRouter.redirect`, not in screens.
