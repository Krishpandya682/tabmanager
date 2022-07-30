import 'package:flutter/material.dart';
import 'package:tabmanager/json_deserialization/link.dart';
import 'package:tabmanager/widgets/button_style.dart';
import 'package:tabmanager/widgets/popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:tabmanager/main.dart';

class MoveableStackItem extends StatefulWidget {
  List<Link>? content;
  String category;
  double xPosition;
  double yPosition;
  final Function notifyParent;
  final Function notifyParentFull;
  ScrollController controller = ScrollController();
  MoveableStackItem(this.content, this.category, this.xPosition, this.yPosition,
      this.notifyParent, this.notifyParentFull,
      {Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MoveableStackItemState();
  }
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  _MoveableStackItemState();
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> removeLink(Link link) async {
    String url = "http://localhost:3000/links/${link.id}";
    var response = await http.delete(Uri.parse(url), body: link.toJson());
    widget.notifyParent();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.yPosition,
      left: widget.xPosition,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 117, 117),
                Color.fromARGB(255, 144, 99, 248),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Center(
                  child: Text(
                widget.category,
                style: const TextStyle(fontSize: 30),
              )),
              SizedBox(height: 8),
              SizedBox(
                height: 300,
                width: 300,
                child: ListView.builder(
                    controller: widget.controller,
                    itemCount: widget.content!.length,
                    itemBuilder: (context, i) {
                      return Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                                title: Center(
                                    child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 25,
                                  width: 100,
                                  child: Text(
                                    "${widget.content![i].title}",
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                  width: 100,
                                  child: Text(
                                    "${widget.content![i].link}",
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ))),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        _launchURL(
                                            "${widget.content![i].link}");
                                      },
                                      style: buttonStyle,
                                      child: const Text("Open")),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                      onPressed: () async {
                                        await removeLink(widget.content![i]);
                                        if (widget.content!.length == 1) {
                                          widget.notifyParentFull(
                                              widget.category);
                                        } else {
                                          widget.notifyParent();
                                        }
                                        await removeLink(widget.content![i]);
                                        if (widget.content!.length == 1) {
                                          widget.notifyParentFull(
                                              widget.category);
                                        } else {
                                          widget.notifyParent();
                                        }
                                      },
                                      style: dangerButtonStyle,
                                      child: const Text("Delete")),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                  style: buttonStyle,
                  onPressed: () async {
                    await showDialog(
                      // Flutter method for showing popups
                      context: context,
                      builder: (context) =>
                          NewLinkPopupCategory(widget.category),
                    );
                    widget.notifyParent();
                  },
                  child: const Text("Add")),
            ],
          ),
        ),
      ),
    );
  }
}
