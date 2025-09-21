import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xo/core/network/ws_client.dart';
import 'package:xo/features/room/presentation/bloc/room_event.dart';
import 'package:xo/features/room/presentation/bloc/room_state.dart';
import '../../model/room.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final WSClient ws;
  StreamSubscription? _wsSub;

  RoomBloc({required this.ws}) : super(RoomState(rooms: [])) {
    on<FetchRooms>(_onFetchRooms);
    on<UpdateRooms>(_onUpdateRooms);
    on<CreateRoom>(_onCreateRoom);
    on<RoomCreated>(_onRoomCreated);
    on<LeaveRoom>(_onLeaveRoom);
    on<JoinRoom>(_onJoinRoom);
  }

  void _onFetchRooms(FetchRooms event, Emitter<RoomState> emit) {
    ws.connect();
    ws.onConnectedStream.listen((_) {
      ws.send({'type': 'fetch_rooms'});
    });
    _wsSub ??= ws.onMessageStream.listen((message) {
      if (message is Map<String, dynamic>) {
        switch (message['type']) {
          case 'room_list':
            final roomsData = message['data'] as List<dynamic>? ?? [];
            final rooms = roomsData.map((r) => Room.fromJson(r)).toList();
            add(UpdateRooms(rooms));
            break;

          case 'room_created':
            final room = Room.fromJson(message['data'] as Map<String, dynamic>);
            add(RoomCreated(room));
            break;
          default:
        }
      }
    });
  }
  void _onJoinRoom(JoinRoom event, Emitter<RoomState> emit) {
    ws.send({
      "type": "join_room",
      "data": {
        "roomId": event.roomId,
        "playerId": event.playerId,
      }
    });
  }
  void _onLeaveRoom(LeaveRoom event, Emitter<RoomState> emit) {
    ws.send({
      "type": "leave_room",
      "data": {
        "roomId": event.roomId,
        "playerId": event.playerId,
      }
    });
  }

  void _onCreateRoom(CreateRoom event, Emitter<RoomState> emit) {
    ws.send({
      "type": "create_room",
      "data": {
        "name": event.roomName,
        'creatorId': event.creatorId,
      }
    });
  }



  void _onUpdateRooms(UpdateRooms event, Emitter<RoomState> emit) {
    emit(RoomState(rooms: event.rooms));
  }
  void _onRoomCreated(RoomCreated event, Emitter<RoomState> emit) {
    emit(state.copyWith(lastCreatedRoom: event.room));
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    ws.close();
    return super.close();
  }

}
