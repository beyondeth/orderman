firebase project name : order-market-app
authentication : google : project-486521508162
firestore database : 생성 -> 컬렉션 비어있음
order-market-app project info :
프로젝트 이름
order-market-app
프로젝트 ID
order-market-app
프로젝트 번호
486521508162
웹 API 키
AIzaSyC-TtpLTSgTJzICfp-MqOhlPakRNhrHtEw

Swift Package Manager를 사용해 Firebase 종속 항목을 설치하고 관리합니다.

앱 프로젝트를 연 상태로 Xcode에서 File(파일) > Add Packages(패키지 추가)로 이동합니다.
메시지가 표시되면 Firebase iOS SDK 저장소 URL을 입력합니다.
https://github.com/firebase/firebase-ios-sdk
사용할 SDK 버전을 선택합니다.
기본(최신) SDK 버전을 사용하는 것이 좋지만 필요하다면 이전 버전을 사용해도 됩니다.

사용할 Firebase 라이브러리를 선택합니다.
FirebaseAnalytics를 추가해야 합니다. IDFA 수집 기능이 없는 애널리틱스의 경우 대신 FirebaseAnalyticsWithoutAdId를 추가하세요.

Finish(완료)를 클릭하면 Xcode가 백그라운드에서 자동으로 종속 항목을 확인하고 다운로드하기 시작합니다.

GoogleService-Info.plist 파일 참고.

Firebase SDK가 google-services.json 구성 값에 액세스할 수 있도록 하려면 Google 서비스 Gradle 플러그인이 필요합니다.


Kotlin DSL(build.gradle.kts)

Groovy(build.gradle)
프로젝트 수준의 build.gradle.kts 파일에 플러그인을 종속 항목으로 추가합니다.

루트 수준(프로젝트 수준) Gradle 파일(<project>/build.gradle.kts):
plugins {
  // ...

  // Add the dependency for the Google services Gradle plugin
  id("com.google.gms.google-services") version "4.4.2" apply false

}
그런 다음 모듈(앱 수준) build.gradle.kts 파일에서 google-services 플러그인과 앱에서 사용할 Firebase SDK를 모두 추가합니다.

모듈(앱 수준) Gradle 파일(<project>/<app-module>/build.gradle.kts):
plugins {
  id("com.android.application")

  // Add the Google services Gradle plugin
  id("com.google.gms.google-services")

  ...
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:33.15.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}
Firebase Android BoM을 사용하면 앱에서 항상 호환되는 Firebase 라이브러리 버전을 사용합니다. 자세히 알아보기
플러그인과 원하는 SDK를 추가한 후 Android 프로젝트를 Gradle 파일과 동기화합니다.

google-services.json 파일 참고할것.


{"flutter":{"platforms":{"android":{"default":{"projectId":"order-market-app","appId":"1:486521508162:android:602bb63397cc90b28a38db","fileOutput":"android/app/google-services.json"}},"dart":{"lib/firebase_options.dart":{"projectId":"order-market-app","configurations":{"android":"1:486521508162:android:602bb63397cc90b28a38db","ios":"1:486521508162:ios:7585660b1ee9be578a38db","web":"1:486521508162:web:4ddd0f9d9e6b27668a38db"}}},"ios":{"default":{"projectId":"order-market-app","appId":"1:486521508162:ios:7585660b1ee9be578a38db","uploadDebugSymbols":false,"fileOutput":"ios/Runner/GoogleService-Info.plist"}}}}}