import 'package:flutter/material.dart';

Widget NavOption(String heading, IconData icon, Function onClick) {
  return GestureDetector(
    onTap: () {
      onClick();
    },
    child: Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 55,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  heading,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Divider(
              thickness: 0.3,
              height: 1,
              color: Colors.grey,
            ),
          )
        ],
      ),
    ),
  );
}
