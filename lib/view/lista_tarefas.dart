import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:organizer/controller/form_disciplina.dart';
import 'package:organizer/view/lista_disciplinas.dart';
import './view_disciplina.dart';
import 'package:organizer/model/obj_disciplina.dart';
import 'package:organizer/model/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:organizer/controller/form_tarefa.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:organizer/model/obj_tarefa.dart';
import 'package:organizer/model/obj_tarefa.dart';
import 'package:organizer/view/view_tarefa.dart';

class ListaTarefas extends StatefulWidget {
  List<Tarefa> listaTarefa;
  List<Disciplina> listaDisciplina;

  ListaTarefas({this.listaTarefa});

  @override
  State createState() => new _ListaTarefas(this.listaTarefa);
}

class _ListaTarefas extends State<ListaTarefas> {
  int count = 0;

  List<Tarefa> listaTarefa;

  DatabaseHelper databaseHelper = DatabaseHelper();

  _ListaTarefas(this.listaTarefa);

  @override
  Widget build(BuildContext context) {
    if (listaTarefa == null)
      listaTarefa = List<Tarefa>();
    else {
      atualizarListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas"),
        backgroundColor: Colors.purple[300],
        actions: <Widget>[
          FlatButton(
              child: Icon(Icons.book),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ListaDisciplinas(
                      listaDisciplina: widget.listaDisciplina);
                }));
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return FormTarefa.add(listaTarefa: listaTarefa, acao: "a");
          }));
          if (result == true) atualizarListView();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green[400],
        tooltip: "Adicionar Tarefa",
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            txtListaVazia(listaTarefa.length),
            Container(  
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              margin: EdgeInsets.only(top:5.0, bottom:5.0),
              decoration: BoxDecoration(  
              color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text("Maio 2019", 
              style: TextStyle(  
              fontSize: 16.0
              ),
              )
            ),
            carregarLista()
          ],
        ),
      ),
    );
  }

  Container txtListaVazia(int tam) {
    if (tam == 0) {
      return Container(
        padding: EdgeInsets.only(top: 260.0),
        alignment: Alignment.center,
        child: Text(
          "Não há tarefas cadastradas!",
          style: TextStyle(color: Colors.grey[600], fontSize: 18.0),
        ),
      );
    } else {
      return Container();
    }
  }

  //getTarefaListView
  Expanded carregarLista() {
    return Expanded(
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int index) {
          return Container(
           
              child: Card(
                child: ListTile(
                  leading: iconePrioridade(listaTarefa[index].getPrioridade()),
                  title: Text(listaTarefa[index].getTipo()),
                  subtitle: Text(listaTarefa[index].getDisciplina()),
                  trailing: Text(
                    dataFormatada(listaTarefa[index]),
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[600]),
                  ),
                  onTap: () async {
                    bool result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ViewTarefa(tarefa: listaTarefa[index]);
                    }));
                    if (result == true) atualizarListView();
                  },
                ),
            ),
          );
        },
      ),
    );
  }

  // trailing: Text(
  //                   listaTarefa[index].getNota().toString() +
  //                       "/" +
  //                       listaTarefa[index].getValor().toString(),
  //                   style: TextStyle(
  //                       fontSize: 15.0,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.blueGrey[600]),
  //                 ),

  Visibility disableTxtVazia(Container cont) {
    return Visibility(
      child: cont,
      visible: false,
    );
  }

  void atualizarListView() {
    final Future<Database> dbFuture = databaseHelper.iniciarDb();
    dbFuture.then((database) {
      Future<List<Tarefa>> tarefaListFuture = databaseHelper.getTarefaLista();
      tarefaListFuture.then((listaTarefa) {
        setState(() {
          this.listaTarefa = listaTarefa;
          this.count = listaTarefa.length;
        });
      });
    });
  }

  Icon iconePrioridade(int prioridade) {
    if (prioridade == 1)
      return Icon(Icons.error, color: Colors.blue[400], size: 45.0);
    else if (prioridade == 2)
      return Icon(Icons.error, color: Colors.amberAccent, size: 45.0);
    else if (prioridade == 3)
      return Icon(Icons.error, color: Colors.red[400], size: 45.0);

    return Icon(Icons.warning, size: 40.0);
  }

  String dataFormatada(Tarefa tarefa) {
    DateTime data = DateTime.fromMillisecondsSinceEpoch(tarefa.getData());
    String dataFormatada = ("${data.day}/${data.month}/${data.year}");
    return dataFormatada;
  }
}
