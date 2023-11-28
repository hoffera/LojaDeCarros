import 'package:bd2/Models/marca.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Marca> listMarcas = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textEditingController = TextEditingController();

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
      body: (listMarcas.isEmpty)
          ? const SizedBox(
              height: 10,
            )
          : ListView(
              children: List.generate(
                listMarcas.length,
                (index) {
                  Marca model = listMarcas[index];
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
                    key: ValueKey<Marca>(model),
                    child: ListTile(
                      onLongPress: () => showFormModal(model: model),
                      leading: const Icon(Icons.cruelty_free_sharp),
                      title: Text("Nome: ${model.nome}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Lato',
                          )),
                      subtitle: Text("Id: ${model.id.toString()}",
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

  showFormModal({Marca? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Marca";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Marca
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      labelTitle = "Editando";
      nameController.text = model.nome;
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
                decoration: const InputDecoration(label: Text("Nome do Marca")),
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
                      // Criar um objeto Marca com as infos
                      Marca marca = Marca(
                        id: UniqueKey().hashCode,
                        nome: nameController.text,
                      );

                      if (model != null) {
                        marca.id = model.id;
                        edit(marca);
                      } else {
                        add(marca);
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
    List<Marca> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("Marca").get();

    for (var doc in snapshot.docs) {
      temp.add(Marca.fromMap(doc.data()));
    }

    setState(() {
      listMarcas = temp;
    });
  }

  Future<void> deleteModelosAndCarrosWithMarcaId(int idMarca) async {
    try {
      CollectionReference modelosRef =
          FirebaseFirestore.instance.collection('Modelo');

      QuerySnapshot modelosSnapshot =
          await modelosRef.where('id_marca', isEqualTo: idMarca).get();

      for (DocumentSnapshot modeloDoc in modelosSnapshot.docs) {
        String idModelo = modeloDoc.id;
        carros(idModelo);

        await modelosRef.doc(idModelo).delete();
      }

      print('Modelos  relacionados à marca deletados com sucesso!');
    } catch (e) {
      print('Erro ao deletar modelos e carros relacionados à marca: $e');
    }
  }

  Future<void> carros(String idModelo) async {
    try {
      CollectionReference carrosRef =
          FirebaseFirestore.instance.collection('Carro');

      DocumentSnapshot carroSnapshot = await carrosRef
          .doc('471659813')
          .get(); // Substitua '471659813' pelo ID do carro específico que não está sendo excluído

      if (carroSnapshot.exists) {
        print('Documento de carro encontrado para o modelo $idModelo');
        // Prossiga com a exclusão do documento
        await carrosRef.doc(carroSnapshot.id).delete();
        print('Carro excluído com sucesso!');
      } else {
        print('Nenhum documento de carro encontrado para o modelo $idModelo');
      }
    } catch (e) {
      print('Erro ao deletar carro relacionado ao modelo: $e');
      rethrow;
    }
  }

  void delete(Marca model) {
    deleteModelosAndCarrosWithMarcaId(model.id);
    firestore.collection('Marca').doc(model.id.toString()).delete();
    refresh();
  }

  void add(Marca model) {
    firestore.collection("Marca").doc(model.id.toString()).set(model.toMap());
    refresh();
  }

  void edit(Marca model) {
    firestore
        .collection("Marca")
        .doc(model.id.toString())
        .update(model.toMap());

    refresh();
  }

  Future<void> getByID(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('Marca').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        Marca marca = Marca(
          id: data['id'],
          nome: data['nome'],
        );
        showFormModal(model: marca);
      }
    } catch (e) {
      print('Erro ao buscar documento: $e');
    }
  }
}
