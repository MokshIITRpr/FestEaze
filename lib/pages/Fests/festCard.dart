import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fest_app/pages/Events/eventTemplatePage.dart';
import 'package:intl/intl.dart';

class FestCard extends StatefulWidget {
  bool isAdmin;
  DocumentReference eventRef;
  Map<String, dynamic> eventData;
  final void Function(
    DocumentReference eventRef,
    String field,
    Map<String, dynamic> eventData,
  ) updateEvent;
  final void Function(String field, DocumentReference eventRef) removeEvent;
  void Function(DocumentReference eventRef, BuildContext context) toggleFavorite;
  bool isFav;
  String field;
  FestCard(
      {super.key,
      required this.isAdmin,
      required this.eventRef,
      required this.eventData,
      required this.updateEvent,
      required this.removeEvent,
      required this.field,
      required this.isFav,
      required this.toggleFavorite});
  @override
  State<FestCard> createState() => _FestCardState();
}

class _FestCardState extends State<FestCard> {
  late bool favorite;   
  @override
  void initState() {
    super.initState();
    favorite = widget.isFav;
  }

  @override
  Widget build(BuildContext context) {
    String eventName = widget.eventData['eventName'] ?? 'No title';
    String venue = widget.eventData['venue'] ?? 'Unknown';
    // Document ID.
    String docId = widget.eventRef.id;
    String type = widget.eventData['type'].trim() ?? 'None';
    String imageType =
        (type == 'None' ? 'assets/Default.jpg' : 'assets/$type.jpeg');

    // Handle Timestamp fields.
    Timestamp timestampDate = widget.eventData['date'] ?? Timestamp.now();
    Timestamp timestampStartTime =
        widget.eventData['startTime'] ?? Timestamp.now();
    Timestamp timestampEndTime = widget.eventData['endTime'] ?? Timestamp.now();

    DateTime date = timestampDate.toDate();
    DateTime startTime = timestampStartTime.toDate();
    DateTime endTime = timestampEndTime.toDate();

    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String formattedStartTime = DateFormat('HH:mm').format(startTime);
    String formattedEndTime = DateFormat('HH:mm').format(endTime);

    String timeRange = '$formattedStartTime - $formattedEndTime';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventTemplatePage(
              title: eventName,
              isSuperAdmin: widget.isAdmin,
              eventRef: widget.eventRef,
            ),
          ),
        );
      },
      child: Container(
        width: 200, // Fixed width for square-shaped card.
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // Background color.
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.isAdmin
                  ? Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: AssetImage(imageType),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Edit icon on the top right.
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  widget.updateEvent(widget.eventRef,
                                      widget.field, widget.eventData);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.withOpacity(0.8),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Remove icon on the top left.
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  widget.removeEvent(
                                      widget.field, widget.eventRef);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.asset(
                        imageType,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            widget.toggleFavorite(widget.eventRef, context);
                            setState((){
                              favorite=!favorite;
                            });
                            },
                          child: Icon(
                            favorite
                                ? Icons.star
                                : Icons.star_border_outlined,
                            size: 20,
                            color: favorite
                                ? const Color.fromARGB(255, 236, 54, 54)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(' $formattedDate',
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(' $timeRange',
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 20, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(' $venue',
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
