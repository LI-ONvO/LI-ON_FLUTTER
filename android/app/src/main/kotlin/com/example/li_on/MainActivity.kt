package com.example.li_on

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 12+ 시스템 스플래시는 기본적으로 아이콘을 먼저 흐리게 없앤 뒤
        // 앱 화면을 드러내 그 사이 흰 화면이 잠깐 보인다. Flutter 스플래시가 같은
        // 로고를 같은 자리에 그리므로 애니메이션 없이 바로 걷어낸다.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { view -> view.remove() }
        }
    }
}
