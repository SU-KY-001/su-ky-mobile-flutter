# 0004 — App shell and navigation

`routerProvider` builds one `GoRouter` for the app's lifetime. It never watches
state (that would rebuild the router and reset navigation); session changes
re-run redirects through `refreshListenable`.

Tabs use `StatefulShellRoute.indexedStack`. The `AppTab -> GoRoute` map in
`app_router.dart` is the single source of truth for both the shell branches and
the tab bar: its order is the branch order and the bar order. A plan that adds a
tab adds one entry. Only tabs that have a screen are registered (Discover and
Profile for now); History, Podcast and Quiz appear when their screens land.

Detail routes (search, login, series, player, quiz, missions, honours) sit at the
root, so they cover the shell and hide the tab bar and mini-player, as the RN app
does with `hideTabs`. Profile keeps the tab bar.

`AppShell` owns the mini-player. It shows when `AudioState.loaded` is true. That
flag is a bridge for the mock audio and goes away with the real playback
controller.

Guests can browse everything. The auth guard (`authGuard`) applies only to the
quiz route, because the quiz API answers 401 to guests. The Profile tab does not
redirect: a guest sees a sign-in card, as in RN. While the session is not yet
hydrated the guard does not redirect, so a stored session is never mistaken for a
guest.

Login receives `returnTo` as a query parameter. `AppRoutes.safeReturnTo` accepts
only in-app absolute paths and rejects `//host`, backslashes and `/login`
(deep links are untrusted; this also prevents redirect loops). Closing the login
screen drops the intent.

Consequence: tests that build a flat router around single screens must be
rewritten against `routerProvider`.
