import 'dart:ui';

import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_flutter/models/post_model.dart';
import 'package:pro_flutter/pages/home/posts_page_details.dart';
import 'package:pro_flutter/pages/home/posts_page_recommend.dart';
import 'package:pro_flutter/widgets/cache_image.dart';
import 'package:pro_flutter/widgets/icon_animation_widget.dart';
import 'package:transparent_image/transparent_image.dart';

final colorProvider = StateProvider((ref) => 0);

class PostsPageItem extends ConsumerWidget {
  final Post post;
  final int index;


  const PostsPageItem({Key key, this.post, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return post.files.length > 0
        ? IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PostsPageDetails(postId: post.id,)));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset.fromDirection(1.6),
                        ),
                      ]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _createImage(),
                          _createTitle(),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 56.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _createAvatar(context),
                      _createViews(context),
                      _createLikes(context),
                      _createComments(context),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  ClipRRect _createTitle() {
    double _radius = 20.0;
    if (post?.category == '摄影' &&
        (post?.files?.length == 6 || post?.files?.length == 9)) {
      _radius = 0;
    }
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(_radius)),
      child: Container(
        color: Colors.white,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          right: 16,
          left: 16,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post?.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'SourceHanSans',
              ),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
            Padding(padding: EdgeInsets.only(top: 3)),
            Text(
              post?.user?.name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'SourceHanSans'),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _createComments(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Icon(
            Icons.mode_comment,
            size: 24,
            color: Colors.grey.withOpacity(0.4),
          ),
          Text(
            post?.totalComments != null ? post.totalComments.toString() : '0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _createViews(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.remove_red_eye,
          size: 24,
          color: Colors.grey.withOpacity(0.4),
        ),
        Text(
          post?.views.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _createLikes(BuildContext context) {
    return Column(
      children: [
        IconAnimationWidget(
          icon: Container(
            decoration: BoxDecoration(
                boxShadow: post?.liked == 0
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.red.shade400.withOpacity(0.15),
                          blurRadius: 8.0,
                          spreadRadius: 1,
                        )
                      ]),
            child: Icon(
              Icons.favorite,
              size: 24,
              color: post?.liked == 0
                  ? Colors.grey.withOpacity(0.6)
                  : Colors.red.withOpacity(0.8),
            ),
          ),
          clickCallback: () async {
            await context.read(postsProvider).clickLike(post.id, index);
          },
        ),
        Text(
          post.totalLikes.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _createAvatar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.8),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(60.0)),
      child: ClipOval(
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: post?.user?.avatar?.mediumAvatarUrl,
          fit: BoxFit.cover,
          width: 36.0,
        ),
      ),
    );
  }

  Widget _gridItemBuilder(BuildContext context, int index) {
    return CacheImage(url: post.files[index].thumbnailImageUrl);
  }

  Widget _createImage() {
    Files _files = post?.files[0];
    double _aspectRatio = 3 / 2;
    if (_files.width < _files?.height) {
      _aspectRatio = 3 / 4;
    }
    if (post?.category == '摄影' &&
        (post?.files?.length == 6 || post?.files?.length == 9)) {
      return Container(
        height: post?.files?.length == 6 ? 180 : 272,
        child: GridView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          itemCount: post?.files?.length,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6.0,
            mainAxisSpacing: 6.0,
          ),
          itemBuilder: _gridItemBuilder,
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: CacheImage(url: _files?.mediumImageUrl,),
      ),
    );
  }
}