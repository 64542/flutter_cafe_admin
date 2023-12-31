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
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CafeItemList(
                                id: data.id,
                              ),
                            ));
                      },
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

class CafeItemList extends StatefulWidget {
  String id;
  CafeItemList({super.key, required this.id});

  @override
  State<CafeItemList> createState() => _CafeItemListState();
}

class _CafeItemListState extends State<CafeItemList> {
  late String id;
  dynamic dropdownMenu = const Text('loading..');
  dynamic itemList = const Text('itemLIst');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    getCategory(id);
    getItemList(categoryId: id);
  }

  Future<void> getItemList({String? categoryId}) async {
    var datas = categoryId == null
        ? myCafe.get(
            collectionName: 'cafe-item',
          )
        : myCafe.get(
            collectionName: 'cafe-item',
            fieldName: 'categoryId',
            fieldValue: categoryId,
          );
    setState(() {
      itemList = FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data.docs;
            if (items.length == 0) {
              return const Text("아무런 데이터가 없습니다");
            }
            return ListView.separated(
              itemBuilder: (context, index) {
                var item = items[index];
                return ListTile(
                  title: Text('${item['itemName']} (${item['itemPrice']})'),
                  subtitle: Text('${item['options']}'),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      switch (value) {
                        case 'modify':
                          var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CafeItemAddForm(
                                    categoryId: item['categoryId'],
                                    itemId: item.id),
                              ));
                          if (result == true) {
                            setState(() {
                              getItemList(categoryId: id);
                            });
                          }
                          break;
                        case 'delete':
                          var data = await myCafe.delete(
                              collectionName: 'cafe-item', id: item.id);

                          if (data) {
                            getItemList(categoryId: id);
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "modify",
                        child: Text("수정"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: const Text("삭제"),
                        onTap: () async {
                          var data = await myCafe.delete(
                              collectionName: 'cafe-item', id: item.id);

                          if (data) {
                            getItemList(categoryId: id);
                          }
                        },
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: items.length,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    });
  }

  Future<void> getCategory(String id) async {
    var datas = myCafe.get(collectionName: categoryCollectionName);
    List<DropdownMenuEntry> entries = [];
    setState(() {
      dropdownMenu = FutureBuilder(
        future: datas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var datas = snapshot.data.docs;
            for (var data in datas) {
              entries.add(
                DropdownMenuEntry(value: data.id, label: data['categoryName']),
              );
            }
            return DropdownMenu(
              dropdownMenuEntries: entries,
              initialSelection: id,
              onSelected: (value) async {
                getItemList(categoryId: value);
              },
            );
          } else {
            return const Text('loading..');
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('item list'),
        actions: [
          TextButton(
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CafeItemAddForm(categoryId: id, itemId: id),
                  ),
                );
                if (result == true) {
                  getItemList(categoryId: id);
                }
              },
              child: const Text('+item',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
        ],
      ),
      body: Column(
        children: [
          dropdownMenu,
          Expanded(
            child: itemList,
          ),
        ],
      ),
    );
  }
}

class CafeItemAddForm extends StatefulWidget {
  String categoryId;
  String? itemId;
  CafeItemAddForm({super.key, required this.categoryId, required this.itemId});

  @override
  State<CafeItemAddForm> createState() => _CafeItemAddFormState();
}

class _CafeItemAddFormState extends State<CafeItemAddForm> {
  late String categoryId;
  String? itemId;
  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  TextEditingController controllerDesc = TextEditingController();
  TextEditingController controllerOptionName = TextEditingController();
  TextEditingController controllerOptionValue = TextEditingController();
  bool isSoldOut = false;
  var options = [];
  dynamic optionView = const Text('옵션이 없습니다.');

  void showOptionList() {
    setState(() {
      optionView = ListView.separated(
        itemBuilder: (context, index) {
          var title = options[index]['optionName'];
          var subTitle =
              options[index]['optionValue'].toString().replaceAll('\n', '/');

          return ListTile(
            title: Text(title),
            subtitle: Text(subTitle),
            trailing: IconButton(
                onPressed: () {
                  options.removeAt(index);
                  showOptionList();
                },
                icon: const Icon(Icons.close)),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: options.length,
      );
    });
    controllerOptionName.clear();
    controllerOptionValue.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryId = widget.categoryId;
    itemId = widget.itemId;

    if (itemId != null) {
      getItemById(itemId);
    }
  }

  void getItemById(itemId) async {
    var data = await myCafe.get(collectionName: itemCollectionName, id: itemId);

    controllerTitle.text = data['itemName'];
    controllerPrice.text = data['itemPrice'].toString();
    controllerDesc.text = data['itemDesc'];
    isSoldOut = data['itemIsSoldOut'];

    if (data['options'].length != 0) {
      for (var o in data['options']) {
        options.add(
            {'optionName': o['optionName'], 'optionValue': o['optionValue']});
      }

      setState(() {
        showOptionList();
      });
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('item add form'),
        actions: [
          TextButton(
            onPressed: () async {
              var data = {
                'itemName': controllerTitle.text,
                'itemPrice': int.parse(controllerPrice.text),
                'itemDesc': controllerDesc.text,
                'itemIsSoldOut': isSoldOut,
                'categoryId': categoryId,
                'options': options,
              };

              var result = itemId != null
                  ? await myCafe.update(
                      collectionName: itemCollectionName,
                      id: itemId!,
                      data: data,
                    )
                  : await myCafe.insert(
                      collectionName: itemCollectionName, data: data);

              // var result1 = await myCafe.insert(
              //     collectionName: itemCollectionName, data: data);

              if (result) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(label: Text('이름')),
            controller: controllerTitle,
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text('가격')),
            controller: controllerPrice,
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: const InputDecoration(label: Text('설명')),
            controller: controllerDesc,
          ),
          SwitchListTile(
            value: isSoldOut,
            onChanged: (value) {
              setState(() {
                isSoldOut = value;
              });
            },
            title: const Text('sold out?'),
          ),
          Expanded(child: optionView),
          IconButton(
              onPressed: () {
                var optionName = controllerOptionName.text;
                var optionValue = controllerOptionValue.text;
                if (optionName != '' && optionValue != '') {
                  var data = {
                    'optionName': optionName,
                    'optionValue': optionValue
                  };
                  options.add(data);
                  showOptionList();
                }
              },
              icon: const Icon(Icons.arrow_circle_up)),
          TextFormField(
            controller: controllerOptionName,
          ),
          TextFormField(
            controller: controllerOptionValue,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
