import 'package:fittrack/common/general/circular_progress_indicator.dart';
import 'package:fittrack/common/general_widget.dart';
import 'package:fittrack/di/dependency_injection.dart';
import 'package:fittrack/features/food_directory/presentation/pages/rich_food_directory/data/data_model/rich_food_model.dart';
import 'package:fittrack/features/food_directory/presentation/pages/rich_food_directory/presentation/bloc/bloc.dart';
import 'package:fittrack/features/food_directory/presentation/pages/rich_food_directory/presentation/widget/rich_food_widget.dart';
import 'package:fittrack/ui_helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RichFoodScreen extends StatefulWidget {
  String foodType;
  String categoryId;

  RichFoodScreen({this.foodType, this.categoryId});

  @override
  _RichFoodScreenState createState() => _RichFoodScreenState();
}

class _RichFoodScreenState extends State<RichFoodScreen> {
  RichFoodDataModel richFoodDataModel;

  bool isLoading = true;

  Bloc bloc = getIt<RichFoodBloc>();

  @override
  void initState() {
    bloc.add(FetchRichFoodDataEvent(offSet: "0", categoryId: widget.categoryId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: bloc,
      listener: (BuildContext context, state) {
        if (state is LoadingBeginRichFoodState) isLoading = true;
        if (state is LoadingEndRichFoodState) isLoading = false;
        if (state is FetchRichFoodDataState) richFoodDataModel = state.data;
      },
      child: BlocBuilder(
        cubit: bloc,
        builder: (BuildContext context, state) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: theme,
                title: labels(text: widget.foodType),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: isLoading
                  ? circularProgressIndicator
                  : ListView.separated(
                      itemCount: richFoodDataModel.data.length,
                      itemBuilder: (context, index) => InkWell(
                        child: listItem(
                          data: richFoodDataModel.data[index],
                          bloc: bloc,
                          context: context,
                        ),
                        // onTap: () => Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => RichFoodDetailScreen(
                        //       bloc: bloc,
                        //       foodId: richFoodDataModel.data[index].foodId,
                        //     ),
                        //   ),
                        // ),
                      ),
                      separatorBuilder: (context, index) => listDivider(padding: 10),
                    ),
            ),
          );
        },
      ),
    );
  }
}
