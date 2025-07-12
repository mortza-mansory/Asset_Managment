import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/entities/invitation_entity.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/invitation_repository.dart';

class FetchMyInvitationsUseCase {
  final InvitationRepository repository;
  FetchMyInvitationsUseCase(this.repository);

  Future<Either<Failure, List<InvitationEntity>>> call() async {
    return await repository.getMyInvitations();
  }
}