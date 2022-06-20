import 'package:zando/global/utils.dart';

class Article {
  dynamic articleId;
  String articleLibelle;
  dynamic articleTimestamp;
  String articleState;

  Article(
      {this.articleLibelle,
      this.articleId,
      this.articleTimestamp,
      this.articleState});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};
    if (articleId != null) {
      data["article_id"] = int.parse(articleId.toString());
    }
    data["article_libelle"] = articleLibelle;
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (articleTimestamp == null) {
      data["article_create_At"] = convertToTimestamp(now);
    } else {
      data["article_create_At"] = int.parse(articleTimestamp.toString());
    }
    if (articleState == null) {
      data["article_state"] = "allowed";
    } else {
      data["article_state"] = articleState;
    }
    return data;
  }

  Article.fromMap(Map<String, dynamic> data) {
    articleId = data["article_id"];
    articleLibelle = data["article_libelle"];
    articleState = data["article_state"];
  }
}
