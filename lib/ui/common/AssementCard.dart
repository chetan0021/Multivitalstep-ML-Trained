// import 'package:flutter/material.dart';

// class AssesmentCard extends StatelessWidget {
//   AssesmentCard({super.key, required this.heading, required this.imagePath});
//   String heading;
//   String imagePath;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 130,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: const [
//           BoxShadow(
//             offset: Offset(0, 2),
//             color: Color.fromARGB(255, 196, 196, 196),
//             blurRadius: 5,
//           )
//         ],
//         borderRadius: BorderRadius.circular(15),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//       margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
//       child: Row(
//         children: [
//           Container(
//             height: 100,
//             width: 100,
//             padding: const EdgeInsets.all(25),
//             decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 130, 169, 198).withAlpha(50),
//                 borderRadius: BorderRadius.circular(10)),
//             child: Image.asset(imagePath),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           heading,
//                           style: const TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 3,
//                         ),
//                         const Text("Twice Daily"),
//                       ],
//                     ),
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Row(
//                           children: [
//                             Text("From:"),
//                             Text("23/07/2024"),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               "To:",
//                               style: TextStyle(fontSize: 13),
//                             ),
//                             Text(
//                               "23/07/2024",
//                               style: TextStyle(fontSize: 13),
//                             ),
//                           ],
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//                 const Spacer(),
//                 const Text(
//                   "Next, Today 09:00 P.M",
//                   style: TextStyle(fontSize: 13),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
