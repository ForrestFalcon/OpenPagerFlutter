import 'package:flutter_open_pager/models/operation_model.dart';
import 'package:flutter_open_pager/repositories/operation_repository.dart';
import 'package:rx_command/rx_command.dart';

class OperationAppModel {

  static final OperationAppModel _singleton = new OperationAppModel._internal();

  RxCommand<OperationModel, OperationModel> addOperationCommand;
  RxCommand<Null, List<OperationModel>> getOperationsCommand;
  RxCommand<int, Null> removeOperation;

  OperationAppModel._internal() {
    OperationRepository operationRepository = OperationRepository();

    this.getOperationsCommand = RxCommand.createAsync2<List<OperationModel>>(operationRepository.getOperations);
    this.addOperationCommand = RxCommand.createAsync3((operation) => operationRepository.insert(operation));
    this.removeOperation = RxCommand.createSync1(operationRepository.removeOperation);

    this.addOperationCommand.listen((t) => this.getOperationsCommand.execute());
    this.removeOperation.listen((t) => this.getOperationsCommand.execute());
  }

  factory OperationAppModel() {
    return _singleton;
  }
}
