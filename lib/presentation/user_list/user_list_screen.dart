import 'package:acote/presentation/user_list/ad_banner_item_widget.dart';
import 'package:acote/presentation/user_list/user_list_item_widget.dart';
import 'package:acote/routes/github_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widget/common_error_widget.dart';
import '../../controller/user_list_controller.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserListController controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UserListController>() ? Get.find<UserListController>() : Get.put(UserListController());
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !controller.isLoading.value) {
        controller.getMoreUsers();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              '사용자',
              style: TextStyle(fontSize: 16),
            ),
            Obx(() {
              return Expanded(
                child: controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.userList.isEmpty
                        ? const CommonErrorWidget()
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(const Duration(seconds: 1));
                              controller.getAllUsers();
                            },
                            child: ListView.builder(
                                controller: scrollController,
                                itemCount: controller.itemCount() + (controller.isFetching.value ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // 광고 배너 표시
                                  if (controller.isAdBanner(index)) {
                                    return AdBannerItemWidget(
                                      key: Key('banner:${index~/10}'),
                                      onTapAdd: () async => controller.onTapAdd(),
                                    );
                                  }

                                  // 스크롤 끝까지 닿을 경우, 로딩 인디케이터 보여주고 추가로 fetch
                                  if (index == controller.itemCount()) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  int userIndex = controller.getUserIndex(index);
                                  String username = controller.userList[userIndex].login;
                                  return InkWell(
                                    onTap: () {
                                      Get.toNamed(GithubPage.USER_DETAIL, arguments: {'username': username});
                                    },
                                    child: UserListItemWidget(
                                      key: Key(username),
                                      username: controller.userList[userIndex].login,
                                      avatarUrl: controller.userList[userIndex].avatarUrl,
                                    ),
                                  );
                                }),
                          ),
              );
            })
          ],
        ),
      ),
    );
  }
}
