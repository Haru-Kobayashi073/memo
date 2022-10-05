import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_app/pages/add_memo_page.dart';
import 'package:memo_app/pages/memo_detail_page.dart';
import '../model/memo.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key, required this.title});
  final String title;

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<Memo> memoList = [];

  Future<void> fetchmemo() async {
    final memocollection =
        await FirebaseFirestore.instance.collection('memo').get();
    final docs = memocollection.docs;
    for (var doc in docs) {
      Memo fetchmemo = Memo(
          title: doc.data()['title'],
          detail: doc.data()['detail'],
          createdDate: doc.data()['createdDate']);
      memoList.add(fetchmemo);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchmemo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter × Firebase'),
      ),
      body: ListView.builder(
          itemCount: memoList.length,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text(memoList[index].title),
              onTap: (() {
                //確認画面に遷移する記述
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) =>
                            MemoDetailPage(memoList[index]))));
              }),
            );
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddMemoPage()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
