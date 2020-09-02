import 'dart:math';

import 'package:chips_choice/chips_choice.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dough/dough.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:intl/intl.dart';

import '../../core/bloc/database_bloc/database_bloc.dart';
import '../../core/model/category_model.dart';
import '../../core/model/reorder_list_model.dart';
import '../../core/model/task_model.dart';
import '../../core/util/local_notification_helper.dart';
import '../widget/custom_button.dart';
import '../widget/custom_textfield.dart';
import '../widget/date_picker.dart';
import '../widget/reorderable_item.dart';
import '../widget/textfield_dialog.dart';
import '../widget/time_picker.dart';
import 'detail_screen.dart';
import 'menu_dashboard_screen.dart';

class AddTask extends StatefulWidget {
  final bool isNew;
  final Function function;
  final Function onMenuTap;
  final Tasks task;
  final bool fromHome;
  final bool fromTaskPage;
  AddTask(
      {@required this.isNew,
      @required this.function,
      @required this.fromHome,
      @required this.fromTaskPage,
      this.task,
      this.onMenuTap});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  //
  // PAGE UTIL
  //
  bool _showButton;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //
  // VARIABLE FOR SAVING TASKS
  //
  DateTime _selectedDate;
  TimeOfDay _startTime, _endTime;
  int _tag = 0;
  List<String> _participants = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _placeController = TextEditingController();
  TextEditingController _participantsController = TextEditingController();
  FocusNode _titleFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _placeFocusNode = FocusNode();
  FocusNode _participantsFocusNode = FocusNode();
  Category _category = Category();
  List<ItemData> _reoderableItems = List();
  List<TextEditingController> textControllerList = [];
  List<FocusNode> focusNodeList = [];

