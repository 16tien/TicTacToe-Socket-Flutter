import 'package:xo/features/room/model/room.dart';

class RoomState {
  final List<Room> rooms;
  final Room? lastCreatedRoom;

  RoomState({required this.rooms, this.lastCreatedRoom});

  RoomState copyWith({List<Room>? rooms, Room? lastCreatedRoom}) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      lastCreatedRoom: lastCreatedRoom ?? this.lastCreatedRoom,
    );
  }
}
