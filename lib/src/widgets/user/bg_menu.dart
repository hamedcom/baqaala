import 'package:flutter/material.dart';

class BgMenu extends StatefulWidget {
  final Function close;

  BgMenu(this.close);

  @override
  _BgMenuState createState() => _BgMenuState();
}

class _BgMenuState extends State<BgMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
      ),
      height: double.infinity,
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: widget.close,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 5,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                  Text(
                    "Close menu",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                child: FlutterLogo(),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Vivek",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Open dashboard",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "services",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "My Orders",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Favourites",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Addresses",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "Customer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "FAQ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Reviews",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Stories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "about",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Company",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Pricing",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Blog",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Support center",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
