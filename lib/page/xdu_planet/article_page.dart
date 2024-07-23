import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/xdu_planet/content_page.dart';
import 'package:watermeter/repository/xdu_planet_session.dart';

class ArticlePage extends StatefulWidget {
  final Article article;
  final String author;

  const ArticlePage({super.key, required this.article, required this.author});

  @override
  State<ArticlePage> createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  late Future<String> _articleContent;
  late Future<List<Comment>> _comments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _articleContent = PlanetSession().content(widget.article.content);
    _comments = PlanetSession().comments(widget.article.content);
  }

  @override
  void didUpdateWidget(covariant ArticlePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _articleContent = PlanetSession().content(widget.article.content);
    _comments = PlanetSession().comments(widget.article.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.article.title),
        ),
        body: FutureBuilder<String>(
          future: _articleContent,
          builder: (context, snapshot) {
            late Widget addon;
            if (snapshot.connectionState == ConnectionState.done) {
              try {
                addon = HtmlWidget(
                  snapshot.data ??
                      '''
  <h3>遇到错误</h3>
  <p>
    文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。
  </p>
''',
                  factoryBuilder: () => MyWidgetFactory(),
                );
              } catch (e) {
                return ReloadWidget(
                  function: () {
                    setState(() {
                      _articleContent =
                          PlanetSession().content(widget.article.content);
                    });
                  },
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
            return SelectionArea(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: widget.article.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextSpan(
                        text: "\n${widget.author} - "
                            "${Jiffy.parseFromDateTime(widget.article.time).format(pattern: "yyyy年MM月dd日 HH:mm")}",
                      ),
                    ]),
                  ),
                  const Divider(),
                  addon
                ],
              ).constrained(
                maxWidth: sheetMaxWidth - 16,
                minWidth: min(
                  MediaQuery.of(context).size.width,
                  sheetMaxWidth - 16,
                ),
              ),
            );
          },
        ).center().safeArea(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CommentSection(),
                )
              },
              child: const Icon(Icons.comment),
            ),
          ],
        ));
  }
}

class CommentSection extends StatelessWidget {
  List<Comment> comments = [
    Comment(
        articleId: "0",
        userId: '用户1',
        time: DateTime.now(),
        content: '这是一个评论内容。'),
    Comment(
        articleId: "0",
        userId: '用户2',
        time: DateTime.now().subtract(Duration(hours: 1)),
        content: '这是另一个评论内容。'),
  ];

  CommentSection(this.comments);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(comment.userId),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.time.toString()),
                      SizedBox(height: 5),
                      Text(comment.content),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 举报按钮功能
                            },
                            child: Text('举报'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 回复按钮功能
                            },
                            child: Text('回复'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '输入你的评论...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // 发送按钮功能
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void fetchComments() {}
}
