import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/models/user_local_storage.dart';
import '../bloc/room_bloc.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchRooms());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phòng')),
      body: BlocListener<RoomBloc, RoomState>(
        listenWhen: (previous, current) =>
        previous.lastCreatedRoom != current.lastCreatedRoom &&
            current.lastCreatedRoom != null,
        listener: (context, state) {
          final room = state.lastCreatedRoom!;
          Navigator.pushNamed(context, '/online-lobby',arguments: room);
        },
        child: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state.rooms.isEmpty) {
              return const Center(
                child: Text('Chưa có phòng nào', style: TextStyle(fontSize: 16)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: state.rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                final isFull = room.players.length >= 2;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Người chơi: ${room.players.length}/2',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () {
                          // Join room thông qua Bloc
                          final userLocalStorage = context.read<UserLocalStorage>();
                          userLocalStorage.getUser().then((user) {
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bạn cần đăng nhập để tham gia phòng'),
                                ),
                              );
                              return;
                            }
                            final roomBloc = context.read<RoomBloc>();
                            roomBloc.add(JoinRoom(
                              roomId: room.id,
                              playerId: user.id,
                            ));
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFull ? Colors.grey : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isFull ? 'Đầy' : 'Tham gia'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final roomBloc = context.read<RoomBloc>();
          final userLocalStorage = context.read<UserLocalStorage>();
          final user = await userLocalStorage.getUser();

          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn cần đăng nhập để tạo phòng')),
            );
            return;
          }

          roomBloc.add(
            CreateRoom(
              roomName: "Phòng mới",
              creatorId: user.id,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo phòng'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}