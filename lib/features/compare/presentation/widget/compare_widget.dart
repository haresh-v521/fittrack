import 'dart:io';

import 'package:fittrack/common/general/buttons.dart';
import 'package:fittrack/common/general/date_time_format.dart';
import 'package:fittrack/common/general_widget.dart';
import 'package:fittrack/features/compare/presentation/bloc/bloc.dart';
import 'package:fittrack/ui_helper/colors.dart';
import 'package:fittrack/ui_helper/images.dart';
import 'package:fittrack/ui_helper/strings.dart';
import 'package:fittrack/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

Widget dateLabel({String label}) => labels(text: label, color: theme);

Widget weightLabel({String label}) => labels(text: "$weight_kg $label", color: green800);

Widget listItem({
  String dateTime1,
  String dateTime2,
  String weight1,
  String weight2,
  String image1,
  String image2,
}) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: item(image: image1, dateTime: dateTime1, weight: weight1)),
        Expanded(child: item(image: image2, dateTime: dateTime2, weight: weight2)),
      ],
    );

Widget item({String dateTime, String weight, String image}) => Container(
      height: height * 0.3,
      child: Card(
        color: white,
        elevation: 20,
        shadowColor: green,
        margin: EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  child: image != null
                      ? Image.network(image, fit: BoxFit.fill)
                      : imageAsset(img: bg_food_eat),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: dateLabel(label: dateTime),
              ),
              weightLabel(label: weight),
            ],
          ),
        ),
      ),
    );

class AddPhotoData extends StatelessWidget {
  Bloc bloc;

  AddPhotoData({this.bloc});

  DateTime dateTime1 = DateTime.now();
  DateTime dateTime2 = DateTime.now();
  File image1;
  File image2;
  double weight1;
  double weight2;
  bool img1 = false;
  bool img2 = false;
  final picker = ImagePicker();

  Future getImage(int i) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) if (i == 1) {
      image1 = File(pickedFile.path);
      bloc.add(GetComparePhotoEvent(image: image1, pic: i));
    } else {
      image2 = File(pickedFile.path);
      bloc.add(GetComparePhotoEvent(image: image2, pic: i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: bloc,
      listener: (BuildContext context, state) {
        // if (state is GetCompareWeight1State) weight1 = state.weight;
        if (state is GetCompareWeightState) {
          state.weightModel.pic == 1
              ? weight1 = state.weightModel.weight
              : weight2 = state.weightModel.weight;
        }
        // if (state is GetCompareDate1State) dateTime1 = state.dateTime;
        if (state is GetCompareDateState) {
          state.dateTimeModel.pic == 1
              ? dateTime1 = state.dateTimeModel.dateTime
              : dateTime2 = state.dateTimeModel.dateTime;
        }
        // if (state is GetComparePhoto1State) image1 = state.image;
        if (state is GetComparePhotoState) {
          state.imageModel.pic == 1
              ? image1 = state.imageModel.image
              : image2 = state.imageModel.image;
        }
        if (image1 != null) img1 = true;
        if (image2 != null) img2 = true;
      },
      child: BlocBuilder(
        cubit: bloc,
        builder: (BuildContext context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              labels(text: addPhoto, color: theme, size: 22),
              verticalSpace(height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: selection(
                      context: context,
                      weight: weight1,
                      dateTime: dateTime1,
                      image: image1,
                      select: 1,
                    ),
                  ),
                  Container(
                    child: VerticalDivider(
                      color: lightTheme,
                      thickness: 2,
                    ),
                    height: height * 0.4,
                  ),
                  Expanded(
                    child: selection(
                      context: context,
                      weight: weight2,
                      dateTime: dateTime2,
                      image: image2,
                      select: 2,
                    ),
                  ),
                ],
              ),
              submitButton(
                text: submit,
                textColor: white,
                disable: false,
                onPressed: () {
                  if (img1 && img2) {
                    bloc.add(SetCompareDataEvent(
                      beforeDate: dateTime1.toString(),
                      beforeWeight: weight1.toString() ?? "60",
                      beforeImage: image1,
                      afterDate: dateTime2.toString(),
                      afterWeight: weight2.toString() ?? "60",
                      afterImage: image2,
                    ));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget selection({
    BuildContext context,
    File image,
    DateTime dateTime,
    double weight,
    int select,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: decoratedContainer(
            child: Container(
              height: height * 0.17,
              width: height * 0.14,
              child: image != null
                  ? imageFile(img: image)
                  : icons(size: height * 0.1, icon: Icons.camera_alt, color: grey),
            ),
          ),
          onTap: () => getImage(select),
        ),
        verticalSpace(height * 0.01),
        image == null
            ? Padding(
                padding: EdgeInsets.all(height * 0.005),
                child: labels(text: selectImage, color: red, size: 10))
            : Container(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: InkWell(
            child: decoratedContainer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: height * 0.01),
                child: labels(
                  text: dateFormat(dateTime: dateTime, format: 'dd MMM yyyy'),
                  color: theme,
                  size: height * 0.015,
                ),
              ),
            ),
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2010),
                lastDate: DateTime(2050),
              ).then((value) {
                bloc.add(
                  GetCompareDateEvent(dateTime: value, pic: select),
                );
              });
            },
          ),
        ),
        pickerWithLabel(
          labelText: weight_kg,
          measure: kg,
          startValue: 10,
          endValue: 150,
          initialItem: 50,
          onItemChanged: (val) {
            double weight = double.parse((val + 10).toString());
            bloc.add(
              GetCompareWeightEvent(weight: weight, pic: select),
            );
          },
        ),
        verticalSpace(height * 0.01),
      ],
    );
  }
}