  //
  // INIT STATE
  @protected
  void initState() {
    super.initState();
    _descriptionController.text = "";
    assignData();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (visible == true) {
        if (mounted) {
          setState(() {
            _showButton = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _showButton = true;
          });
          FocusScope.of(context).unfocus();
        }
      }
    });
  }

  //
  // DISPOSE
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    _participantsController.dispose();
    for (var item in textControllerList) {
      item.dispose();
    }
    super.dispose();
  }

  //
  // PAGE FUNCTION

  Tasks _saveTasks() {
    var rand = Random();

    return Tasks(
        taskId: widget.isNew == true
            ? "$_selectedDate${_startTime.format(context)}${_endTime.format(context)}$_tag${rand.nextInt(100)}"
            : widget.task.taskId,
        taskName: _titleController.text,
        description: _descriptionController.text,
        place: _placeController.text,
        category: _tag,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        participants: _participants,
        subtask: getSubtask(_reoderableItems),
        isDone: widget.isNew == true ? false : widget.task.isDone,
        pinned: widget.isNew == true ? false : widget.task.pinned);
  }

  void addTime(TimeOfDay start, TimeOfDay end) {
    setState(() {
      _startTime = start;
      _endTime = end;
    });
  }

  void addDescription(String description) {
    setState(() {
      _descriptionController.text = description;
    });
  }

  void assignData() {
    if (widget.task != null) {
      _titleController.text = widget.task.taskName;
      _descriptionController.text = widget.task.description;
      _participants = widget.task.participants;
      _placeController.text = widget.task.place;
      _selectedDate = widget.task.date;
      _startTime = widget.task.startTime;
      _endTime = widget.task.endTime;
      _reoderableItems = subtaskToItemData(widget.task.subtask);
    } else
      return;
  }

  _navigator() {
    if (widget.fromHome == true) {
      Navigator.pop(context);
    } else if (widget.fromTaskPage == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MenuDashboard(currentIndexPage: 1)));
    } else {
      Navigator.pop(context);
    }
    if (widget.function != null) widget.function.call();
  }

  _bottomButtonFunction() {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _titleController.text == "") {
      _scaffoldKey.currentState.showSnackBar(validationSnackBar());
    } else {
      if (widget.isNew == true) {
        BlocProvider.of<DatabaseBloc>(context)
            .add(CreateTask(tasks: _saveTasks()));

        notificationPlugin.scheduleNotification(
            DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day,
                _startTime.hour, _startTime.minute),
            _saveTasks());

        if (widget.function != null) widget.function.call();
        Navigator.pop(context);
      } else {
        BlocProvider.of<DatabaseBloc>(context)
            .add(UpdateTask(tasks: _saveTasks()));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DetailTask(
                      tasks: widget.task,
                      fromNotification: false,
                      function: null,
                      fromEditor: true,
                    )));
      }
    }
  }

  List<ItemData> subtaskToItemData(List<Subtask> subtask) {
    List<ItemData> reoderableItems = List();

    for (var i = 0; i < subtask.length; i++) {
      setState(() {
        reoderableItems.add(ItemData(subtask[i], ValueKey(i)));
      });
    }

    return reoderableItems;
  }

  List<Subtask> getSubtask(List<ItemData> reoderableItems) {
    List<Subtask> subtaskList = List();
    for (var item in reoderableItems) {
      subtaskList.add(item.subtask);
    }
    return subtaskList;
  }

  //
  // CALLBACK FUNCTION
  void deleteSubtask(Key key) {
    int index = _indexOfKey(key);
    setState(() {
      _reoderableItems.removeAt(index);
      textControllerList.removeAt(index);
      focusNodeList.removeAt(index);
    });
  }

  int _indexOfKey(Key key) {
    return _reoderableItems.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _reoderableItems[draggingIndex];
    final controller = textControllerList[draggingIndex];
    final focusNode = focusNodeList[draggingIndex];

    setState(() {
      _reoderableItems.removeAt(draggingIndex);
      _reoderableItems.insert(newPositionIndex, draggedItem);
      textControllerList.removeAt(draggingIndex);
      textControllerList.insert(newPositionIndex, controller);
      focusNodeList.removeAt(draggingIndex);
      focusNodeList.insert(newPositionIndex, focusNode);
    });
    return true;
  }

  //
  // PAGE BUILDER

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigator();
        return true;
      },
      child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _navigator();
                }),
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
          body: ReorderableList(
            onReorder: this._reorderCallback,
            child: Stack(
              children: [body(), createTaskButton()],
            ),
          )),
    );
  }

  Widget body() {
    return GestureDetector(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              title(),
              SizedBox(height: ScreenUtil().setHeight(80)),
              taskTitleTextfield(),
              SizedBox(height: ScreenUtil().setHeight(60)),
              datePicker(),
              SizedBox(height: ScreenUtil().setHeight(30)),
              timePicker(),
              SizedBox(height: ScreenUtil().setHeight(30)),
              locationTextfield(),
              SizedBox(height: ScreenUtil().setHeight(60)),
              Text(
                'Description',
                style: TextStyle(fontSize: 15.0, fontFamily: 'Roboto-Bold'),
              ),
              SizedBox(height: ScreenUtil().setHeight(30)),
              _descriptionController.text == ""
                  ? addDescriptionButton()
                  : descriptionTextfield(),
              SizedBox(height: ScreenUtil().setHeight(60)),
              Text(
                'Participants',
                style: TextStyle(fontSize: 15.0, fontFamily: 'Roboto-Bold'),
              ),
              participantTextfield(),
              SizedBox(height: ScreenUtil().setHeight(15)),
              chipsTags(),
              SizedBox(height: ScreenUtil().setHeight(60)),
              Text(
                'Category',
                style: TextStyle(fontSize: 15.0, fontFamily: 'Roboto-Bold'),
              ),
              chipsCategory(),
              SizedBox(height: ScreenUtil().setHeight(60)),
              Text(
                'SubTask',
                style: TextStyle(fontSize: 15.0, fontFamily: 'Roboto-Bold'),
              ),
              listSubtask(),
              SizedBox(height: ScreenUtil().setHeight(300)),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(widget.isNew == true ? 'Create \nNew Tasks' : 'Edit Tasks',
        style: TextStyle(
            color: Colors.black, fontFamily: 'Roboto-Bold', fontSize: 25.0));
  }

  Widget taskTitleTextfield() {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(150),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
          child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontFamily: 'Roboto-Medium', fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Tasks title',
                hintStyle: TextStyle(fontFamily: 'Roboto-Medium', fontSize: 18),
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 10, top: 10, right: 15),
              )),
        ),
      ),
    );
  }

  Widget datePicker() {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        var date = await selectDate(context);
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.date_range, color: Colors.orangeAccent),
            )),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            (_selectedDate != null)
                ? DateFormat('EEEE dd, MMMM yyyy').format(_selectedDate)
                : 'Pick Date',
            style: TextStyle(
                fontSize: 14.0,
                color: (_selectedDate != null) ? Colors.black : Colors.black54),
          )
        ],
      ),
    );
  }

  Widget timePicker() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        showDialog(
            context: context,
            builder: (BuildContext context) => TimePicker(
                  function: addTime,
                  startTime: null,
                  endTime: null,
                ));
      },
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.access_time, color: Colors.pinkAccent),
            )),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            _startTime != null
                ? '${_startTime.format(context)} - ${_endTime != null ? _endTime.format(context) : ""}'
                : 'Pick Time',
            style: TextStyle(
                fontSize: 14.0,
                color: (_startTime != null) ? Colors.black : Colors.black54),
          )
        ],
      ),
    );
  }

  Widget locationTextfield() {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.place, color: Colors.blueAccent),
          )),
        ),
        SizedBox(
          width: 20,
        ),
        Flexible(
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                    controller: _placeController,
                    focusNode: _placeFocusNode,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Colors.black,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    style: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
                    decoration: InputDecoration(
                      hintText: 'Insert Location',
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        bottom: 12,
                      ),
                    ))),
          ),
        ),
      ],
    );
  }

  Widget descriptionTextfield() {
    return TextField(
      maxLines: null,
      controller: _descriptionController,
      focusNode: _descriptionFocusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget addDescriptionButton() {
    return InkWell(
      onTap: () => showDialog(
          context: context,
          builder: (context) => TextfieldDialog(function: addDescription)),
      child: DottedBorder(
          strokeCap: StrokeCap.round,
          padding: EdgeInsets.all(6),
          radius: Radius.circular(ScreenUtil().setWidth(40)),
          dashPattern: [8, 4],
          color: Colors.grey,
          strokeWidth: 1.5,
          child: Container(
            height: ScreenUtil().setHeight(100),
            width: double.infinity,
            child: Center(
                child: Text(
              "Add Description",
              style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Roboto-Medium',
                  fontSize: 14),
            )),
          )),
    );
  }

  Widget participantTextfield() {
    return CustomTextfield(
      textEditingController: _participantsController,
      focusNode: _participantsFocusNode,
      hintText: 'Insert Participants',
      icon: Icons.add,
      onTap: () => setState(() {
        _participants.add(_participantsController.text);
        _participantsController.clear();
        FocusScope.of(context).unfocus();
      }),
    );
  }

  Widget chipsTags() {
    return Tags(
      itemCount: _participants.length,
      itemBuilder: (index) {
        return ItemTags(
          key: Key(index.toString()),
          index: index,
          title: _participants[index],
          active: true,
          combine: ItemTagsCombine.withTextBefore,
          color: Theme.of(context).primaryColor,
          activeColor: Theme.of(context).primaryColor,
          textActiveColor: Colors.black,
          removeButton: ItemTagsRemoveButton(
            backgroundColor: Colors.white,
            color: Colors.black,
            onRemoved: () {
              setState(() {
                _participants.removeAt(index);
              });
              return true;
            },
          ),
        );
      },
    );
  }

  Widget chipsCategory() {
    return ChipsChoice<int>.single(
      padding: EdgeInsets.all(0.0),
      value: widget.task != null ? widget.task.category : _tag,
      options: ChipsChoiceOption.listFrom<int, String>(
        source: _category.category,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
      onChanged: (val) {
        FocusScope.of(context).unfocus();
        setState(() => _tag = val);
      },
      isWrapped: true,
      itemConfig: const ChipsChoiceItemConfig(
          selectedColor: Color(0xFFfabb18),
          selectedBrightness: Brightness.dark,
          labelStyle: TextStyle(fontSize: 13)),
    );
  }

  Widget listSubtask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
            padding: EdgeInsets.all(0.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _reoderableItems.length,
            itemBuilder: (context, index) {
              textControllerList.add(TextEditingController());
              focusNodeList.add(FocusNode());

              return ReoderableItem(
                data: _reoderableItems[index],
                controller: textControllerList[index],
                focusNode: focusNodeList[index],
                isFirst: index == 0,
                isLast: index == _reoderableItems.length - 1,
                draggingMode: DraggingMode.iOS,
                deleteCallback: deleteSubtask,
              );
            }),
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        DoughRecipe(
          data: DoughRecipeData(
            viscosity: 3000,
            expansion: 1.025,
          ),
          child: PressableDough(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _reoderableItems.add(ItemData(
                      Subtask(subtaskName: "", isDone: false),
                      ValueKey(_reoderableItems == null
                          ? 1
                          : _reoderableItems.length + 1)));
                });
              },
              child: Container(
                height: ScreenUtil().setWidth(100),
                width: ScreenUtil().setWidth(100),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(15)))),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget createTaskButton() {
    return Visibility(
      visible: _showButton != null ? _showButton : true,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingBottomButton(
              buttonFunction: _bottomButtonFunction,
              title: widget.isNew == true ? "CREATE TASKS" : "UPDATE TASKS")),
    );
  }

  Widget validationSnackBar() {
    return SnackBar(
      content: Text(_titleController.text != ""
          ? "Please select date & time"
          : "Title can't be null"),
      action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          }),
    );
  }
}
