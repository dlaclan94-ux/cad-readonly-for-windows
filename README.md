# CAD Readonly for Windows

`.dwg` 파일을 오른쪽 클릭 메뉴에서 AutoCAD 읽기 전용으로 엽니다.
파일을 잠그지 않아 다른 사람이 작업 중인 서버 도면도 열 수 있고, 실수로 덮어쓸 일도 없습니다. (저장하려면 다른 이름으로 저장)
실행할 때 PowerShell 창이 뜨지 않고, AutoCAD 를 새로 띄운 경우 시작할 때 생기는 빈 도면(Drawing1)은 닫습니다.

## 지원 환경

- Windows 10 / 11
- AutoCAD 2010 ~ 2026. 2024 에서 확인했고, 다른 버전도 같은 방식(COM)으로 엽니다.
  여러 버전이 깔려 있으면 실행 중인 AutoCAD 에 먼저 붙고, 실행 중인 것이 없으면 가장 새 버전을 띄웁니다.
- AutoCAD LT 는 외부 자동화(COM)를 지원하지 않아 쓸 수 없습니다.

## 설치

1. 이 저장소를 내려받습니다. (`Code` → `Download ZIP` 후 압축 풀기, 또는 `git clone`)
2. 시작 메뉴에서 PowerShell 을 열고, 내려받은 폴더로 이동해 실행합니다.

```powershell
cd "내려받은 폴더"
powershell -ExecutionPolicy Bypass -File .\cad-readonly\open_readonly.ps1 -Install
```

`.dwg` 오른쪽 클릭 메뉴에 "AutoCAD 읽기 전용으로 열기"가 생깁니다.
Windows 11 에서는 오른쪽 클릭 → "더 많은 옵션 표시"(Shift+F10) 안에 있습니다.

`-Install` 은 스크립트를 `%LOCALAPPDATA%\cad-readonly\` 에 복사해 등록하므로, 내려받은 폴더는 옮기거나 지워도 됩니다.
스크립트를 고친 뒤에는 `-Install` 을 다시 실행해야 반영됩니다.

## 제거

```powershell
powershell -ExecutionPolicy Bypass -File .\cad-readonly\open_readonly.ps1 -Uninstall
```

메뉴와 `%LOCALAPPDATA%\cad-readonly\` 를 지웁니다.

## 라이선스

[MIT](LICENSE)

## 참고

Claude 데스크톱 앱(Microsoft Store 방식으로 설치됨) 안의 터미널이나 Claude 에게 시켜서 `-Install` / `-Uninstall` 을 실행하면,
레지스트리 등록이 Claude 전용 가상 레지스트리에만 들어가 탐색기 메뉴에 나타나지 않습니다.
`[완료]` 가 나왔는데 메뉴가 안 보이면 시작 메뉴에서 연 PowerShell 에서 다시 실행하세요.
