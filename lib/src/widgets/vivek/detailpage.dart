import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'travelbean.dart';

class DetailPage extends StatefulWidget {
  final TravelBean bean;

  DetailPage(this.bean);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final double expanded_height = 300;
  final double rounded_container_height = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              _buildSliverHead(),
              SliverToBoxAdapter(
                child: _buildDetail(),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 15,
                  //   ),
                  //   child: Icon(
                  //     Icons.menu,
                  //     color: Colors.white,
                  //   ),
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSliverHead() {
    return SliverPersistentHeader(
      delegate: DetailSliverDelegate(
        expanded_height,
        widget.bean,
        rounded_container_height,
      ),
    );
  }

  Widget _buildDetail() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildUserInfo(),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            child: Text(
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link",
              style: TextStyle(
                color: Colors.black38,
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            child: Text(
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link",
              style: TextStyle(
                color: Colors.black38,
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            child: Text(
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link"
              "This Is Promotion Details Page. "
              "This could be a Product Link, or Category Link or Website Link",
              style: TextStyle(
                color: Colors.black38,
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
              child: Container(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.amber,
                  child: Text('Accept Offer'),
                  onPressed: () {
                    Get.back();
                  },
                ),
              )),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Promotion Heading',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class FeaturedWidget extends StatelessWidget {
  List<TravelBean> _list = TravelBean.generateMostPopularBean();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          width: 120,
          margin: EdgeInsets.only(
            right: 15,
          ),
          child: Image.asset(
            _list[index].url,
            fit: BoxFit.cover,
          ),
        );
      },
      itemCount: _list.length,
    );
  }
}

class DetailSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final TravelBean bean;
  final double rounded_container_height;

  DetailSliverDelegate(
      this.expandedHeight, this.bean, this.rounded_container_height);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: <Widget>[
          Hero(
            tag: bean.url,
            child: Image.asset(
              bean.url,
              width: MediaQuery.of(context).size.width,
              height: expandedHeight,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: expandedHeight - rounded_container_height - shrinkOffset,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: rounded_container_height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: expandedHeight - 120 - shrinkOffset,
          //   left: 30,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text(
          //         bean.name,
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 30,
          //         ),
          //       ),
          //       Text(
          //         bean.location,
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 15,
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
