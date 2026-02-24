import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:triftly/core/extensions/localizations.dart';
import 'package:triftly/features/_standalone/login/bloc/login_bloc.dart';
import 'package:triftly/router/app_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    void handleSubmit() {
      if (formKey.currentState!.saveAndValidate()) {
        context.read<LoginBloc>().add(
              LoginRequest(
                email: formKey.currentState!.value['email'],
                credentials: formKey.currentState!.value['credentials'],
              ),
            );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FormBuilder(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  context.go(AppPage.today.path);
                }
                if (state is LoginFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email or password is incorrect.'),
                    ),
                  );
                }
              },
              builder: (BuildContext context, LoginState loginState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppPage.today.path);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                        Text(
                          context.l10n.page_login,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecoration(
                        labelText: context.l10n.login_page_email,
                        hintText: 'example@example.com',
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'credentials',
                      decoration: InputDecoration(
                        labelText: context.l10n.login_page_password,
                        hintText: context.l10n.login_page_password,
                      ),
                      validator: FormBuilderValidators.required(),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed:
                          loginState is! LoginLoading ? handleSubmit : null,
                      child: Text(context.l10n.login_page_submit),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
