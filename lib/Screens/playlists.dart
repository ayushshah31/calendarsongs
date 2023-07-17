import 'package:calendarsong/constants/routes.dart';
import 'package:flutter/material.dart';

class Playlists extends StatefulWidget {
  const Playlists({Key? key}) : super(key: key);

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mantra App"),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Playlists: ", style: TextStyle(fontSize: 20),),
            ),
            // const Spacer(),
            Card(
              color: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("By Mantra"),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async{
                              Navigator.of(context).pushNamed(customCalendar);
                            },
                            icon:const Icon(Icons.arrow_forward_ios),
                        )
                        // IconButton(onPressed: (){}, icon: const Icon(Icons.keyboard_arrow_down_sharp))
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Spacer(flex: 1),
            Card(
              color: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("By Day"),
                    IconButton(onPressed: (){
                      const snackBar = SnackBar(
                        content: Text('Available in Pro'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }, icon: const Icon(Icons.download))
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
