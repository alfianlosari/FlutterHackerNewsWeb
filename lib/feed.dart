import 'package:flutter_web/material.dart';
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

  FeedListWidget({this.ids});

  @override
  Widget build(BuildContext context) {
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
