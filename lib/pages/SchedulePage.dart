import 'package:flutter/material.dart';
import '../interface/schedule.dart';
import '../interface/station.dart';
import '../services/ScheduleService.dart';

class SchedulePage extends StatefulWidget {
  final Station station;
  const SchedulePage({super.key, required this.station});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Future<List<Schedule>> scheduleFuture;

  @override
  void initState() {
    super.initState();
    scheduleFuture = ScheduleService().fetchSchedule(widget.station.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F4FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Jadwal", style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<List<Schedule>>(
        future: scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // final schedulesToShow = snapshot.data ?? [];

          final allSchedules = snapshot.data ?? [];
          final now = DateTime.now();

          // batas 1 jam ke depan
          final oneHourLater = now.add(const Duration(hours: 1));

          final schedulesToShow =
              allSchedules.where((s) {
                final localTime = s.departsAt.toLocal();

                // Buat DateTime sesuai hari ini (karena tanggal API tidak relevan)
                final departToday = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  localTime.hour,
                  localTime.minute,
                  localTime.second,
                );

                return departToday.isAfter(now) &&
                    departToday.isBefore(oneHourLater);
              }).toList()..sort((a, b) {
                final ta = a.departsAt.toLocal();
                final tb = b.departsAt.toLocal();
                return ta.compareTo(tb);
              });

          if (schedulesToShow.isEmpty) {
            return const Center(
              child: Text("Tidak ada jadwal dalam 1 jam ke depan."),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header "Stasiun / Tambun"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stasiun",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.station.name
                          .toLowerCase()
                          .split(' ')
                          .map(
                            (w) => w.isEmpty
                                ? ''
                                : '${w[0].toUpperCase()}${w.substring(1)}',
                          )
                          .join(' '),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: schedulesToShow.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada jadwal tersisa hari ini.",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: schedulesToShow.length,
                        itemBuilder: (context, index) {
                          final s = schedulesToShow[index];
                          return _ScheduleItem(schedule: s);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleItem({required this.schedule});

  Color _parseColor(String hex) {
    try {
      var clean = hex.replaceFirst('#', '');
      if (clean.length == 6) {
        clean = 'FF$clean';
      }
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return const Color(0xFF0084D8); // default biru
    }
  }

  String _formatTime(DateTime dt) {
    final l = dt.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _remainingText(DateTime departToday) {
    final diffMinutes = departToday.difference(DateTime.now()).inMinutes;
    if (diffMinutes <= 0) return 'Sedang berangkat';
    if (diffMinutes == 1) return '1 menit lagi';
    return '$diffMinutes menit lagi';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final localDepart = schedule.departsAt.toLocal();

    // jam keberangkatan "hari ini" (tanggal disamakan dengan hari ini)
    final departToday = DateTime(
      now.year,
      now.month,
      now.day,
      localDepart.hour,
      localDepart.minute,
      localDepart.second,
    );

    final color = _parseColor(schedule.color);

    // ambil tujuan dari route, contoh: "CIKARANG-MANGGARAI" → "Manggarai"
    String destination;
    if (schedule.route.contains('-')) {
      destination = schedule.route.split('-').last;
    } else {
      destination = schedule.route;
    }

    return Container(
      color: const Color(0xFFF9F4FF),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // garis vertikal di kiri
            Container(
              width: 3,
              height: 64,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // info kiri: line, arah, tujuan, train id
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.line.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Arah menuju",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.trainId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // info kanan: waktu
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Berangkat pukul",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(localDepart),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _remainingText(departToday),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
