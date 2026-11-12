<#
    DWG 파일을 AutoCAD 에서 "읽기 전용"으로 엽니다.

    읽기 전용으로 열면 파일을 잠그지 않으므로, 서버의 도면을 다른 사람이
    작업 중이어도 열 수 있고 실수로 덮어쓸 일도 없습니다. (저장하려면 다른 이름으로 저장)

    사용:
        open_readonly.ps1 "도면.dwg"      파일 하나를 읽기 전용으로 열기
        open_readonly.ps1 -Install         .dwg 오른쪽 클릭 메뉴에 "AutoCAD 읽기 전용으로 열기" 추가
        open_readonly.ps1 -Uninstall       메뉴 제거

    ※ Windows PowerShell 5.1 이 한글을 읽도록 "BOM 있는 UTF-8"로 저장해야 합니다.
#>
param(
    [string]$Path,
    [switch]$Install,
    [switch]$Uninstall
)

$menuKey = 'HKCU:\Software\Classes\SystemFileAssociations\.dwg\shell\OpenReadOnlyAutoCAD'
$installDir = Join-Path $env:LOCALAPPDATA 'mini-tool\cad-readonly'
# 설치된 AutoCAD 버전 (2024 = 24.3). 앞에서부터 차례로 시도한다.
$progIds = 'AutoCAD.Application.24.3', 'AutoCAD.Application.24', 'AutoCAD.Application'

function Show-Error([string]$Message) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($Message, 'AutoCAD 읽기 전용 열기', 'OK', 'Error') | Out-Null
}

# ---------------------------------------------------------------- 메뉴 설치 / 제거
if ($Install) {
    $acadExe = (Get-ItemProperty 'Registry::HKEY_CLASSES_ROOT\AutoCAD.Drawing.24\DefaultIcon' -ErrorAction SilentlyContinue).'(default)'
    # 저장소 폴더를 옮겨도 메뉴가 끊기지 않도록 고정 위치에 복사해 두고 그 사본을 등록한다.
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    $installed = (Copy-Item -LiteralPath $PSCommandPath -Destination $installDir -Force -PassThru).FullName
    New-Item -Path "$menuKey\command" -Force | Out-Null
    Set-Item -Path $menuKey -Value 'AutoCAD 읽기 전용으로 열기'
    if ($acadExe) { Set-ItemProperty -Path $menuKey -Name 'Icon' -Value $acadExe }
    # conhost --headless: Windows 터미널이 기본 터미널이어도 창을 띄우지 않는다 (-WindowStyle Hidden 만으로는 창이 보임)
    Set-Item -Path "$menuKey\command" -Value ("conhost.exe --headless powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$installed`" `"%1`"")
    Write-Host '[완료] .dwg 오른쪽 클릭 메뉴에 "AutoCAD 읽기 전용으로 열기"를 추가했습니다.' -ForegroundColor Green
    Write-Host '       Windows 11 에서는 "더 많은 옵션 표시"(Shift+F10) 안에 있습니다.'
    exit 0
}
if ($Uninstall) {
    Remove-Item -Path $menuKey -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $installDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host '[완료] 메뉴를 제거했습니다.' -ForegroundColor Green
    exit 0
}

# ---------------------------------------------------------------- 읽기 전용으로 열기
if (-not $Path -or -not (Test-Path -LiteralPath $Path)) {
    Show-Error "파일을 찾을 수 없습니다.`n$Path"
    exit 1
}
$full = (Resolve-Path -LiteralPath $Path).ProviderPath

# AutoCAD 가 시작 중이면 COM 호출을 거절(RPC_E_CALL_REJECTED)하므로 잠시 기다렸다 다시 시도한다.
function Invoke-Retry([scriptblock]$Action) {
    for ($i = 0; $i -lt 60; $i++) {
        try { return & $Action } catch {
            if ($_.Exception.HResult -ne -2147418111 -and $_.Exception.InnerException.HResult -ne -2147418111) { throw }
            Start-Sleep -Milliseconds 500
        }
    }
    throw 'AutoCAD 가 응답하지 않습니다.'
}

try {
    $acad = $null
    $started = $false
    foreach ($id in $progIds) {        # 이미 실행 중인 AutoCAD 에 붙는다
        try { $acad = [Runtime.InteropServices.Marshal]::GetActiveObject($id); break } catch {}
    }
    if (-not $acad) {                  # 없으면 새로 띄운다
        foreach ($id in $progIds) {
            try { $acad = New-Object -ComObject $id; $started = $true; break } catch {}
        }
    }
    if (-not $acad) { throw 'AutoCAD 를 찾을 수 없습니다.' }
    Invoke-Retry { $acad.Visible = $true }

    # 이미 열려 있으면 그 도면으로 전환만 한다.
    foreach ($d in (Invoke-Retry { @($acad.Documents) })) {
        if ($d.FullName -eq $full) { Invoke-Retry { $d.Activate() }; exit 0 }
    }
    $doc = Invoke-Retry { $acad.Documents.Open($full, $true) }   # 두 번째 인자 = 읽기 전용

    # 방금 AutoCAD 를 띄웠다면 시작할 때 생긴 빈 도면(Drawing1)을 닫는다.
    # 저장된 적 없고(Path 비어 있음) 수정되지 않은(Saved) 도면만 닫으므로 작업 내용은 건드리지 않는다.
    if ($started) {
        foreach ($d in (Invoke-Retry { @($acad.Documents) })) {
            if ($d.FullName -ne $doc.FullName -and -not $d.Path -and $d.Saved) {
                Invoke-Retry { $d.Close($false) }
            }
        }
        Invoke-Retry { $doc.Activate() }
    }
} catch {
    Show-Error "읽기 전용으로 열지 못했습니다.`n$full`n`n$($_.Exception.Message)"
    exit 1
}
