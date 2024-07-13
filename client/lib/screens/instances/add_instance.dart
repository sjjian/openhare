import 'package:client/models/instances.dart';
import 'package:client/providers/instances.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddInstancePage {
  static Future<void> showAddInstanceDialog(BuildContext context) {
    // todo: 释放资源
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController descCtrl = TextEditingController();
    TextEditingController addrCtrl = TextEditingController();
    TextEditingController portCtrl = TextEditingController(text: "3306");
    TextEditingController userCtrl = TextEditingController();
    TextEditingController passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              alignment: Alignment.center,
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 532),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Row(
                          children: [
                            const Text(
                              "添加数据源",
                              style: TextStyle(fontSize: 24),
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
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 80),
                                  child: TextFormField(
                                    controller: nameCtrl,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "名称不能为空";
                                      }
                                      if (context
                                          .read<InstancesProvider>()
                                          .isInstanceExist(value)) {
                                        return "名称已存在";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        labelText: "名称",
                                        contentPadding:
                                            const EdgeInsets.all(10)),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 90),
                                  child: TextFormField(
                                    controller: descCtrl,
                                    maxLength: 50,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        labelText: "描述",
                                        contentPadding:
                                            const EdgeInsets.all(10)),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 80),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: addrCtrl,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              labelText: "地址",
                                              contentPadding:
                                                  const EdgeInsets.all(10)),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 120),
                                        child: TextFormField(
                                          controller: portCtrl,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              labelText: "端口",
                                              contentPadding:
                                                  const EdgeInsets.all(10)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 80),
                                  child: TextFormField(
                                    controller: userCtrl,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        labelText: "帐号",
                                        contentPadding:
                                            const EdgeInsets.all(10)),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 80),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      // if
                                      print(value);
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "密码不能为空";
                                      }
                                      return null;
                                    },
                                    controller: passwordCtrl,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        labelText: "密码",
                                        contentPadding:
                                            const EdgeInsets.all(10)),
                                  ),
                                ),
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
                                        context
                                            .read<InstancesProvider>()
                                            .addInstance(InstanceModel(
                                                name: nameCtrl.text,
                                                addr: addrCtrl.text,
                                                port: 3306,
                                                user: userCtrl.text,
                                                password: passwordCtrl.text));

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
              ));
        });
  }
}
