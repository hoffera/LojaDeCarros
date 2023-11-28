import 'package:bd2/Models/Carro.dart';
import 'package:bd2/Models/marca.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenCarro extends StatefulWidget {
  const ScreenCarro({super.key});

  @override
  State<ScreenCarro> createState() => _ScreenCarroState();
}

class _ScreenCarroState extends State<ScreenCarro> {
  List<Carro> listCarros = [];
  List<Marca> listModelos = [];
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
                  print(searchText);
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
      body: (listCarros.isEmpty)
          ? const SizedBox(
              height: 10,
            )
          : ListView(
              children: List.generate(
                listCarros.length,
                (index) {
                  Carro model = listCarros[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      delete(model);
                    },
                    background: Container(
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        )),
                    direction: DismissDirection.endToStart,
                    key: ValueKey<Carro>(model),
                    child: ListTile(
                      onLongPress: () => showFormModal(model: model),
                      leading: const Icon(Icons.child_friendly_sharp),
                      title: Text("Nome: ${model.nome}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Lato',
                          )),
                      subtitle: Text(
                          "Id: ${model.id}\nRenavam: ${model.renavam}\nId_Modelo: ${model.id_modelo}\nPlaca: ${model.placa}\nValor: ${model.valor}\nAno: ${model.ano}",
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

  showFormModal({Carro? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Carro";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";
    String dropdownText = "Seleciona o modelo";

    // Controlador do campo que receberá o nome do Carro
    TextEditingController nameController = TextEditingController();
    TextEditingController namePlaca = TextEditingController();
    final TextEditingController nameRenavam = TextEditingController();
    final TextEditingController nameValor = TextEditingController();
    DateTime nameAno = DateTime.now();

    if (model != null) {
      labelTitle = "Editando";
      nameController.text = model.nome;
      namePlaca.text = model.placa;
      nameRenavam.text = model.renavam.toString();
      nameValor.text = model.valor.toString();
      dropdownText = model.id_modelo.toString();
      nameAno = model.ano;
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
                decoration: const InputDecoration(label: Text("Nome")),
              ),
              TextFormField(
                controller: nameRenavam,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Renavam',
                ),
              ),
              TextFormField(
                controller: namePlaca,
                decoration: const InputDecoration(label: Text("Placa")),
              ),
              TextFormField(
                controller: nameValor,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor',
                ),
              ),
              DropdownButton<int>(
                hint: Text(
                    dropdownText), // Usar a variável para exibir o texto do botão
                value: dropdownValue,
                onChanged: (int? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    dropdownText = listModelos
                        .firstWhere((modelo) => modelo.id == newValue)
                        .nome; // Atualizar o texto do botão com o nome da marca selecionada
                  });
                },
                items: listModelos.map<DropdownMenuItem<int>>((Marca marca) {
                  return DropdownMenuItem<int>(
                    value: marca.id,
                    child: Text(marca.id.toString()),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 50,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: nameAno,
                  onDateTimeChanged: (novaDataEntrega) {
                    setState(() {
                      nameAno = novaDataEntrega;
                    });
                  },
                ),
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
                      String value = nameRenavam.text;
                      String valueValor = nameValor.text;
                      double? valor = double.tryParse(valueValor);
                      int? renavamInt = int.tryParse(value);
                      if (renavamInt != null && valor != null) {
                        Carro modelo = Carro(
                          id: UniqueKey().hashCode,
                          id_modelo: dropdownValue!,
                          nome: nameController.text,
                          ano: nameAno,
                          placa: namePlaca.text,
                          renavam: renavamInt,
                          valor: valor,
                        );
                        if (model != null) {
                          modelo.id = model.id;
                          edit(modelo);
                        } else {
                          add(modelo);
                        }
                      }
                      // Criar um objeto Carro com as infos

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
    List<Carro> temp = [];
    List<Marca> tempM = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("Carro").get();

    for (var doc in snapshot.docs) {
      temp.add(Carro.fromMap(doc.data()));
    }

    QuerySnapshot<Map<String, dynamic>> snapshotM =
        await firestore.collection("Modelo").get();

    for (var doc in snapshotM.docs) {
      tempM.add(Marca.fromMap(doc.data()));
    }

    setState(() {
      listCarros = temp;
      listModelos = tempM;
    });
  }

  void delete(Carro model) {
    firestore.collection('Carro').doc(model.id.toString()).delete();
    refresh();
  }

  void add(Carro model) {
    firestore.collection("Carro").doc(model.id.toString()).set(model.toMap());
    refresh();
  }

  void edit(Carro model) {
    firestore
        .collection("Carro")
        .doc(model.id.toString())
        .update(model.toMap());

    refresh();
  }

  Future<void> getByID(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('Carro').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        Carro modelo = Carro(
          id: data['id'],
          nome: data['nome'],
          ano: (data['ano'] as Timestamp).toDate(),
          id_modelo: data['id_modelo'],
          placa: data['placa'],
          renavam: data['renavam'],
          valor: data['valor'],
        );
        print("erro");
        showFormModal(model: modelo);
      }
    } catch (e) {
      print('Erro ao buscar documento: $e');
    }
  }
}
