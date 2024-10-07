part of 'package:timona_ec/pages/my.dart';

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors
// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, use_build_context_synchronously

class ImportSettings extends StatefulWidget {
  const ImportSettings(this.block, this.blockBase, this.rowBase, {super.key});

  final Function block, blockBase, rowBase;

  @override
  ImportSettingsState createState() => ImportSettingsState();
}

class ImportSettingsState extends State<ImportSettings> {
  String? file1Place, file2Place;
  bool pickingFile = false;

  @override
  void initState() {
    super.initState();
  }

  void process() {
    if (file1Place != null && file2Place != null) {
      showCheckSheet("确定导入吗？将覆盖现有用户数据，且不可撤销。建议在导入前先导出当前数据", context, () async {
        final Directory boxDir = await getApplicationDocumentsDirectory();
        final String boxPlace = "${boxDir.path}/GetStorage.gs";
        final String realmPlace = ECApp.realm.config.path;
        File file1 = File(file1Place!);
        File file2 = File(file2Place!);
        await file1.copy(boxPlace);
        await file2.copy(realmPlace);
        context.pop();
        context.replace('/my/imported');
      });
    } else {
      showHud(ProgressHudType.error, "请先选择两部分文件");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.block(
        "导入",
        [
          (
            file1Place == null
                ? "选择第一部分 .pbkp1 文件"
                : "已选择：${file1Place!.split('/').last}",
            () => pickFile(1)
          ),
          (
            file2Place == null
                ? "选择第二部分 .pbkp2 文件"
                : "已选择：${file2Place!.split('/').last}",
            () => pickFile(2)
          ),
        ],
      ),
      widget.block(
        "提交",
        [
          (
            "开始导入",
            () => process(),
          ),
        ],
      ),
    ]);
  }

  Future<void> pickFile(int part) async {
    FilePickerResult? result;
    if (!pickingFile) {
      pickingFile = true;
      if (isMobile()) {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 PBKP$part 文件以导入",
          type: FileType.any,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 PBKP$part 文件以导入",
          type: FileType.custom,
          allowedExtensions: ["pbkp$part"],
        );
      }
    } else {
      showHudC(ProgressHudType.error, "请勿重复打开", context);
      return;
    }
    if (result != null) {
      if (part == 1) {
        if (result.files.single.path?.contains('.pbkp1') ?? false) {
          file1Place = result.files.single.path;
        } else {
          showHudC(ProgressHudType.error, "请打开扩展名为 .pbkp1 的导出文件", context);
        }
      } else {
        if (result.files.single.path?.contains('.pbkp2') ?? false) {
          file2Place = result.files.single.path;
        } else {
          showHudC(ProgressHudType.error, "请打开扩展名为 .pbkp2 的导出文件", context);
        }
      }
    } else {
      showHudC(ProgressHudType.error, "未选择文件", context);
    }
    pickingFile = false;
  }
}

class ExportSettings extends StatefulWidget {
  const ExportSettings(this.block, this.blockBase, this.rowBase, {super.key});

  final Function block, blockBase, rowBase;

  @override
  ExportSettingsState createState() => ExportSettingsState();
}

class ExportSettingsState extends State<ExportSettings> {
  final box = GetStorage();

  bool processing = false;
  bool processed = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> process() async {
    final Directory boxDir = await getApplicationDocumentsDirectory();
    final String boxPlace = "${boxDir.path}/GetStorage.gs";
    final String realmPlace = ECApp.realm.config.path;
    String? selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "选择导出的位置",
    );
    try {
      File boxFile = File(boxPlace);
      File realmFile = File(realmPlace);
      String timeString = dateTimeSSWY(DateTime.now())
          .replaceAll(':', '.')
          .replaceAll(' ', '.');
      await boxFile.copy('$selectedDir/$timeString.pbkp1');
      await realmFile.copy('$selectedDir/$timeString.pbkp2');
      processing = false;
      processed = true;
    } catch (e) {
      showHud(ProgressHudType.error, "导出遇到错误：$e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (!processing && !processed)
        widget.block("导出", [
          (
            "开始导出数据",
            () {
              processing = true;
              process();
              setState(() {});
            }
          ),
        ]),
      if (processing)
        widget.blockBase(
          widget.rowBase("数据正在导出中，请稍候...", () {}, Text("")),
        ),
      if (processed)
        widget.blockBase(
          widget.rowBase("导出成功！导出的数据分为两部分，文件\n可以在刚才选定的文件夹中找到", () {}, Text("")),
        ),
    ]);
  }
}

class ImportedPage extends StatelessWidget {
  const ImportedPage({super.key});

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    return Container(
      color: Pantone.white,
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 20.h),
      child: Text(
        "导入完成 请重新启动应用",
        style: TextStyle(color: Pantone.green, fontSize: 21.sp),
      ),
    );
  }
}

class DebugInfoSettings extends StatefulWidget {
  const DebugInfoSettings(this.blockBase, this.rowBase, {super.key});

  final Function blockBase, rowBase;

  @override
  DebugInfoSettingsState createState() => DebugInfoSettingsState();
}

class DebugInfoSettingsState extends State<DebugInfoSettings> {
  List<PendingNotificationRequest> pendingRequests = [];
  List<String> pendingRequestsContents = [];

  @override
  void initState() {
    super.initState();
    initPendingRequests();
  }

  Future<void> initPendingRequests() async {
    pendingRequests = await ECApp.notifier.pendingNotificationRequests();
    for (var item in pendingRequests) {
      pendingRequestsContents.add(
        "${item.id}, ${item.title ?? 'unnamed'}: ${item.payload}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.blockBase(
        widget.rowBase(
            "Notifications Queue: $pendingRequestsContents", () {}, Text("")),
      ),
    ]);
  }
}
