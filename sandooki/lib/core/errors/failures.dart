import 'package:equatable/equatable.dart';

/// Failure types surfaced to the presentation layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'حدث خطأ، حاول مرة أخرى.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'يرجى إدخال مبلغ صحيح.',
  ]);
}

class StorageFailure extends Failure {
  const StorageFailure([
    super.message = 'ما كدرنا نحفظ البيانات، حاول مرة ثانية.',
  ]);
}
