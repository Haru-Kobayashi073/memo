import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_app/pages/add_edit_memo_page.dart';
import 'package:memo_app/pages/memo_detail_page.dart';
import '../model/memo.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key, required this.title});
  final String title;

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final memoCllection = FirebaseFirestore.instance.collection('memo');

  Future<void> deleteMemo(String id) async {
    final doc = FirebaseFirestore.instance.collection('memo').doc(id);
    await doc.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Flutter × Firebase'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: memoCllection.orderBy('createdDate', descending: true).snapshots(), //追加や変更を検知
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text('データがありません。'),
              );
            }
            final docs = snapshot.data!.docs; //docsはdocuments
            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: ((context, index) {
                  Map<String, dynamic> data =
                      docs[index].data() as Map<String, dynamic>;

                  final Memo fetchMemo = Memo(
                    id: docs[index].id,
                    title: data['title'],
                    detail: data['detail'],
                    createdDate: data['createdDate'],
                    updatedDate: data['updatedDate'],
                  );
                  return ListTile(
                    title: Text(fetchMemo.title),
                    trailing: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddEditMemoPage(
                                                currentMemo: fetchMemo,
                                              ),
                                            ));
                                      },
                                      leading: Icon(Icons.edit),
                                      title: Text('編集'),
                                    ),
                                    ListTile(
                                      onTap: () async {
                                        await deleteMemo(fetchMemo.id);
                                        Navigator.pop(context);
                                      },
                                      leading: Icon(Icons.delete),
                                      title: Text('削除'),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    onTap: (() {
                      //確認画面に遷移する記述
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  MemoDetailPage(fetchMemo))));
                    }),
                  );
                }));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddEditMemoPage()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
