import 'package:flutter/material.dart';

class DetailTaskWidget extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Function onTap;
  DetailTaskWidget({this.icon, this.iconColor, this.text, this.onTap});

  @override
  _DetailTaskWidgetState createState() => _DetailTaskWidgetState();
}

class _DetailTaskWidgetState extends State<DetailTaskWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null ? null : widget.onTap,
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
              child: Icon(widget.icon, color: widget.iconColor),
            )),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            widget.text,
            style: TextStyle(
                decoration: TextDecoration.none,
                fontStyle: FontStyle.normal,
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: (widget.text == "") ? Colors.black54 : Colors.black),
          )
        ],
      ),
    );
  }
}
