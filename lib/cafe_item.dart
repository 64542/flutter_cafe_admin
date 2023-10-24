import 'package:flutter/material.dart';
import 'my_cafe.dart';

MyCafe myCafe = MyCafe();
String categoryCollectionName = 'cafe-category';
String itemCollectionName = 'cafe-item';

class CafeItem extends StatefulWidget {
  const CafeItem({super.key});

  @override
  State<CafeItem> createState() => _CafeItemState();
}

class _CafeItemState extends State<CafeItem> {
  dynamic body = const Text('loading...');

  Future<void> getCategory() async {
    var datas = myCafe.get(
        collectionName: categoryCollectionName,
        id: null,
        fieldName: null,
        fieldValue: null);
    setState(() {
      body = FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData == true) {
            var datas = snapshot.data?.docs;
            if (datas == null) {
              return const Center(
                child: Text('empty'),
              );
            } else {
              return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = datas[index];
                    return ListTile(
                      title: Text(data['categoryName']),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          switch (value) {
                            case 'modify':
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CafeCategoryAddForm(id: data.id),
                                  ));
                              if (result == true) {
                                getCategory();
                              }
                              break;
                            case 'delete':
                              var result = await myCafe.delete(
                                  collectionName: categoryCollectionName,
                                  id: data.id);
                              if (result == true) {
                                getCategory();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'modify',
                            child: Text('수정'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: datas.length);
            }
          } else {
            return const Center(child: Text('loading...'));
          }
        },
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CafeCategoryAddForm(id: null),
              ));
          if (result == true) {
            getCategory();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CafeCategoryAddForm extends StatefulWidget {
  String? id;
  CafeCategoryAddForm({super.key, required this.id});

  @override
  State<CafeCategoryAddForm> createState() => _CafeCategoryAddFormState();
}

class _CafeCategoryAddFormState extends State<CafeCategoryAddForm> {
  TextEditingController controller = TextEditingController();
  String? id;
  var isUsed = true;

  Future<void> getData({required String id}) async {
    var data = await myCafe.get(collectionName: categoryCollectionName, id: id);
    setState(() {
      controller.text = data['categoryName'];
      isUsed = data['isUsed'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    if (id != null) {
      getData(id: id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('category add'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                var data = {
                  'categoryName': controller.text,
                  'isUsed': isUsed,
                };
                var result = id != null
                    ? await myCafe.update(
                        collectionName: categoryCollectionName,
                        id: id!,
                        data: data)
                    : await myCafe.insert(
                        collectionName: categoryCollectionName, data: data);
                if (result == true) {
                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text(
              'save',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Text('category name'),
              border: OutlineInputBorder(),
            ),
            controller: controller,
          ),
          SwitchListTile(
            title: const Text('used'),
            value: isUsed,
            onChanged: (value) {
              setState(() {
                isUsed = value;
              });
            },
          )
        ],
      ),
    );
  }
}
