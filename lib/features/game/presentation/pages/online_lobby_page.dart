import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xo/features/room/model/room.dart';
import 'package:xo/features/room/presentation/bloc/room_event.dart';

import '../../../auth/data/models/user_local_storage.dart';
import '../../../room/presentation/bloc/room_bloc.dart';
class OnlineLobbyPage extends StatefulWidget {
  const OnlineLobbyPage({super.key});

  @override
  State<OnlineLobbyPage> createState() => _OnlineLobbyPageState();
}

class _OnlineLobbyPageState extends State<OnlineLobbyPage> {
  late Room room;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    room = ModalRoute.of(context)!.settings.arguments as Room;
    final roomid= room.status;
    print('Room ID: $roomid');
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E2C),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            final roomBloc = context.read<RoomBloc>();
            final userLocalStorage = context.read<UserLocalStorage>();

            return IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {

                final user = await userLocalStorage.getUser();

                if (user != null) {
                  roomBloc.add(LeaveRoom(roomId: room.id, playerId: user.id));
                }

                if (!mounted) return;
                Navigator.of(context).pop();
              },
            );
          },
        ),
        title: Text('TIC TAC TOE', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          // Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _scoreBox('Bạn', '1', Colors.red),
                _scoreBox('Đối thủ', '0', Colors.green),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Turn indicator

          Text(
              room.status == 'your_turn'
                  ? 'Lượt của bạn'
                  : room.status == 'opponent_turn'
                  ? 'Lượt đối thủ'
                  : 'Đang chờ...',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Tic Tac Toe board
          _board(),
          SizedBox(height: 24),
          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.white24,
                  ),
                  onPressed: () {},
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('Đầu hàng', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.white12,
                  ),
                  onPressed: () {},
                  child: Text('Luật chơi', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Score box widget
  Widget _scoreBox(String name, String score, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(name, style: TextStyle(color: Colors.white70)),
          SizedBox(height: 4),
          Text(score, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Tic Tac Toe board
  Widget _board() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(3, (i) {
          return Row(
            children: List.generate(3, (j) {
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}