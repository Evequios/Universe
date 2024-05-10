import 'package:flutter/material.dart';
import 'package:wwe_universe/classes/News.dart';
import 'package:wwe_universe/database.dart';
import 'package:wwe_universe/widget/NewsFormWidget.dart';

class AddEditNewsPage extends StatefulWidget {
  final News? news;

  const AddEditNewsPage({
    Key? key,
    this.news,
  }) : super(key: key);
  @override
  _AddEditNewsPage createState() => _AddEditNewsPage();
}

class _AddEditNewsPage extends State<AddEditNewsPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String text;
  late String type;

  @override
  void initState() {
    super.initState();

    title = widget.news?.title ?? '';
    text = widget.news?.text ?? '';
    type = widget.news?.type ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: NewsFormWidget(
        title: title,
        text: text,
        type: type,
        onChangedTitle: (title) => setState(() => this.title = title),
        onChangedText: (text) => setState(() => this.text = text),
        onChangedType: (type) => setState(() => this.type = type!),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, 
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateUniverseNews,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateUniverseNews() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.news != null;

      if (isUpdating) {
        await updateUniverseNews();
      } else {
        await addUniverseNews();
      }

      if(context.mounted) Navigator.of(context).pop();
    }
  }

  Future updateUniverseNews() async {
    final news = widget.news!.copy(
      title: title,
      text: text,
      type: type != '' ? type : "Annonce",
    );

    await DatabaseService.instance.updateNews(news);
  }

  Future addUniverseNews() async {
    final news = News(
      title: title,
      text: text,
      createdTime: DateTime.now(),
      type: type != '' ? type : "Annonce" 
    );

    await DatabaseService.instance.createNews(news);
  }
}