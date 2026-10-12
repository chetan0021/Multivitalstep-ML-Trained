import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/services/specialist_service.dart';

class AddCommentDialogModel extends BaseViewModel {
  final remarkController = TextEditingController();
  final _logger = getLogger("AddCommentDialogViewModel");
  final _specialistService = locator<SpecialistService>();
  Future<bool> submitComment(
      {required String comment, required int assessmentId}) async {
    _logger.i(comment);
    if (comment.isEmpty) {
      Fluttertoast.showToast(msg: "The comment can not be empty, please fill");
      return false;
    }
    await _specialistService.addComment(
        assessmentId: assessmentId, comment: comment);
    return true;
  }
}
