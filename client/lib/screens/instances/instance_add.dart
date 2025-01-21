import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> showAddInstanceDialog(BuildContext context) {
  // todo: 释放资源
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          child: AddInstancePage(),
        );
      });
}

Future<void> showUpdateInstanceDialog(
    BuildContext context, InstanceModel instance) {
  // todo: 释放资源
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          child: UpdateInstancePage(instance: instance),
        );
      });
}

class AddInstancePage extends StatelessWidget {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController addrCtrl = TextEditingController();
  final TextEditingController portCtrl = TextEditingController(text: "3306");
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final String title = "添加数据源";

  AddInstancePage({Key? key}) : super(key: key);

  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().addInstance(instance);
  }

  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      if (context.read<InstancesProvider>().isInstanceExist(value)) {
        return "名称已存在";
      }
      return null;
    };
  }

  FormFieldValidator validatorPassword() {
    return (value) {
      if (value == null || value.isEmpty) {
        return "密码不能为空";
      }
      return null;
    };
  }

  Widget nameFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return commonFormField("名称", ctrl, validator: validator);
  }

  Widget passwordFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        obscureText: true,
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          labelText: "密码",
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget commonFormField(String label, TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: label,
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget addressFormField(
      TextEditingController addrCtrl, TextEditingController portCtrl) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: addrCtrl,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  labelText: "地址",
                  contentPadding: const EdgeInsets.all(10)),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: TextFormField(
              controller: portCtrl,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  labelText: "端口",
                  contentPadding: const EdgeInsets.all(10)),
            ),
          )
        ],
      ),
    );
  }

  Widget descFormField(TextEditingController descCtrl) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      child: TextFormField(
        controller: descCtrl,
        maxLength: 50,
        maxLines: 2,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: "描述",
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 532),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close))
                ],
              ))
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Form(
              key: formKey,
              child: Column(
                children: [
                  nameFormField(nameCtrl, validator: validatorName(context)),
                  descFormField(descCtrl),
                  addressFormField(addrCtrl, portCtrl),
                  commonFormField("账号", userCtrl),
                  passwordFormField(passwordCtrl,
                      validator: validatorPassword()),
                ],
              )),
        ),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 40, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onSubmit(
                              context,
                              InstanceModel(
                                name: nameCtrl.text,
                                addr: addrCtrl.text,
                                port: int.parse(portCtrl.text),
                                user: userCtrl.text,
                                password: passwordCtrl.text,
                                desc: descCtrl.text,
                              ));
                          context.pop();
                        }
                      },
                      child: const Text("提交"))
                ],
              ),
            ),
          ],
        ))
      ]),
    );
  }
}

class UpdateInstancePage extends AddInstancePage {
  @override
  String get title => "更新数据源";

  UpdateInstancePage({Key? key, required InstanceModel instance})
      : super(key: key) {
    nameCtrl.text = instance.name;
    descCtrl.text = instance.desc ?? "";
    addrCtrl.text = instance.addr;
    portCtrl.text = instance.port.toString();
    userCtrl.text = instance.user;
    passwordCtrl.text = instance.password;
  }

  @override
  void onSubmit(BuildContext context, InstanceModel instance) {
    context.read<InstancesProvider>().updateInstance(instance);
  }

  @override
  FormFieldValidator validatorName(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) {
        return "名称不能为空";
      }
      return null;
    };
  }

  @override
  Widget nameFormField(TextEditingController ctrl,
      {FormFieldValidator? validator}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: TextFormField(
        readOnly: true,
        controller: ctrl,
        validator: validator,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: "名称",
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }
}
