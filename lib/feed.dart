import 'package:flutter_web/material.dart';
import 'dart:html' as html;
import 'repository.dart';
import 'stories.dart';
import 'item.dart';
import 'item_row.dart';

class MainWidgetState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        // The number of tabs / content sections we need to display
        length: 5,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Hacker News Flutter'),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (builder) {
                          return Padding(
                              padding: EdgeInsets.all(64),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                            height: 100,
                                            width: 100,
                                            decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        const Color(0xfff1f1f1),
                                                    width: 4.0),
                                                image: new DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: new NetworkImage(
                                                      'https://avatars3.githubusercontent.com/u/6789991?s=460&v=4',
                                                    )))),
                                        Padding(
                                          padding: EdgeInsets.only(right: 16),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'by Alfian Losari - Made in Jakarta with Love 😋😋😋',
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
                                        )
                                      ],
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'GitHub Repo - https://github.com/alfianlosari/flutter-hackernews',
                                      ),
                                      onPressed: () {
                                        html.window.open(
                                            'https://github.com/alfianlosari/flutter-hackernews',
                                            '');
                                      },
                                    )
                                  ]));
                        });
                  },
                  child: Text("About"),
                )
              ],
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.grade),
                    text: 'Top',
                  ),
                  Tab(
                    icon: Icon(Icons.new_releases),
                    text: 'Latest',
                  ),
                  Tab(
                    icon: Icon(Icons.people),
                    text: 'Jobs',
                  ),
                  Tab(
                    icon: Icon(Icons.slideshow),
                    text: 'Show',
                  ),
                  Tab(
                    icon: Icon(Icons.question_answer),
                    text: 'Asks',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                FeedWidget(stories: Stories.top),
                FeedWidget(stories: Stories.newest),
                FeedWidget(
                  stories: Stories.jobs,
                ),
                FeedWidget(
                  stories: Stories.shows,
                ),
                FeedWidget(
                  stories: Stories.asks,
                )
              ],
            )));
  }
}

class FeedWidget extends StatefulWidget {
  final Stories stories;
  final repository = HackerNewsRepository();

  FeedWidget({this.stories});

  @override
  State<StatefulWidget> createState() {
    return FeedWidgetState();
  }
}

class FeedWidgetState extends State<FeedWidget>
    with AutomaticKeepAliveClientMixin<FeedWidget> {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<dynamic>> feeds;

  @override
  void initState() {
    feeds = widget.repository.getFeed(widget.stories);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () {
          feeds = widget.repository.getFeed(widget.stories);
          setState(() {});
          return feeds;
        },
        child: FutureBuilder<List<dynamic>>(
          future: feeds,
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return FeedListWidget(
                ids: snapshot.data,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}

class FeedListWidget extends StatelessWidget {
  final List<dynamic> ids;
  final repository = HackerNewsRepository();

  final double mediumBreakPoint = 800;

  FeedListWidget({this.ids});

  @override
  Widget build(BuildContext context) {
    final smallestWidth = MediaQuery.of(context).size.shortestSide;
    if (smallestWidth >= mediumBreakPoint) {
      return Align(
        alignment: Alignment.center,
        child: Container(width: 1024, child: _getGrid()),
      );
    } else {
      return _getList();
    }
  }

  GridView _getGrid() {
    final width = 1024 / 2;
    const height = 122;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: width / height,
        crossAxisCount: 2,
      ),
      itemCount: this.ids.length,
      itemBuilder: (ctx, position) {
        final id = ids[position];
        return FutureBuilder<Item>(
          future: repository.getItem(id),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              final item = snapshot.data;
              return ItemRow(item: item);
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }

  ListView _getList() {
    return ListView.builder(
        itemCount: this.ids.length,
        itemBuilder: (ctx, position) {
          final id = ids[position];
          return FutureBuilder<Item>(
            future: repository.getItem(id),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                final item = snapshot.data;
                return ItemRow(item: item);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        });
  }
}
