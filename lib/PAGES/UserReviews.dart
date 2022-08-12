import 'package:flutter/material.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/COMPONENTS/ReviewTile.dart';
import 'package:humanly/MODELS/HelpReviewModel.dart';
import 'package:humanly/MODELS/DatabaseModel.dart';
import 'package:provider/provider.dart';

class UserReview extends StatelessWidget {
  const UserReview({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 5.0,
        iconTheme: IconTheme.of(context).copyWith(
          color: Colors.white,
        ),
        title: Text(
          'My Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'ProductSans',
            color: Colors.white,
          ),
        ),
      ),
      body: StreamProvider<List<HelpReviewModel>>(
        create: (_) => myReviews(),
        child: SafeArea(
          child: Container(
            child: UserReviewBody(),
          ),
        ),
      ),
    );
  }
}

class UserReviewBody extends StatefulWidget {
  UserReviewBody({Key key}) : super(key: key);

  @override
  _UserReviewBodyState createState() => _UserReviewBodyState();
}

class _UserReviewBodyState extends State<UserReviewBody> {
  @override
  Widget build(BuildContext context) {
    List<HelpReviewModel> _data = Provider.of<List<HelpReviewModel>>(context);

    if (_data != null && _data.length > 0) {
      return ListView(
        children: _data
            .map(
              (e) => ReviewTile(
                name: e.helperName,
                contact: e.helpLocation,
                rating: e.ratedAs.toDouble(),
              ),
            )
            .toList(),
      );
    } else if (_data != null && _data.length == 0) {
      return Center(
        child: Text(
          'no review data found!',
          style: TextStyle(
            fontFamily: 'Product Sans',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kPrimaryColor),
            ),
            SizedBox(
              height: 6.0,
            ),
            Text(
              'Please Wait...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
