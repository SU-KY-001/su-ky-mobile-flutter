import 'package:flutter/material.dart';
import 'package:su_ky_mobile/shared/design/app_design.dart';
import 'package:su_ky_mobile/shared/widgets/su_ke_widgets.dart';

class WeeklyMissionsScreen extends StatefulWidget {
  const WeeklyMissionsScreen({
    super.key,
    this.onBack,
    this.onMissionDetail,
    this.onHonours,
    this.onHome,
    this.onSearch,
    this.onLibrary,
    this.onProfile,
  });

  final VoidCallback? onBack;
  final VoidCallback? onMissionDetail;
  final VoidCallback? onHonours;
  final VoidCallback? onHome;
  final VoidCallback? onSearch;
  final VoidCallback? onLibrary;
  final VoidCallback? onProfile;

  @override
  State<WeeklyMissionsScreen> createState() => _WeeklyMissionsScreenState();
}

class _WeeklyMissionsScreenState extends State<WeeklyMissionsScreen> {
  static const Color wine = AppDesign.red;
  static const Color ink = AppDesign.ink;
  static const Color muted = AppDesign.muted;
  static const Color cream = AppDesign.canvas;
  static const Color gold = Color(0xFFC18B36);
  static const Color green = Color(0xFF43836A);

  int selectedDay = 2;
  bool showAllTasks = false;
  bool showHistory = false;

  final List<_Mission> missions = [
    _Mission(
      title: 'Lắng nghe dòng chảy lịch sử',
      subtitle: 'Nghe podcast lịch sử trong 30 phút',
      points: 50,
      icon: Icons.headphones_outlined,
      completed: true,
      detail: 'Thời lượng: 30/30 phút',
    ),
    _Mission(
      title: 'Khám phá trận Bạch Đằng',
      subtitle: 'Hoàn thành 2 tập podcast thuộc chủ đề',
      points: 60,
      icon: Icons.menu_book_outlined,
      completed: true,
      detail: 'Tiến độ: 2/2 tập',
    ),
    _Mission(
      title: 'Thử tài sử học',
      subtitle: 'Trả lời đúng ít nhất 4/5 câu hỏi',
      points: 40,
      icon: Icons.assignment_outlined,
      completed: true,
      detail: 'Tiến độ: 4/5 câu',
    ),
    _Mission(
      title: 'Hành trình chưa dừng lại',
      opensDetail: true,
      subtitle: 'Nghe thêm 3 tập podcast bất kỳ',
      points: 70,
      icon: Icons.hearing_outlined,
      completed: false,
      progress: 0.33,
      detail: 'Tiến trình: 1/3 tập',
    ),
    _Mission(
      title: 'Người giữ lửa lịch sử',
      subtitle: 'Nghe podcast vào 5 ngày khác nhau trong tuần',
      points: 80,
      icon: Icons.local_fire_department_outlined,
      completed: false,
      progress: 0.60,
      detail: 'Tiến trình: 3/5 ngày',
    ),
  ];

  int get completedCount =>
      missions.where((mission) => mission.completed).length;

