import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const CalendarApp());
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: CalendarPage(
        toggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
        isDark: isDark,
      ),
    );
  }
}

class Event {
  String title;
  String category;

  Event(this.title, this.category);
}

class CalendarPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const CalendarPage({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();

  Map<DateTime, List<Event>> events = {};

  String searchText = "";

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  List<Event> getEventsForDay(DateTime day) {
    return events.entries
        .where((entry) => isSameDay(entry.key, day))
        .expand((entry) => entry.value)
        .toList();
  }

  void addEvent(String title, String category) {
    final selectedDate =
    DateTime(today.year, today.month, today.day);

    if (events[selectedDate] == null) {
      events[selectedDate] = [];
    }

    events[selectedDate]!.add(Event(title, category));

    setState(() {});
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "Work":
        return Colors.blue;
      case "Birthday":
        return Colors.green;
      case "Personal":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void showAddEventDialog() {
    TextEditingController controller = TextEditingController();
    String selectedCategory = "Work";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Event Title",
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "Work",
                        child: Text("Work"),
                      ),
                      DropdownMenuItem(
                        value: "Personal",
                        child: Text("Personal"),
                      ),
                      DropdownMenuItem(
                        value: "Birthday",
                        child: Text("Birthday"),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      addEvent(
                        controller.text,
                        selectedCategory,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Event> dayEvents = getEventsForDay(today);

    if (searchText.isNotEmpty) {
      dayEvents = dayEvents
          .where((event) => event.title
          .toLowerCase()
          .contains(searchText.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Calendar"),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddEventDialog,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Selected Date: ${today.toString().split(" ")[0]}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  today = DateTime.now();
                });
              },
              child: const Text("Go To Today"),
            ),

            const SizedBox(height: 10),

            TableCalendar(
              locale: "en_US",
              rowHeight: 52,
              focusedDay: today,
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),

              selectedDayPredicate: (day) =>
                  isSameDay(day, today),

              onDaySelected: _onDaySelected,

              eventLoader: (day) {
                return getEventsForDay(day);
              },

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),

              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: const InputDecoration(
                hintText: "Search Events",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),

            const SizedBox(height: 15),

            Expanded(
              child: dayEvents.isEmpty
                  ? const Center(
                child: Text(
                  "No Events Found",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  Event event = dayEvents[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        getCategoryColor(event.category),
                      ),
                      title: Text(event.title),
                      subtitle: Text(event.category),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(event: event),
                          ),
                        );
                      },

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            events[DateTime(
                              today.year,
                              today.month,
                              today.day,
                            )]
                                ?.remove(event);
                          });
                        },
                      ),
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Category: ${event.category}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




