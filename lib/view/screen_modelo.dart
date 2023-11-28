import 'package:bd2/Models/marca.dart';
import 'package:bd2/Models/modelo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScreenModelo extends StatefulWidget {
  const ScreenModelo({super.key});

  @override
  State<ScreenModelo> createState() => _ScreenModeloState();
}

class _ScreenModeloState extends State<ScreenModelo> {
  List<Modelo> listModelos = [];
  List<Marca> listMarcas = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textEditingController = TextEditingController();
  int? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por id',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Aqui você pode adicionar lógica para lidar com a mudança de texto
                    print('Texto alterado: $value');
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  String searchText = _textEditingController.text;
                  getByID(searchText);
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listModelos.isEmpty)
          ? const SizedBox(
              height: 10,
            )
          : ListView(
              children: List.generate(
                listModelos.length,
                (index) {
                  Modelo model = listModelos[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      delete(model);
                    },
                    background: Container(
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        )),
                    direction: DismissDirection.endToStart,
                    key: ValueKey<Modelo>(model),
                    child: ListTile(
                      onLongPress: () => showFormModal(model: model),
                      leading: const Icon(Icons.child_care_sharp),
                      title: Text("Nome: ${model.nome}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Lato',
                          )),
                      subtitle: Text(
                          "ID: ${model.id.toString()}\nId_Marca: ${model.id_marca.toString()}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontFamily: 'Lato',
                          )),
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  showFormModal({Modelo? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Modelo";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";
    String dropdownText = 'Selecione uma marca';

    // Controlador do campo que receberá o nome do Modelo
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      labelTitle = "Editando";
      nameController.text = model.nome;
      dropdownText = model.id_marca.toString();
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              if (model != null)
                Text("$labelTitle ID: ${model.id.toString()}",
                    style: Theme.of(context).textTheme.headlineSmall)
              else
                Text(labelTitle,
                    style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Modelo")),
              ),
              DropdownButton<int>(
                hint: Text(
                    dropdownText), // Usar a variável para exibir o texto do botão
                value: dropdownValue,
                onChanged: (int? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    dropdownText = listMarcas
                        .firstWhere((marca) => marca.id == newValue)
                        .id
                        .toString(); // Atualizar o texto do botão com o nome da marca selecionada
                  });
                },
                items: listMarcas.map<DropdownMenuItem<int>>((Marca marca) {
                  return DropdownMenuItem<int>(
                    value: marca.id,
                    child: Text(marca.id.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Modelo com as infos
                      Modelo modelo = Modelo(
                        id: UniqueKey().hashCode,
                        id_marca: dropdownValue!,
                        nome: nameController.text,
                      );

                      if (model != null) {
                        modelo.id = model.id;
                        edit(modelo);
                      } else {
                        add(modelo);
                      }

                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Modelo> temp = [];
    List<Marca> tempM = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("Modelo").get();

    for (var doc in snapshot.docs) {
      temp.add(Modelo.fromMap(doc.data()));
    }

    QuerySnapshot<Map<String, dynamic>> snapshotM =
        await firestore.collection("Marca").get();

    for (var doc in snapshotM.docs) {
      tempM.add(Marca.fromMap(doc.data()));
    }

    setState(() {
      listModelos = temp;
      listMarcas = tempM;
    });
  }

  void delete(Modelo model) {
    firestore.collection('Modelo').doc(model.id.toString()).delete();
    refresh();
  }

  void add(Modelo model) {
    firestore.collection("Modelo").doc(model.id.toString()).set(model.toMap());
    refresh();
  }

  void edit(Modelo model) {
    firestore
        .collection("Modelo")
        .doc(model.id.toString())
        .update(model.toMap());

    refresh();
  }

  Future<void> getByID(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('Modelo').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        Modelo modelo = Modelo(
          id: data['id'],
          nome: data['nome'],
          id_marca: data['id_marca'],
        );
        showFormModal(model: modelo);
      }
    } catch (e) {
      print('Erro ao buscar documento: $e');
    }
  }
}
