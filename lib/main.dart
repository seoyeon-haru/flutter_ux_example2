import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// ListView 에 출력할 아이템들
  List<int> items = List.generate(20, (index) => index);

  /// 현재 마지막 스크롤 도달했을 때 fetchMore 호출
  /// 호출 중일 때 또 마지막 스크롤이 머물러서 이동이 될 수 있음
  /// fetchMore 데이터 가지고 오는 중에는 fetchMore 더 이상 실현되지 않게 구현!
  bool isFetching = false;

  /// ListView 끝에 다 달았을 때 데이터 더 넣을 함수 정의
  void fetchMore() async {
    /// isFetching 이 실행중이라면 바로 함수 종료
    if (isFetching) {
      return;
    }

    /// isFetching 이 실행 중이 아니라면
    isFetching = true;

    /// async 달아서 duration Future.delayed 로 가상으로 실제 서버에서 받아온 것처럼 delayed
    await Future.delayed(Duration(milliseconds: 500));
    // 데이터 가지고 오고 나서 fetchMore 트리거 되고 실제로 호출됨이 한 번 더 실행이 됨
    /// ListView 업데이트 되고 나서 아이템 길이가 늘어났을 때 업데이트가 한번 더 되면서
    /// 트리거가 되는 현상 이때 Future.delayed 이용해서 duration 으로 300
    print('실제로 호출됨');

    /// 시간 지나면 List.generate 이용해서 새로 추가적인 리스트
    final newList = List.generate(20, (index) => items.length + index);
    items.addAll(newList);
    setState(() {});
    await Future.delayed(Duration(milliseconds: 300));
    // 상태 업데이트 다 해주고 나서
    isFetching = false;
  }

  /// ListView 최상단에서 끌어 당겼을 때 새로고침 되는 기능 구현!
  /// ListView 초기화 시키는 새로 고침하는 함수
  Future<void> onRefresh() async {
    if (isFetching) {
      return;
    }
    print('onRefresh 호출됨');
    isFetching = true;
    // 데이서 가져오는 시간 가정하기 위해서
    await Future.delayed(Duration(milliseconds: 500));
    items = List.generate(20, (index) => index);
    setState(() {});
    isFetching = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      /// 무한 스크롤 기능 구현
      /// ListView Wrap with Widget 해서 NotificationListener 로 넣어줌
      body: NotificationListener(
        onNotification: (notification) {
          /// notification 타입이 다양하기 때문에
          if (notification is ScrollUpdateNotification) {
            // 현재 위치가 스크롤 가능한 범위보다 크거나 같다면
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent) {
              print('fetchMore 호출됨');

              /// 데이터 더 불러온 함수 정의해 놓은 fetchMore 호출
              fetchMore();
            }
          }
          // 버블링 여부
          return false;
        },
        child: RefreshIndicator(
          /// onRefresh 에 Future<void> 타입을 리턴하는 함수를 넣어주면
          /// ListView 를 당겼을 때 알아서 새로고침 되는 아이콘이 나오고
          /// 새로고침 함수로 호출 해주게 됨
          onRefresh: onRefresh,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.amber,
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                child: Text('${items[index]}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
