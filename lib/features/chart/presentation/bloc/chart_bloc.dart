import 'package:fittrack/features/chart/domain/usecase/chart_usecase.dart';
import 'package:fittrack/features/chart/presentation/bloc/chart_event.dart';
import 'package:fittrack/features/chart/presentation/bloc/chart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartDataUseCase chartDataUseCase;

  ChartBloc({this.chartDataUseCase});

  @override
  ChartState get initialState => InitialChartState();

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {
    if (event is GetChartDataEvent) {
      yield LoadingBeginChartState();
      final result = await chartDataUseCase(ChartDataParams(
        dateType: event.dateType,
        month: event.month,
      ));
      yield LoadingEndChartState();
      yield result.fold(
        (error) => ErrorState(error.message),
        (success) => GetChartDataState(data: success),
      );
    }
  }
}