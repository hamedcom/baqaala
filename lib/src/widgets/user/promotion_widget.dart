import 'package:baqaala/src/widgets/vivek/detailpage.dart';
import 'package:baqaala/src/widgets/vivek/travelbean.dart';
import 'package:flutter/material.dart';

class PromotionWidget extends StatelessWidget {
  List<TravelBean> _list = TravelBean.generateTravelBean();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(viewportFraction: 1),
      itemBuilder: (context, index) {
        var bean = _list[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DetailPage(bean);
            }));
          },
          child: Hero(
            tag: bean.url,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 15, right: 10, left: 10),
                  child: Card(
                    elevation: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        bean.url,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: _list.length,
    );
  }
}
