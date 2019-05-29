import 'package:flutter_web/material.dart';
import 'dart:html' as html;
import 'package:timeago/timeago.dart' as timeago;
import 'item.dart';
import 'comment_page.dart';

class ItemRow extends StatelessWidget {
  final Item item;
  ItemRow({Key key, this.item}) : super(key: key);

  void launchURL(String url) async {
    html.window.open(url, '');
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime.fromMillisecondsSinceEpoch(item.time * 1000);
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Text(
                    item.title,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 17.0),
                  ),
                )),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CommentPage(item: item)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.comment,
                          color: const Color(0xFFFF6600),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            "${item.descendants != null ? item.descendants : 0}",
                            style: TextStyle(
                                color: const Color(0xFFFF6600),
                                fontWeight: FontWeight.w700,
                                fontSize: 18.0),
                          ),
                        )
                      ],
                    ))
              ],
            )),
            Container(
              padding: EdgeInsets.only(top: 6.0),
              child: Text(
                "${item.by != null ? item.by : 'unknown'} - ${timeago.format(date)}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 4.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          child: Text(
                        item.url != null ? item.url : "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0,
                        ),
                      )),
                    ),
                    Container(
                        child: Text(
                      "${item.score}",
                      style: TextStyle(
                          color: const Color(0xFFFF6600),
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0),
                    ))
                  ],
                ))
          ],
        ),
      ),
      onTap: () {
        launchURL(item.url);
      },
    );
  }
}
