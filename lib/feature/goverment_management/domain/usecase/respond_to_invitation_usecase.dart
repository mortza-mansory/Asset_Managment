import 'package:dartz/dartz.dart';
import 'package:assetsrfid/core/error/failures.dart';
import 'package:assetsrfid/feature/goverment_management/domain/repository/invitation_repository.dart';

class RespondToInvitationUseCase {
  final InvitationRepository repository;

  RespondToInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call({required String token, required bool accept}) async {
    return await repository.respondToInvitation(token: token, accept: accept);
  }
}