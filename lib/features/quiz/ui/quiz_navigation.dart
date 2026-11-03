import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';

/// Leaves the quiz back to the episode player, even on a cold deep link.
void leaveQuiz(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.player);