  double get weeklyProgress => completedCount / missions.length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMissionTap(_Mission mission) {
    if (mission.opensDetail && widget.onMissionDetail != null) {
      widget.onMissionDetail!();
      return;
    }
    if (mission.completed) {
      _showMessage('Bạn đã hoàn thành nhiệm vụ này!');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mission.subtitle,
                style: const TextStyle(fontSize: 13, color: muted),
              ),
              const SizedBox(height: 18),
              Text(
                mission.detail,
                style: const TextStyle(
                  color: wine,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _progressBar(mission.progress),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: wine,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () {
                    setState(() {
                      mission.completed = true;
                      mission.progress = 1;
                    });
                    Navigator.pop(sheetContext);
                    _showMessage('Đã hoàn thành nhiệm vụ demo!');
                  },
                  child: const Text('Hoàn thành thử nghiệm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(double progress, {double height = 7}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: const Color(0xFFF0E5DC),
        valueColor: const AlwaysStoppedAnimation<Color>(wine),
      ),
    );
  }

  Widget _panel({
    required Widget child,
    Color color = Colors.white,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3120).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      bottom: MainNavigation(
        index: 0,
        onDiscover: widget.onHome ?? () => Navigator.maybePop(context),
        onSearch: widget.onSearch ?? () {},
        onProfile: widget.onProfile ?? () {},
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        children: [
          _header(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDesign.gap),
            child: Divider(),
          ),
          _backRow(),
          const SizedBox(height: AppDesign.gap),
          _introCard(),
          const SizedBox(height: AppDesign.gap),
          _progressCard(),
          const SizedBox(height: AppDesign.gap),
          _calendarCard(),
          const SizedBox(height: AppDesign.pagePadding),
          _missionsHeader(),
          const SizedBox(height: AppDesign.gap),
          _missionsCard(),
          const SizedBox(height: AppDesign.gap),
          _weeklyReward(),
          const SizedBox(height: AppDesign.gap),
          _quoteCard(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: const BoxDecoration(
              color: wine,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Nhiệm Vụ Tuần',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: wine,
                fontFamily: 'Inter',
              ),
            ),
          ),
          IconButton(
            onPressed:
                widget.onHonours ?? () => _showMessage('Tính năng thành tích'),
            icon: const Icon(
              Icons.military_tech_outlined,
              color: gold,
              size: 21,
            ),
          ),
          GestureDetector(
            onTap: widget.onProfile ?? () => _showMessage('Trang cá nhân'),
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: wine,
              child: Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onBack ?? () => Navigator.maybePop(context),
          child: Container(
            width: 37,
            height: 37,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1EDE8),
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: ink),
          ),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'KHÁM PHÁ LỊCH SỬ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: gold,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Nhiệm Vụ Tuần',
                style: TextStyle(
                  fontSize: 17,
                  color: ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 37,
          height: 37,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF0D1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events_outlined, size: 19, color: gold),
        ),
      ],
    );
  }

  Widget _introCard() {
    return _panel(
      color: const Color(0xFFF8F4F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                '● HÀNH TRÌNH SỬ VIỆT',
                style: TextStyle(
                  color: wine,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Tuần 3/10 – 9/11',
                style: TextStyle(
                  color: muted.withValues(alpha: .9),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Mỗi tuần một trang sử',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lắng nghe lịch sử, tích lũy tri thức và nhận '
            'những phần thưởng xứng đáng qua thử thách của bạn.',
            style: TextStyle(fontSize: 12, color: muted, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _progressCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Tiến độ tuần này',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: wine,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Hoàn thành ${(weeklyProgress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '$completedCount/${missions.length} nhiệm vụ',
            style: const TextStyle(
              fontSize: 24,
              color: wine,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          _progressBar(weeklyProgress, height: 8),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  Icons.stars_rounded,
                  '150',
                  'Điểm tích lũy',
                  const Color(0xFFFFF4DF),
                  gold,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _statBox(
                  Icons.local_fire_department_outlined,
                  '3 Ngày',
                  'Chuỗi liên tiếp',
                  const Color(0xFFFFEEED),
                  wine,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(
    IconData icon,
    String value,
    String label,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(label, style: const TextStyle(fontSize: 9, color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard() {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const dates = ['2', '3', '4', '5', '6', '7', '8'];

    return _panel(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Wrap(
            spacing: AppDesign.gap,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const Text(
                'Điểm danh nghe sử tuần này',
                style: TextStyle(
                  color: ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Hôm nay: Thứ Năm',
                style: TextStyle(
                  color: gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final active = index == selectedDay;
              final completed = index < 3;

              return GestureDetector(
                onTap: () => setState(() => selectedDay = index),
                child: Column(
                  children: [
                    Text(
                      days[index],
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? wine
                            : completed
                            ? const Color(0xFFB65A53)
                            : const Color(0xFFF5F1ED),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dates[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active || completed ? Colors.white : muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Icon(
                      completed ? Icons.check_circle : Icons.circle_outlined,
                      size: 11,
                      color: completed ? wine : const Color(0xFFE1D9D2),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _missionsHeader() {
    return Wrap(
      spacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Nhiệm vụ của bạn',
          style: TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFECE7E2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '${missions.length}',
            style: const TextStyle(
              fontSize: 11,
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() => showHistory = !showHistory);
            if (showHistory) {
              _showMessage('Bạn đã hoàn thành $completedCount nhiệm vụ');
            }
          },
          child: const Text(
            'Lịch sử quy định ›',
            style: TextStyle(
              fontSize: 10,
              color: wine,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionsCard() {
    final visibleMissions = showAllTasks ? missions : missions.take(5).toList();

    return _panel(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      child: Column(
        children: [
          for (var i = 0; i < visibleMissions.length; i++) ...[
            _missionTile(visibleMissions[i]),
            if (i < visibleMissions.length - 1)
              const Divider(height: 1, color: Color(0xFFF0EBE6)),
          ],
          if (!showAllTasks)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => setState(() => showAllTasks = true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: const BorderSide(color: Color(0xFFF0E7E0)),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Xem chi tiết →',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => setState(() => showAllTasks = false),
              child: const Text('Thu gọn'),
            ),
        ],
      ),
    );
  }

  Widget _missionTile(_Mission mission) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onMissionTap(mission),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: mission.completed
                    ? const Color(0xFFFFF3DB)
                    : const Color(0xFFFCE7E5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                mission.icon,
                size: 18,
                color: mission.completed ? gold : wine,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0C8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '+${mission.points} điểm',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mission.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.detail,
                          style: const TextStyle(fontSize: 9, color: muted),
                        ),
                      ),
                      if (mission.completed) ...[
                        const Icon(Icons.check_circle, size: 12, color: green),
                        const SizedBox(width: 3),
                        const Text(
                          'Đã hoàn thành',
                          style: TextStyle(
                            color: green,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else
                        Text(
                          '${(mission.progress * 100).round()}%',
                          style: const TextStyle(
                            color: wine,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  if (!mission.completed) ...[
                    const SizedBox(height: 7),
                    _progressBar(mission.progress, height: 5),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => _onMissionTap(mission),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: wine,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Tiếp tục nghe ›',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyReward() {
    return _panel(
      color: const Color(0xFFFFF1D7),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: wine,
              border: Border.all(color: gold, width: 4),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD77C),
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✧ PHẦN THƯỞNG TUẦN',
                  style: TextStyle(
                    fontSize: 10,
                    color: gold,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Huy hiệu Sử Ký\nƯu Điểm Thường',
                  style: TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hoàn thành đủ 5/5 nhiệm vụ để nhận danh hiệu '
                  'tuần cùng 100 điểm thưởng hoàng gia.',
                  style: TextStyle(color: muted, fontSize: 10, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quoteCard() {
    return _panel(
      color: const Color(0xFFF7F3EF),
      child: const Column(
        children: [
          Text(
            '❞',
            style: TextStyle(
              color: wine,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '"Sử để ghi việc xưa, răn đời sau, mở\n'
            'mang trí đời ta!"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: ink,
              height: 1.6,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '— ĐẠI VIỆT SỬ KÝ TOÀN THƯ',
            style: TextStyle(
              color: gold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Mission {
  _Mission({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
    required this.completed,
    required this.detail,
    this.progress = 1,
    this.opensDetail = false,
  });

  final bool opensDetail;
  final String title;
  final String subtitle;
  final int points;
  final IconData icon;
  final String detail;
  bool completed;
  double progress;
}
