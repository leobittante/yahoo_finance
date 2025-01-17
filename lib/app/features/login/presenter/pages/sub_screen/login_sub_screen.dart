import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pokemon_dex/app/features/login/presenter/cubit/login_storage_cubit.dart';

import '../../../../../app_routes.dart';
import '../../../../../core/dialogs/app_dialogs.dart';
import '../../../../../core/style/app_text_styles.dart';
import '../../../../../core/utils/assert_route.dart';
import '../../../../../core/utils/validators.dart';
import '../../params/user_storage_params.dart';
import '../widgets/button_login_custom_widget.dart';
import '../widgets/text_field_custom_widget.dart';

class LoginSubScreen extends StatefulWidget {
  final Size size;
  const LoginSubScreen({Key? key, required this.size}) : super(key: key);

  @override
  State<LoginSubScreen> createState() => _LoginSubScreenState();
}

class _LoginSubScreenState extends State<LoginSubScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController textEditingControllerEmail,
      textEditingControllerPassword;

  bool validateEmail = false, validatePassword = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginStorageCubit, LoginStorageState>(
        bloc: Modular.get<LoginStorageCubit>(),
        builder: (context, state) {
          if (state is LoginStorageLoading) {
            loading = true;
          }
          if (state is LoginStorageSuccess) {
            loading = false;
            if (state.response.name.isNotEmpty) {
              Modular.to.pushReplacementNamed(assertRoute(AppRoutes.home),
                  arguments: {'name': state.response.name});
            }
          }
          if (state is LoginStorageError) {
            loading = false;
            AppDialog.message(context, state.errorMessage);
          }

          return Form(
            key: formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Text(
                    'Bem-vindo ao',
                    style: AppTextStyles.subTitleCards,
                  ),
                ),
                const Text(
                  'Pokémon Dex',
                  style: AppTextStyles.titleCards,
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 45.0),
                    child: TextFieldCustomWidget(
                      controller: textEditingControllerEmail,
                      labelText: "E-mail:",
                      textInputType: TextInputType.emailAddress,
                      paddingHorizontal: 40,
                      password: false,
                      validator: (value) =>
                          !AppValidator.emailValidator(value).isEmpty
                              ? AppValidator.emailValidator(value)
                              : null,
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFieldCustomWidget(
                      controller: textEditingControllerPassword,
                      labelText: "Senha:",
                      textInputType: TextInputType.number,
                      paddingHorizontal: 40,
                      lenghtText: 8,
                      password: true,
                      validator: (value) =>
                          !AppValidator.cannotBeNullableAndMin8(value).isEmpty
                              ? AppValidator.cannotBeNullableAndMin8(value)
                              : null,
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: ButtonLoginCustomWidget(
                    size: widget.size,
                    paddingHorizontal: 35,
                    textButton: 'ENTRAR',
                    loading: loading,
                    onTap: () => _loginButtonAction(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  //ACAO AO CLICAR NO BOTAO
  void _loginButtonAction() {
    final form = formKey.currentState!;
    if (form.validate()) {
      Modular.get<LoginStorageCubit>().getLogin(
          params: UserStorageParams(
        email: textEditingControllerEmail.text,
        password: textEditingControllerPassword.text,
      ));
    }
  }

  void _setupControllers() {
    textEditingControllerEmail = TextEditingController();
    textEditingControllerPassword = TextEditingController();
  }
}
