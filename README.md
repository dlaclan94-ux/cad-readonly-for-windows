# CAD Readonly for Windows

## CAD 읽기 전용 열기 — `cad-readonly/`

`.dwg` 를 AutoCAD 에서 읽기 전용으로 엽니다. 파일을 잠그지 않아 다른 사람이
작업 중인 서버 도면도 열 수 있습니다. 실행할 때 파워쉘 창이 뜨지 않고, AutoCAD 를 새로 띄운 경우
시작할 때 생기는 빈 도면(Drawing1)은 닫습니다.

```powershell
cad-readonly\open_readonly.ps1 -Install     # .dwg 오른쪽 클릭 메뉴에 "AutoCAD 읽기 전용으로 열기" 추가
cad-readonly\open_readonly.ps1 -Uninstall   # 메뉴 제거
```

Windows 11 에서는 오른쪽 클릭 → "더 많은 옵션 표시"(Shift+F10) 안에 있습니다.

> **`-Install` / `-Uninstall` 은 시작 메뉴에서 연 PowerShell 창에서 실행하세요.**
> Claude 데스크톱 앱(Microsoft Store 방식으로 설치됨) 안의 터미널이나 Claude 에게 시켜서 실행하면
> 레지스트리 등록이 Claude 전용 가상 레지스트리에만 들어가 탐색기 메뉴에 나타나지 않습니다.
> `[완료]` 가 나왔는데 메뉴가 안 보이면 이 경우입니다.
>
> ```powershell
> powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\Claude Code\cad-readonly-for-windows\cad-readonly\open_readonly.ps1" -Install
> ```

`-Install` 은 스크립트를 `%LOCALAPPDATA%\mini-tool\cad-readonly\` 에 복사해 등록하므로 저장소 폴더를
옮겨도 메뉴가 끊기지 않습니다. 스크립트를 고친 뒤에는 `-Install` 을 다시 실행해야 반영됩니다.
