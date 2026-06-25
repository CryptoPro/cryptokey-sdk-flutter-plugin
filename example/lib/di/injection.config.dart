// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cpkey_example/data/auth_repository.dart' as _i1042;
import 'package:cpkey_example/navigation/navigation_service.dart' as _i449;
import 'package:cpkey_example/presentation/auth/auth_bloc.dart' as _i728;
import 'package:cpkey_example/presentation/cert/cert_bloc.dart' as _i477;
import 'package:cpkey_example/presentation/cert/create_cert_bloc.dart' as _i345;
import 'package:cpkey_example/presentation/keys/keys_bloc.dart' as _i1053;
import 'package:cpkey_example/presentation/main/main_bloc.dart' as _i536;
import 'package:cpkey_example/presentation/operations/operation_bloc.dart'
    as _i711;
import 'package:cpkey_example/presentation/profile/profile_bloc.dart' as _i600;
import 'package:cpkey_example/presentation/start_bloc.dart' as _i999;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i1053.KeysBloc>(() => _i1053.KeysBloc());
    gh.factory<_i536.MainBloc>(() => _i536.MainBloc());
    gh.factory<_i711.OperationsBloc>(() => _i711.OperationsBloc());
    gh.lazySingleton<_i1042.AuthRepository>(() => _i1042.AuthRepository());
    gh.lazySingleton<_i449.NavigationService>(() => _i449.NavigationService());
    gh.factory<_i728.AuthBloc>(
      () => _i728.AuthBloc(gh<_i449.NavigationService>()),
    );
    gh.factory<_i477.CertsBloc>(
      () => _i477.CertsBloc(gh<_i449.NavigationService>()),
    );
    gh.factory<_i345.CreateCertBloc>(
      () => _i345.CreateCertBloc(gh<_i449.NavigationService>()),
    );
    gh.factory<_i600.ProfileBloc>(
      () => _i600.ProfileBloc(gh<_i449.NavigationService>()),
    );
    gh.factory<_i999.StartBloc>(
      () => _i999.StartBloc(gh<_i449.NavigationService>()),
    );
    return this;
  }
}
