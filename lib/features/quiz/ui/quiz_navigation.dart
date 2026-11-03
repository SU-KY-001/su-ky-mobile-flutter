import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/app/router/app_routes.dart';

/// Leaves the quiz back to where it was opened, or to the Quiz tab on a cold
/// deep link that has no back stack.
void leaveQuiz(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.quizzes);
