import '../../model/room.dart';

abstract class RoomEvent{}

class FetchRooms extends RoomEvent{}

class UpdateRooms extends RoomEvent{
  final List<Room> rooms;
  UpdateRooms(this.rooms);
}
class CreateRoom extends RoomEvent {
  final String roomName;
  final String creatorId;
  CreateRoom({required this.roomName, required this.creatorId});
}
class RoomCreated extends RoomEvent {
  final Room room;
  RoomCreated(this.room);
}
class JoinRoom extends RoomEvent {
  final String roomId;
  final String playerId;
  JoinRoom({required this.roomId, required this.playerId});
}
class LeaveRoom extends RoomEvent {
  final String roomId;
  final String playerId;

  LeaveRoom({required this.roomId, required this.playerId});
}